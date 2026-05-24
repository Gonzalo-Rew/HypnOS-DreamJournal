"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.backfillFollowCounters = exports.cleanupUserDataOnAuthDelete = exports.decrementFollowCounters = exports.notifyNewFollower = exports.notifyFollowRequestCreated = exports.incrementFollowCounters = exports.notifyFollowerOnDreamPublish = exports.transcribeAudio = exports.analyzeDream = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const generative_ai_1 = require("@google/generative-ai");
const functionsV1 = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const geminiApiKey = (0, params_1.defineSecret)('GEMINI_API_KEY');
const MODEL_NAME = 'gemini-2.5-flash';
const BACKFILL_TOKEN = 'backfill-20260521';
if (admin.apps.length === 0) {
    admin.initializeApp();
}
const db = admin.firestore();
const ANALYSIS_PROMPT_TEMPLATE = `
You are Morfeo, a compassionate dream analyst.
Analyze the following dream and respond with valid JSON only using exactly these keys:
sentiment, category, emotions, characters, places, themes, psychologicalNote, summary.

Rules:
- sentiment must be one of: positive, neutral, negative, mixed
- category must be one of: Adventure, Nightmare, Fantasy, Romantic, Surreal, Anxiety, Nostalgic, Spiritual, Neutral
- emotions: array of up to 5 short strings
- characters: array of up to 5 short strings
- places: array of up to 5 short strings
- themes: array of up to 5 short strings
- psychologicalNote: 2-3 empathetic sentences, no diagnosis
- summary: 1-2 short sentences that summarize the dream itself, using concrete events and images from the dream text; do not summarize the interpretation or reflection
- Always provide a best-effort analysis, even if the dream is brief or loosely structured.
- Only soften the reading when the text is clearly incoherent or gibberish.
- Output language: {responseLanguage}
- Mood score represents emotional intensity on waking, not happiness or sadness.
- Mood score scale: 1 = Calm, 2 = Mild, 3 = Moderate, 4 = Intense, 5 = Extreme.

Dream title: {title}
Dream text: {text}
Mood score (1-5): {moodScore}
Context notes: {context}
`.trim();
const FACETS_TO_UNIFY = ['emotions', 'characters', 'places', 'themes'];
const HISTORY_DREAMS_LIMIT = 100;
const FACET_SYNONYM_GROUPS = [
    ['sonador', 'soñador', 'dreamer'],
    ['casa', 'hogar', 'home'],
    ['miedo', 'temor', 'fear'],
    ['ansiedad', 'angustia', 'anxiety'],
    ['trabajo', 'oficina', 'office', 'work'],
];
const FACET_SYNONYM_INDEX = buildFacetSynonymIndex(FACET_SYNONYM_GROUPS);
function buildFacetSynonymIndex(groups) {
    const index = new Map();
    for (const group of groups) {
        const normalizedGroup = Array.from(new Set(group.map((item) => normalizeLabelForMatching(item)).filter((item) => item.length > 0)));
        for (const normalizedItem of normalizedGroup) {
            const alternatives = normalizedGroup.filter((candidate) => candidate !== normalizedItem);
            index.set(normalizedItem, alternatives);
        }
    }
    return index;
}
function resolveResponseLanguage(language) {
    return (language !== null && language !== void 0 ? language : '').toLowerCase().startsWith('es') ? 'Spanish' : 'English';
}
function normalizeLegacyTerm(value) {
    return value.replace(/\bsonador\b/gi, 'soñador');
}
function normalizeStringList(value) {
    if (!Array.isArray(value))
        return [];
    return value
        .map((item) => normalizeLegacyTerm(String(item !== null && item !== void 0 ? item : '').trim()))
        .filter((item) => item.length > 0);
}
function normalizeLabelForMatching(value) {
    return normalizeLegacyTerm(value)
        .trim()
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/\s+/g, ' ');
}
function getSimplePluralSingularVariants(normalizedLabel) {
    if (!normalizedLabel)
        return [];
    if (normalizedLabel.endsWith('s') && normalizedLabel.length > 1) {
        return [normalizedLabel.slice(0, -1)];
    }
    return [`${normalizedLabel}s`];
}
function getFacetSynonymVariants(normalizedLabel) {
    var _a;
    return (_a = FACET_SYNONYM_INDEX.get(normalizedLabel)) !== null && _a !== void 0 ? _a : [];
}
function buildFacetMatchKeys(label) {
    const normalized = normalizeLabelForMatching(label);
    if (!normalized)
        return [];
    const allKeys = new Set([normalized]);
    for (const variant of getSimplePluralSingularVariants(normalized)) {
        allKeys.add(variant);
    }
    for (const synonym of getFacetSynonymVariants(normalized)) {
        allKeys.add(synonym);
        for (const variant of getSimplePluralSingularVariants(synonym)) {
            allKeys.add(variant);
        }
    }
    return Array.from(allKeys);
}
function parseAnalysisObject(value) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
        return value;
    }
    if (typeof value !== 'string') {
        return null;
    }
    try {
        const parsed = JSON.parse(value);
        if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
            return parsed;
        }
    }
    catch (_err) {
        return null;
    }
    return null;
}
function extractAnalysesFromDreamData(dreamData) {
    const analyses = [];
    const aiAnalysis = parseAnalysisObject(dreamData['aiAnalysis']);
    if (aiAnalysis) {
        analyses.push(aiAnalysis);
    }
    const aiAnalysisByLanguage = dreamData['aiAnalysisByLanguage'];
    if (aiAnalysisByLanguage && typeof aiAnalysisByLanguage === 'object' && !Array.isArray(aiAnalysisByLanguage)) {
        for (const value of Object.values(aiAnalysisByLanguage)) {
            const parsed = parseAnalysisObject(value);
            if (parsed) {
                analyses.push(parsed);
            }
        }
    }
    return analyses;
}
function dedupeLabelsPreservingOrder(labels) {
    const seen = new Set();
    const output = [];
    for (const label of labels) {
        const key = normalizeLabelForMatching(label);
        if (!key || seen.has(key)) {
            continue;
        }
        seen.add(key);
        output.push(label);
    }
    return output;
}
function resolveCanonicalLabel(label, inventory) {
    for (const key of buildFacetMatchKeys(label)) {
        const matched = inventory.get(key);
        if (matched) {
            return matched;
        }
    }
    return label;
}
async function buildHistoricalFacetInventory(uid) {
    const inventory = {
        emotions: new Map(),
        characters: new Map(),
        places: new Map(),
        themes: new Map(),
    };
    const dreamsSnap = await db
        .collection('users')
        .doc(uid)
        .collection('dreams')
        .orderBy('createdAt', 'desc')
        .limit(HISTORY_DREAMS_LIMIT)
        .get();
    for (const dreamDoc of dreamsSnap.docs) {
        const dreamData = dreamDoc.data();
        const analyses = extractAnalysesFromDreamData(dreamData);
        for (const analysis of analyses) {
            for (const facet of FACETS_TO_UNIFY) {
                const labels = normalizeStringList(analysis[facet]);
                for (const label of labels) {
                    const canonical = label.trim();
                    if (!canonical)
                        continue;
                    const facetInventory = inventory[facet];
                    for (const key of buildFacetMatchKeys(canonical)) {
                        if (!facetInventory.has(key)) {
                            facetInventory.set(key, canonical);
                        }
                    }
                }
            }
        }
    }
    return inventory;
}
async function unifyAnalysisFacetsWithHistory(uid, normalizedAnalysisJson) {
    const parsed = JSON.parse(normalizedAnalysisJson);
    const inventory = await buildHistoricalFacetInventory(uid);
    for (const facet of FACETS_TO_UNIFY) {
        const labels = normalizeStringList(parsed[facet]);
        const unifiedLabels = labels.map((label) => resolveCanonicalLabel(label, inventory[facet]));
        parsed[facet] = dedupeLabelsPreservingOrder(unifiedLabels);
    }
    return JSON.stringify(parsed);
}
function extractJsonCandidate(rawText) {
    const trimmed = rawText.trim();
    const withoutFence = trimmed
        .replace(/^```json\s*/i, '')
        .replace(/^```\s*/i, '')
        .replace(/```$/i, '')
        .trim();
    if (withoutFence.startsWith('{') && withoutFence.endsWith('}')) {
        return withoutFence;
    }
    const first = withoutFence.indexOf('{');
    const last = withoutFence.lastIndexOf('}');
    if (first >= 0 && last > first) {
        return withoutFence.slice(first, last + 1);
    }
    throw new Error('No JSON object found in Gemini output');
}
function normalizeAnalysisJson(rawText) {
    var _a, _b, _c, _d;
    const candidate = extractJsonCandidate(rawText);
    const parsed = JSON.parse(candidate);
    return JSON.stringify({
        sentiment: normalizeLegacyTerm(String((_a = parsed['sentiment']) !== null && _a !== void 0 ? _a : '')),
        category: normalizeLegacyTerm(String((_b = parsed['category']) !== null && _b !== void 0 ? _b : '')),
        emotions: normalizeStringList(parsed['emotions']),
        characters: normalizeStringList(parsed['characters']),
        places: normalizeStringList(parsed['places']),
        themes: normalizeStringList(parsed['themes']),
        psychologicalNote: normalizeLegacyTerm(String((_c = parsed['psychologicalNote']) !== null && _c !== void 0 ? _c : '')),
        summary: normalizeLegacyTerm(String((_d = parsed['summary']) !== null && _d !== void 0 ? _d : '')),
    });
}
function buildJsonRepairPrompt(rawOutput, responseLanguage) {
    return `
You are Morfeo JSON Repair.
Convert the following model output into valid JSON only using exactly these keys:
sentiment, category, emotions, characters, places, themes, psychologicalNote, summary.

Rules:
- Output only a JSON object, no markdown.
- Keep semantic meaning from the original output.
- Output language for free-text fields: ${responseLanguage}.

Original output:
${rawOutput}
`.trim();
}
function toLogPreview(value, maxChars = 320) {
    const compact = value.replace(/\s+/g, ' ').trim();
    if (compact.length <= maxChars) {
        return compact;
    }
    return `${compact.slice(0, maxChars)}...`;
}
function buildStrictJsonAnalysisPrompt(params) {
    var _a, _b, _c;
    return `
You are Morfeo, a compassionate dream analyst.
Return ONLY one valid JSON object with exactly these keys:
sentiment, category, emotions, characters, places, themes, psychologicalNote, summary.

Rules:
- sentiment: one of positive, neutral, negative, mixed
- category: one of Adventure, Nightmare, Fantasy, Romantic, Surreal, Anxiety, Nostalgic, Spiritual, Neutral
- emotions/characters/places/themes: arrays (max 5 short strings each)
- psychologicalNote: 2-3 empathetic sentences, no diagnosis
- summary: 1-2 short sentences that summarize the dream itself, using concrete events and images from the dream text; do not summarize the interpretation or reflection
- free-text fields language: ${params.responseLanguage}
- do not include markdown, comments, or extra keys
- mood score means emotional intensity on waking, not happiness or sadness.
- mood score scale: 1 = Calm, 2 = Mild, 3 = Moderate, 4 = Intense, 5 = Extreme.

Dream title: ${params.title}
Dream text: ${params.text}
Mood score (1-5): ${(_b = (_a = params.moodScore) === null || _a === void 0 ? void 0 : _a.toString()) !== null && _b !== void 0 ? _b : 'not specified'}
Context notes: ${((_c = params.contextNotes) === null || _c === void 0 ? void 0 : _c.trim()) || 'none'}
`.trim();
}
async function runGeminiPrompt(prompt, options = {}) {
    var _a, _b;
    const genAI = new generative_ai_1.GoogleGenerativeAI(geminiApiKey.value());
    const generationConfig = {
        temperature: (_a = options.temperature) !== null && _a !== void 0 ? _a : 0.7,
        maxOutputTokens: (_b = options.maxOutputTokens) !== null && _b !== void 0 ? _b : 768,
    };
    if (options.jsonMode) {
        generationConfig.responseMimeType = 'application/json';
    }
    const model = genAI.getGenerativeModel({
        model: MODEL_NAME,
        generationConfig,
    });
    const result = await model.generateContent(prompt);
    return result.response.text();
}
async function applyFollowCounterDelta(followerId, followingId, delta) {
    if (!followerId || !followingId || followerId === followingId) {
        return;
    }
    await db.runTransaction(async (tx) => {
        const followerRef = db.collection('users').doc(followerId);
        const followingRef = db.collection('users').doc(followingId);
        const [followerSnap, followingSnap] = await Promise.all([
            tx.get(followerRef),
            tx.get(followingRef),
        ]);
        if (!followerSnap.exists || !followingSnap.exists) {
            return;
        }
        tx.update(followerRef, {
            followingCount: admin.firestore.FieldValue.increment(delta),
        });
        tx.update(followingRef, {
            followersCount: admin.firestore.FieldValue.increment(delta),
        });
    });
}
async function deleteDocsByQuery(query) {
    const snap = await query.get();
    if (snap.empty)
        return 0;
    const docs = snap.docs;
    const chunkSize = 400;
    let deleted = 0;
    for (let i = 0; i < docs.length; i += chunkSize) {
        const chunk = docs.slice(i, i + chunkSize);
        const batch = db.batch();
        for (const doc of chunk) {
            batch.delete(doc.ref);
            deleted += 1;
        }
        await batch.commit();
    }
    return deleted;
}
async function sendPushToUser({ userId, title, body, data, preferenceField, }) {
    if (!userId)
        return;
    const userSnap = await db.collection('users').doc(userId).get();
    const userData = userSnap.data();
    if (!userData)
        return;
    if (preferenceField && userData[preferenceField] === false)
        return;
    const token = userData['fcmToken'];
    if (!token)
        return;
    try {
        await admin.messaging().send({
            token,
            notification: { title, body },
            data,
            android: {
                notification: {
                    channelId: 'social_notifications',
                    priority: 'default',
                },
            },
            apns: {
                payload: {
                    aps: { sound: 'default' },
                },
            },
        });
    }
    catch (err) {
        console.error('sendPushToUser FCM error:', err);
    }
}
exports.analyzeDream = (0, https_1.onCall)({ secrets: [geminiApiKey], region: 'us-central1' }, async (request) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j;
    if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
        throw new https_1.HttpsError('unauthenticated', 'Unauthorized');
    }
    const payload = ((_b = request.data) !== null && _b !== void 0 ? _b : {});
    const title = (_d = (_c = payload.title) === null || _c === void 0 ? void 0 : _c.trim()) !== null && _d !== void 0 ? _d : '';
    const text = (_f = (_e = payload.text) === null || _e === void 0 ? void 0 : _e.trim()) !== null && _f !== void 0 ? _f : '';
    const moodScore = payload.moodScore;
    const contextNotes = payload.contextNotes;
    const responseLanguage = resolveResponseLanguage(payload.language);
    console.info('[analyzeDream] Request received', {
        uid: request.auth.uid,
        language: (_g = payload.language) !== null && _g !== void 0 ? _g : 'not_provided',
        responseLanguage,
        titleLength: title.length,
        textLength: text.length,
        contextLength: (contextNotes !== null && contextNotes !== void 0 ? contextNotes : '').trim().length,
        moodScore: moodScore !== null && moodScore !== void 0 ? moodScore : null,
    });
    if (!text) {
        throw new https_1.HttpsError('invalid-argument', 'Dream text is required for Gemini analysis.');
    }
    const prompt = ANALYSIS_PROMPT_TEMPLATE
        .replace('{responseLanguage}', responseLanguage)
        .replace('{title}', title)
        .replace('{text}', text)
        .replace('{moodScore}', (_h = moodScore === null || moodScore === void 0 ? void 0 : moodScore.toString()) !== null && _h !== void 0 ? _h : 'not specified')
        .replace('{context}', (_j = contextNotes === null || contextNotes === void 0 ? void 0 : contextNotes.trim()) !== null && _j !== void 0 ? _j : 'none');
    try {
        const rawText = await runGeminiPrompt(prompt, {
            jsonMode: true,
            temperature: 0.35,
            maxOutputTokens: 900,
        });
        console.info('[analyzeDream] Gemini first output', {
            length: rawText.length,
            preview: toLogPreview(rawText),
        });
        let normalized;
        let normalizationPath = 'first-pass';
        try {
            normalized = normalizeAnalysisJson(rawText);
        }
        catch (firstParseErr) {
            console.warn('[analyzeDream] First parse failed, retrying with strict prompt', {
                error: String(firstParseErr),
            });
            try {
                const strictPrompt = buildStrictJsonAnalysisPrompt({
                    title,
                    text,
                    moodScore,
                    contextNotes,
                    responseLanguage,
                });
                const strictRawText = await runGeminiPrompt(strictPrompt, {
                    jsonMode: true,
                    temperature: 0.2,
                    maxOutputTokens: 900,
                });
                normalizationPath = 'strict-pass';
                console.info('[analyzeDream] Gemini strict output', {
                    length: strictRawText.length,
                    preview: toLogPreview(strictRawText),
                });
                normalized = normalizeAnalysisJson(strictRawText);
            }
            catch (strictErr) {
                console.warn('[analyzeDream] Strict parse failed, retrying with repair prompt', {
                    error: String(strictErr),
                });
                const repairPrompt = buildJsonRepairPrompt(`First output:\n${rawText}\n\nStrict output:\n${String(strictErr)}`, responseLanguage);
                const repairedRawText = await runGeminiPrompt(repairPrompt, {
                    jsonMode: true,
                    temperature: 0,
                    maxOutputTokens: 900,
                });
                normalizationPath = 'repair-pass';
                console.info('[analyzeDream] Gemini repair output', {
                    length: repairedRawText.length,
                    preview: toLogPreview(repairedRawText),
                });
                normalized = normalizeAnalysisJson(repairedRawText);
                void firstParseErr;
            }
        }
        console.info('[analyzeDream] Normalized analysis ready', {
            normalizationPath,
            normalizedLength: normalized.length,
            normalizedPreview: toLogPreview(normalized),
        });
        const normalizedWithHistory = await unifyAnalysisFacetsWithHistory(request.auth.uid, normalized);
        try {
            const parsed = JSON.parse(normalizedWithHistory);
            console.info('[analyzeDream] Final response stats', {
                normalizationPath,
                sentiment: parsed.sentiment,
                category: parsed.category,
                summaryLength: parsed.summary.length,
                psychNoteLength: parsed.psychologicalNote.length,
                emotionsCount: parsed.emotions.length,
                charactersCount: parsed.characters.length,
                placesCount: parsed.places.length,
                themesCount: parsed.themes.length,
            });
        }
        catch (finalParseErr) {
            console.warn('[analyzeDream] Could not parse normalizedWithHistory for stats', {
                error: String(finalParseErr),
            });
        }
        return {
            analysisText: normalizedWithHistory,
            quality: 'high',
        };
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('analyzeDream Gemini error:', msg);
        throw new https_1.HttpsError('internal', `Gemini analyze error: ${msg}`);
    }
});
exports.transcribeAudio = (0, https_1.onCall)({ secrets: [geminiApiKey], region: 'us-central1' }, async (request) => {
    var _a, _b, _c;
    if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
        throw new https_1.HttpsError('unauthenticated', 'Unauthorized');
    }
    const payload = ((_b = request.data) !== null && _b !== void 0 ? _b : {});
    if (!payload.audioBase64) {
        throw new https_1.HttpsError('invalid-argument', 'audioBase64 is required.');
    }
    try {
        const genAI = new generative_ai_1.GoogleGenerativeAI(geminiApiKey.value());
        const model = genAI.getGenerativeModel({ model: MODEL_NAME });
        const result = await model.generateContent([
            'Transcribe the following audio recording of a person describing their dream. Output only the transcription text, nothing else.',
            {
                inlineData: {
                    data: payload.audioBase64,
                    mimeType: (_c = payload.mimeType) !== null && _c !== void 0 ? _c : 'audio/m4a',
                },
            },
        ]);
        const transcription = result.response.text().trim();
        if (!transcription) {
            throw new https_1.HttpsError('internal', 'Transcription returned an empty result.');
        }
        return { transcription };
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('transcribeAudio Gemini error:', msg);
        if (err instanceof https_1.HttpsError) {
            throw err;
        }
        throw new https_1.HttpsError('internal', `Gemini error: ${msg}`);
    }
});
exports.notifyFollowerOnDreamPublish = (0, firestore_1.onDocumentCreated)({ document: 'publicDreams/{dreamId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c, _d, _e;
    const dreamData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!dreamData)
        return;
    const authorId = (_b = dreamData['userId']) !== null && _b !== void 0 ? _b : '';
    const dreamTitle = (_c = dreamData['title']) !== null && _c !== void 0 ? _c : 'Un nuevo sueno';
    if (!authorId) {
        console.warn('notifyFollowerOnDreamPublish: missing userId in dream doc');
        return;
    }
    const fcm = admin.messaging();
    const authorSnap = await db.collection('users').doc(authorId).get();
    const authorName = (_e = (_d = authorSnap.data()) === null || _d === void 0 ? void 0 : _d['displayName']) !== null && _e !== void 0 ? _e : 'Alguien';
    const followsSnap = await db
        .collection('follows')
        .where('followingId', '==', authorId)
        .get();
    if (followsSnap.empty)
        return;
    const followerIds = followsSnap.docs.map((doc) => doc.data()['followerId']);
    const tokens = [];
    await Promise.all(followerIds.map(async (followerId) => {
        if (!followerId)
            return;
        const followerSnap = await db.collection('users').doc(followerId).get();
        const followerData = followerSnap.data();
        if (!followerData)
            return;
        const wantsNotif = followerData['notifyFollowingDreams'] !== false;
        const token = followerData['fcmToken'];
        if (wantsNotif && token) {
            tokens.push(token);
        }
    }));
    if (tokens.length === 0)
        return;
    const batchSize = 500;
    for (let index = 0; index < tokens.length; index += batchSize) {
        const batch = tokens.slice(index, index + batchSize);
        try {
            const response = await fcm.sendEachForMulticast({
                tokens: batch,
                notification: {
                    title: `${authorName} publico un sueno`,
                    body: dreamTitle,
                },
                data: {
                    type: 'new_dream',
                    authorId,
                    dreamId: event.params.dreamId,
                },
                android: {
                    notification: {
                        channelId: 'social_notifications',
                        priority: 'default',
                    },
                },
                apns: {
                    payload: {
                        aps: { sound: 'default' },
                    },
                },
            });
            const failedCount = response.responses.filter((item) => !item.success).length;
            if (failedCount > 0) {
                console.warn(`notifyFollowerOnDreamPublish: ${failedCount} messages failed in batch`);
            }
        }
        catch (err) {
            console.error('notifyFollowerOnDreamPublish FCM error:', err);
        }
    }
});
exports.incrementFollowCounters = (0, firestore_1.onDocumentCreated)({ document: 'follows/{followId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    await applyFollowCounterDelta((_b = data['followerId']) !== null && _b !== void 0 ? _b : '', (_c = data['followingId']) !== null && _c !== void 0 ? _c : '', 1);
});
exports.notifyFollowRequestCreated = (0, firestore_1.onDocumentCreated)({ document: 'followRequests/{requestId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c, _d, _e;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    const status = (_b = data['status']) !== null && _b !== void 0 ? _b : 'pending';
    if (status !== 'pending')
        return;
    const targetId = (_c = data['targetId']) !== null && _c !== void 0 ? _c : '';
    const requesterId = (_d = data['requesterId']) !== null && _d !== void 0 ? _d : '';
    const requesterName = (_e = data['requesterName']) !== null && _e !== void 0 ? _e : 'Alguien';
    await sendPushToUser({
        userId: targetId,
        title: `${requesterName} quiere seguirte`,
        body: 'Tienes una nueva solicitud de seguimiento.',
        data: {
            type: 'follow_request',
            requestId: event.params.requestId,
            requesterId,
        },
        preferenceField: 'notifyFollowRequests',
    });
});
exports.notifyNewFollower = (0, firestore_1.onDocumentCreated)({ document: 'follows/{followId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c, _d, _e;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    const followerId = (_b = data['followerId']) !== null && _b !== void 0 ? _b : '';
    const followingId = (_c = data['followingId']) !== null && _c !== void 0 ? _c : '';
    if (!followerId || !followingId || followerId === followingId)
        return;
    const followerSnap = await db.collection('users').doc(followerId).get();
    const followerName = (_e = (_d = followerSnap.data()) === null || _d === void 0 ? void 0 : _d['displayName']) !== null && _e !== void 0 ? _e : 'Alguien';
    await sendPushToUser({
        userId: followingId,
        title: `${followerName} empezó a seguirte`,
        body: 'Tienes un nuevo seguidor.',
        data: {
            type: 'new_follower',
            followerId,
            followId: event.params.followId,
        },
        preferenceField: 'notifyNewFollowers',
    });
});
exports.decrementFollowCounters = (0, firestore_1.onDocumentDeleted)({ document: 'follows/{followId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    await applyFollowCounterDelta((_b = data['followerId']) !== null && _b !== void 0 ? _b : '', (_c = data['followingId']) !== null && _c !== void 0 ? _c : '', -1);
});
exports.cleanupUserDataOnAuthDelete = functionsV1
    .region('us-central1')
    .auth
    .user()
    .onDelete(async (user) => {
    const uid = user.uid;
    console.info('[cleanupUserDataOnAuthDelete] Start', { uid });
    const userRef = db.collection('users').doc(uid);
    try {
        await db.recursiveDelete(userRef.collection('dreams'));
        await db.recursiveDelete(userRef.collection('insights'));
    }
    catch (err) {
        console.warn('[cleanupUserDataOnAuthDelete] Failed deleting subcollections', {
            uid,
            error: String(err),
        });
    }
    try {
        await deleteDocsByQuery(db.collection('usernames').where('uid', '==', uid));
        await deleteDocsByQuery(db.collection('follows').where('followerId', '==', uid));
        await deleteDocsByQuery(db.collection('follows').where('followingId', '==', uid));
        await deleteDocsByQuery(db.collection('followRequests').where('requesterId', '==', uid));
        await deleteDocsByQuery(db.collection('followRequests').where('targetId', '==', uid));
        const publicDreamsSnap = await db.collection('publicDreams').where('userId', '==', uid).get();
        for (const dreamDoc of publicDreamsSnap.docs) {
            await db.recursiveDelete(dreamDoc.ref);
        }
        await userRef.delete().catch(() => {
            return;
        });
    }
    catch (err) {
        console.error('[cleanupUserDataOnAuthDelete] Firestore cleanup error', {
            uid,
            error: String(err),
        });
    }
    try {
        await admin.storage().bucket().deleteFiles({ prefix: `users/${uid}/` });
    }
    catch (err) {
        console.warn('[cleanupUserDataOnAuthDelete] Storage cleanup warning', {
            uid,
            error: String(err),
        });
    }
    console.info('[cleanupUserDataOnAuthDelete] Completed', { uid });
});
exports.backfillFollowCounters = (0, https_1.onRequest)({ region: 'us-central1', invoker: 'public', cors: true }, async (req, res) => {
    var _a, _b, _c, _d, _e;
    if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method not allowed. Use POST.' });
        return;
    }
    const token = (_a = req.header('x-backfill-token')) !== null && _a !== void 0 ? _a : req.query['token'];
    if (token !== BACKFILL_TOKEN) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
    }
    try {
        const usersSnap = await db.collection('users').get();
        const counters = new Map();
        for (const userDoc of usersSnap.docs) {
            counters.set(userDoc.id, { followers: 0, following: 0 });
        }
        const followsSnap = await db.collection('follows').get();
        for (const followDoc of followsSnap.docs) {
            const data = followDoc.data();
            const followerId = (_b = data['followerId']) !== null && _b !== void 0 ? _b : '';
            const followingId = (_c = data['followingId']) !== null && _c !== void 0 ? _c : '';
            if (followerId && followerId !== followingId) {
                const follower = (_d = counters.get(followerId)) !== null && _d !== void 0 ? _d : { followers: 0, following: 0 };
                follower.following += 1;
                counters.set(followerId, follower);
            }
            if (followingId && followerId !== followingId) {
                const following = (_e = counters.get(followingId)) !== null && _e !== void 0 ? _e : { followers: 0, following: 0 };
                following.followers += 1;
                counters.set(followingId, following);
            }
        }
        let batch = db.batch();
        let ops = 0;
        let updatedUsers = 0;
        for (const [userId, count] of counters) {
            const userRef = db.collection('users').doc(userId);
            batch.update(userRef, {
                followersCount: count.followers,
                followingCount: count.following,
            });
            ops += 1;
            updatedUsers += 1;
            if (ops === 500) {
                await batch.commit();
                batch = db.batch();
                ops = 0;
            }
        }
        if (ops > 0) {
            await batch.commit();
        }
        res.json({
            ok: true,
            usersProcessed: usersSnap.size,
            followsProcessed: followsSnap.size,
            usersUpdated: updatedUsers,
        });
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('backfillFollowCounters error:', msg);
        res.status(500).json({ error: msg });
    }
});
//# sourceMappingURL=index.js.map
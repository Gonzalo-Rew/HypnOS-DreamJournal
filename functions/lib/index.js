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
exports.backfillFollowCounters = exports.decrementFollowCounters = exports.incrementFollowCounters = exports.notifyFollowerOnDreamPublish = exports.transcribeAudio = exports.analyzeDream = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const generative_ai_1 = require("@google/generative-ai");
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
- summary: 1-2 compassionate sentences
- Output language: {responseLanguage}

Dream title: {title}
Dream text: {text}
Mood score (1-5): {moodScore}
Context notes: {context}
`.trim();
function resolveResponseLanguage(language) {
    return (language !== null && language !== void 0 ? language : '').toLowerCase().startsWith('es') ? 'Spanish' : 'English';
}
function buildFallbackAnalysisText(responseLanguage) {
    const isSpanish = responseLanguage === 'Spanish';
    return JSON.stringify({
        sentiment: 'neutral',
        category: 'Neutral',
        emotions: isSpanish ? ['reflexion'] : ['reflection'],
        characters: isSpanish ? ['sonador'] : ['dreamer'],
        places: isSpanish ? ['escenario onirico'] : ['dream setting'],
        themes: isSpanish ? ['procesamiento'] : ['processing'],
        psychologicalNote: isSpanish
            ? 'Morfeo detecta un relato breve o insuficiente para una lectura profunda, pero aun asi percibe una necesidad de observacion tranquila y sin juicio.'
            : 'Morfeo detects a brief or insufficient dream report for a deep reading, but still senses a need for calm, non-judgmental observation.',
        summary: isSpanish
            ? 'Morfeo necesita mas detalles para ofrecer un analisis mas preciso.'
            : 'Morfeo needs more detail to provide a more precise analysis.',
    });
}
function coerceAnalysisText(rawText, responseLanguage) {
    var _a, _b, _c, _d;
    const trimmed = rawText.trim();
    if (!trimmed) {
        return buildFallbackAnalysisText(responseLanguage);
    }
    try {
        const parsed = JSON.parse(trimmed);
        return JSON.stringify({
            sentiment: String((_a = parsed['sentiment']) !== null && _a !== void 0 ? _a : 'neutral'),
            category: String((_b = parsed['category']) !== null && _b !== void 0 ? _b : 'Neutral'),
            emotions: Array.isArray(parsed['emotions']) ? parsed['emotions'] : [],
            characters: Array.isArray(parsed['characters']) ? parsed['characters'] : [],
            places: Array.isArray(parsed['places']) ? parsed['places'] : [],
            themes: Array.isArray(parsed['themes']) ? parsed['themes'] : [],
            psychologicalNote: String((_c = parsed['psychologicalNote']) !== null && _c !== void 0 ? _c : ''),
            summary: String((_d = parsed['summary']) !== null && _d !== void 0 ? _d : ''),
        });
    }
    catch (_) {
        return buildFallbackAnalysisText(responseLanguage);
    }
}
async function runGeminiPrompt(prompt) {
    const genAI = new generative_ai_1.GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({
        model: MODEL_NAME,
        generationConfig: { temperature: 0.7, maxOutputTokens: 768 },
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
exports.analyzeDream = (0, https_1.onCall)({ secrets: [geminiApiKey], region: 'us-central1' }, async (request) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
    if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
        throw new https_1.HttpsError('unauthenticated', 'Unauthorized');
    }
    const payload = ((_b = request.data) !== null && _b !== void 0 ? _b : {});
    const title = (_d = (_c = payload.title) === null || _c === void 0 ? void 0 : _c.trim()) !== null && _d !== void 0 ? _d : '';
    const text = (_f = (_e = payload.text) === null || _e === void 0 ? void 0 : _e.trim()) !== null && _f !== void 0 ? _f : '';
    const responseLanguage = resolveResponseLanguage(payload.language);
    if (!text) {
        return {
            analysisText: buildFallbackAnalysisText(responseLanguage),
        };
    }
    const prompt = ANALYSIS_PROMPT_TEMPLATE
        .replace('{responseLanguage}', responseLanguage)
        .replace('{title}', title)
        .replace('{text}', text)
        .replace('{moodScore}', (_h = (_g = payload.moodScore) === null || _g === void 0 ? void 0 : _g.toString()) !== null && _h !== void 0 ? _h : 'not specified')
        .replace('{context}', (_k = (_j = payload.contextNotes) === null || _j === void 0 ? void 0 : _j.trim()) !== null && _k !== void 0 ? _k : 'none');
    try {
        const rawText = await runGeminiPrompt(prompt);
        return {
            analysisText: coerceAnalysisText(rawText, responseLanguage),
        };
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('analyzeDream Gemini error:', msg);
        throw new https_1.HttpsError('internal', `Gemini error: ${msg}`);
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
exports.decrementFollowCounters = (0, firestore_1.onDocumentDeleted)({ document: 'follows/{followId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    await applyFollowCounterDelta((_b = data['followerId']) !== null && _b !== void 0 ? _b : '', (_c = data['followingId']) !== null && _c !== void 0 ? _c : '', -1);
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
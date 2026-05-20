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
exports.notifyFollowerOnDreamPublish = exports.transcribeAudio = exports.analyzeDream = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const generative_ai_1 = require("@google/generative-ai");
const admin = __importStar(require("firebase-admin"));
// Gemini API key stored in Firebase Secret Manager.
// Set it once with: firebase functions:secrets:set GEMINI_API_KEY
const geminiApiKey = (0, params_1.defineSecret)('GEMINI_API_KEY');
const MODEL_NAME = 'gemini-2.5-flash';
if (admin.apps.length === 0) {
    admin.initializeApp();
}
const ANALYSIS_PROMPT_TEMPLATE = `
You are a compassionate dream analyst. Analyze the following dream entry and respond in EXACTLY this format (no extra text):

SENTIMENT: [positive/neutral/negative/mixed]
CATEGORY: [one of: Adventure, Nightmare, Fantasy, Romantic, Surreal, Anxiety, Nostalgic, Spiritual, Neutral]
EMOTIONS: [comma-separated list of up to 5 emotions detected, e.g.: joy, fear, confusion]
CHARACTERS: [comma-separated list of up to 5 characters/entities, e.g.: unknown figure, childhood friend]
PLACES: [comma-separated list of up to 3 places, e.g.: forest, old house]
THEMES: [comma-separated list of up to 4 recurring themes, e.g.: pursuit, transformation, loss]
PSYCHOLOGICAL_NOTE: [2-3 sentences of empathetic psychological insight, no diagnosis]
SUMMARY: [1-2 sentence compassionate summary of the dream]

Dream title: {title}
Dream text: {text}
Mood score (1-5): {moodScore}
Context: {context}
`.trim();
// Validates the Firebase Auth Bearer token and returns the uid, or null.
async function verifyAuth(authHeader) {
    if (!(authHeader === null || authHeader === void 0 ? void 0 : authHeader.startsWith('Bearer ')))
        return null;
    try {
        const decoded = await admin.auth().verifyIdToken(authHeader.slice(7));
        return decoded.uid;
    }
    catch (_a) {
        return null;
    }
}
// ── analyzeDream ─────────────────────────────────────────────────────────────
// HTTP function: analyses a dream text with Gemini.
// Auth: Firebase ID token in Authorization: Bearer header.
exports.analyzeDream = (0, https_1.onRequest)({ secrets: [geminiApiKey], region: 'us-central1', invoker: 'public', cors: true }, async (req, res) => {
    var _a;
    const uid = await verifyAuth(req.headers.authorization);
    if (!uid) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
    }
    const { title, text, moodScore, contextNotes } = req.body;
    if (!(text === null || text === void 0 ? void 0 : text.trim())) {
        res.status(400).json({ error: 'Dream text is required.' });
        return;
    }
    const prompt = ANALYSIS_PROMPT_TEMPLATE
        .replace('{title}', title !== null && title !== void 0 ? title : '')
        .replace('{text}', text.trim())
        .replace('{moodScore}', (_a = moodScore === null || moodScore === void 0 ? void 0 : moodScore.toString()) !== null && _a !== void 0 ? _a : 'not specified')
        .replace('{context}', contextNotes !== null && contextNotes !== void 0 ? contextNotes : 'none');
    try {
        const genAI = new generative_ai_1.GoogleGenerativeAI(geminiApiKey.value());
        const model = genAI.getGenerativeModel({
            model: MODEL_NAME,
            generationConfig: { temperature: 0.7, maxOutputTokens: 512 },
        });
        const result = await model.generateContent(prompt);
        const analysisText = result.response.text();
        if (!analysisText) {
            res.status(500).json({ error: 'Gemini returned an empty response.' });
            return;
        }
        res.json({ analysisText });
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('analyzeDream Gemini error:', msg);
        res.status(500).json({ error: `Gemini error: ${msg}` });
    }
});
// ── transcribeAudio ───────────────────────────────────────────────────────────
// HTTP function: transcribes base64-encoded audio with Gemini multimodal.
// Auth: Firebase ID token in Authorization: Bearer header.
exports.transcribeAudio = (0, https_1.onRequest)({ secrets: [geminiApiKey], region: 'us-central1', invoker: 'public', cors: true }, async (req, res) => {
    const uid = await verifyAuth(req.headers.authorization);
    if (!uid) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
    }
    const { audioBase64, mimeType } = req.body;
    if (!audioBase64) {
        res.status(400).json({ error: 'audioBase64 is required.' });
        return;
    }
    try {
        const genAI = new generative_ai_1.GoogleGenerativeAI(geminiApiKey.value());
        const model = genAI.getGenerativeModel({ model: MODEL_NAME });
        const result = await model.generateContent([
            'Transcribe the following audio recording of a person describing their dream. '
                + 'Output only the transcription text, nothing else.',
            {
                inlineData: {
                    data: audioBase64,
                    mimeType: mimeType !== null && mimeType !== void 0 ? mimeType : 'audio/m4a',
                },
            },
        ]);
        const transcription = result.response.text();
        if (!transcription) {
            res.status(500).json({ error: 'Transcription returned an empty result.' });
            return;
        }
        res.json({ transcription });
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error('transcribeAudio Gemini error:', msg);
        res.status(500).json({ error: `Gemini error: ${msg}` });
    }
});
// ── notifyFollowerOnDreamPublish ──────────────────────────────────────────────
// Firestore trigger: fires when a new document is created in publicDreams.
// Reads the author's followers and sends FCM push notifications to those who
// have notifyFollowingDreams = true and have a valid fcmToken.
exports.notifyFollowerOnDreamPublish = (0, firestore_1.onDocumentCreated)({ document: 'publicDreams/{dreamId}', region: 'us-central1' }, async (event) => {
    var _a, _b, _c, _d, _e;
    const dreamData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!dreamData)
        return;
    const authorId = (_b = dreamData['userId']) !== null && _b !== void 0 ? _b : '';
    const dreamTitle = (_c = dreamData['title']) !== null && _c !== void 0 ? _c : 'Un nuevo sueño';
    if (!authorId) {
        console.warn('notifyFollowerOnDreamPublish: missing userId in dream doc');
        return;
    }
    const db = admin.firestore();
    const fcm = admin.messaging();
    // 1. Get the author's display name
    const authorSnap = await db.collection('users').doc(authorId).get();
    const authorName = (_e = (_d = authorSnap.data()) === null || _d === void 0 ? void 0 : _d['displayName']) !== null && _e !== void 0 ? _e : 'Alguien';
    // 2. Get all followers of the author (followingId == authorId)
    const followsSnap = await db
        .collection('follows')
        .where('followingId', '==', authorId)
        .get();
    if (followsSnap.empty)
        return;
    const followerIds = followsSnap.docs.map((d) => d.data()['followerId']);
    // 3. For each follower, check their notification preference and FCM token
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
    // 4. Send FCM notifications in batches of 500
    const batchSize = 500;
    for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        try {
            const response = await fcm.sendEachForMulticast({
                tokens: batch,
                notification: {
                    title: `${authorName} publicó un sueño`,
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
            const failed = response.responses.filter((r) => !r.success).length;
            if (failed > 0) {
                console.warn(`notifyFollowerOnDreamPublish: ${failed} messages failed in batch`);
            }
        }
        catch (err) {
            console.error('notifyFollowerOnDreamPublish FCM error:', err);
        }
    }
});
//# sourceMappingURL=index.js.map
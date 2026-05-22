import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
import {
  onDocumentCreated,
  onDocumentDeleted,
} from 'firebase-functions/v2/firestore';
import { defineSecret } from 'firebase-functions/params';
import { GoogleGenerativeAI } from '@google/generative-ai';
import * as admin from 'firebase-admin';

const geminiApiKey = defineSecret('GEMINI_API_KEY');
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

type AnalysisPayload = {
  title?: string;
  text?: string;
  moodScore?: number;
  contextNotes?: string;
  language?: string;
};

function resolveResponseLanguage(language?: string): string {
  return (language ?? '').toLowerCase().startsWith('es') ? 'Spanish' : 'English';
}

function buildFallbackAnalysisText(responseLanguage: string): string {
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

function coerceAnalysisText(rawText: string, responseLanguage: string): string {
  const trimmed = rawText.trim();
  if (!trimmed) {
    return buildFallbackAnalysisText(responseLanguage);
  }

  try {
    const parsed = JSON.parse(trimmed) as Record<string, unknown>;
    return JSON.stringify({
      sentiment: String(parsed['sentiment'] ?? 'neutral'),
      category: String(parsed['category'] ?? 'Neutral'),
      emotions: Array.isArray(parsed['emotions']) ? parsed['emotions'] : [],
      characters: Array.isArray(parsed['characters']) ? parsed['characters'] : [],
      places: Array.isArray(parsed['places']) ? parsed['places'] : [],
      themes: Array.isArray(parsed['themes']) ? parsed['themes'] : [],
      psychologicalNote: String(parsed['psychologicalNote'] ?? ''),
      summary: String(parsed['summary'] ?? ''),
    });
  } catch (_) {
    return buildFallbackAnalysisText(responseLanguage);
  }
}

async function runGeminiPrompt(prompt: string): Promise<string> {
  const genAI = new GoogleGenerativeAI(geminiApiKey.value());
  const model = genAI.getGenerativeModel({
    model: MODEL_NAME,
    generationConfig: { temperature: 0.7, maxOutputTokens: 768 },
  });

  const result = await model.generateContent(prompt);
  return result.response.text();
}

async function applyFollowCounterDelta(
  followerId: string,
  followingId: string,
  delta: number,
): Promise<void> {
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

export const analyzeDream = onCall(
  { secrets: [geminiApiKey], region: 'us-central1' },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Unauthorized');
    }

    const payload = (request.data ?? {}) as AnalysisPayload;
    const title = payload.title?.trim() ?? '';
    const text = payload.text?.trim() ?? '';
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
      .replace('{moodScore}', payload.moodScore?.toString() ?? 'not specified')
      .replace('{context}', payload.contextNotes?.trim() ?? 'none');

    try {
      const rawText = await runGeminiPrompt(prompt);
      return {
        analysisText: coerceAnalysisText(rawText, responseLanguage),
      };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error('analyzeDream Gemini error:', msg);
      throw new HttpsError('internal', `Gemini error: ${msg}`);
    }
  },
);

export const transcribeAudio = onCall(
  { secrets: [geminiApiKey], region: 'us-central1' },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Unauthorized');
    }

    const payload = (request.data ?? {}) as {
      audioBase64?: string;
      mimeType?: string;
    };

    if (!payload.audioBase64) {
      throw new HttpsError('invalid-argument', 'audioBase64 is required.');
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({ model: MODEL_NAME });

      const result = await model.generateContent([
        'Transcribe the following audio recording of a person describing their dream. Output only the transcription text, nothing else.',
        {
          inlineData: {
            data: payload.audioBase64,
            mimeType: payload.mimeType ?? 'audio/m4a',
          },
        },
      ]);

      const transcription = result.response.text().trim();
      if (!transcription) {
        throw new HttpsError('internal', 'Transcription returned an empty result.');
      }

      return { transcription };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error('transcribeAudio Gemini error:', msg);
      if (err instanceof HttpsError) {
        throw err;
      }
      throw new HttpsError('internal', `Gemini error: ${msg}`);
    }
  },
);

export const notifyFollowerOnDreamPublish = onDocumentCreated(
  { document: 'publicDreams/{dreamId}', region: 'us-central1' },
  async (event) => {
    const dreamData = event.data?.data();
    if (!dreamData) return;

    const authorId: string = dreamData['userId'] ?? '';
    const dreamTitle: string = dreamData['title'] ?? 'Un nuevo sueno';

    if (!authorId) {
      console.warn('notifyFollowerOnDreamPublish: missing userId in dream doc');
      return;
    }

    const fcm = admin.messaging();
    const authorSnap = await db.collection('users').doc(authorId).get();
    const authorName: string = authorSnap.data()?.['displayName'] ?? 'Alguien';

    const followsSnap = await db
      .collection('follows')
      .where('followingId', '==', authorId)
      .get();

    if (followsSnap.empty) return;

    const followerIds = followsSnap.docs.map((doc) => doc.data()['followerId'] as string);
    const tokens: string[] = [];

    await Promise.all(
      followerIds.map(async (followerId) => {
        if (!followerId) return;
        const followerSnap = await db.collection('users').doc(followerId).get();
        const followerData = followerSnap.data();
        if (!followerData) return;

        const wantsNotif = followerData['notifyFollowingDreams'] !== false;
        const token = followerData['fcmToken'] as string | undefined;
        if (wantsNotif && token) {
          tokens.push(token);
        }
      }),
    );

    if (tokens.length === 0) return;

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
      } catch (err) {
        console.error('notifyFollowerOnDreamPublish FCM error:', err);
      }
    }
  },
);

export const incrementFollowCounters = onDocumentCreated(
  { document: 'follows/{followId}', region: 'us-central1' },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    await applyFollowCounterDelta(
      data['followerId'] ?? '',
      data['followingId'] ?? '',
      1,
    );
  },
);

export const decrementFollowCounters = onDocumentDeleted(
  { document: 'follows/{followId}', region: 'us-central1' },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    await applyFollowCounterDelta(
      data['followerId'] ?? '',
      data['followingId'] ?? '',
      -1,
    );
  },
);

export const backfillFollowCounters = onRequest(
  { region: 'us-central1', invoker: 'public', cors: true },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed. Use POST.' });
      return;
    }

    const token = req.header('x-backfill-token') ?? req.query['token'];
    if (token !== BACKFILL_TOKEN) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    try {
      const usersSnap = await db.collection('users').get();
      const counters = new Map<string, { followers: number; following: number }>();

      for (const userDoc of usersSnap.docs) {
        counters.set(userDoc.id, { followers: 0, following: 0 });
      }

      const followsSnap = await db.collection('follows').get();
      for (const followDoc of followsSnap.docs) {
        const data = followDoc.data();
        const followerId = (data['followerId'] as string | undefined) ?? '';
        const followingId = (data['followingId'] as string | undefined) ?? '';

        if (followerId && followerId !== followingId) {
          const follower = counters.get(followerId) ?? { followers: 0, following: 0 };
          follower.following += 1;
          counters.set(followerId, follower);
        }

        if (followingId && followerId !== followingId) {
          const following = counters.get(followingId) ?? { followers: 0, following: 0 };
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
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error('backfillFollowCounters error:', msg);
      res.status(500).json({ error: msg });
    }
  },
);

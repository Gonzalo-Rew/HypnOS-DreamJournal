import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
import {
  onDocumentCreated,
  onDocumentDeleted,
} from 'firebase-functions/v2/firestore';
import { defineSecret } from 'firebase-functions/params';
import { GoogleGenerativeAI } from '@google/generative-ai';
import * as functionsV1 from 'firebase-functions/v1';
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

type AnalysisPayload = {
  title?: string;
  text?: string;
  moodScore?: number;
  contextNotes?: string;
  language?: string;
};

type DreamAnalysisResult = {
  sentiment: string;
  category: string;
  emotions: string[];
  characters: string[];
  places: string[];
  themes: string[];
  psychologicalNote: string;
  summary: string;
};

const FACETS_TO_UNIFY = ['emotions', 'characters', 'places', 'themes'] as const;
type FacetToUnify = (typeof FACETS_TO_UNIFY)[number];

const HISTORY_DREAMS_LIMIT = 100;

const FACET_SYNONYM_GROUPS: string[][] = [
  ['sonador', 'soñador', 'dreamer'],
  ['casa', 'hogar', 'home'],
  ['miedo', 'temor', 'fear'],
  ['ansiedad', 'angustia', 'anxiety'],
  ['trabajo', 'oficina', 'office', 'work'],
];

const FACET_SYNONYM_INDEX = buildFacetSynonymIndex(FACET_SYNONYM_GROUPS);

function buildFacetSynonymIndex(groups: string[][]): Map<string, string[]> {
  const index = new Map<string, string[]>();

  for (const group of groups) {
    const normalizedGroup = Array.from(
      new Set(group.map((item) => normalizeLabelForMatching(item)).filter((item) => item.length > 0)),
    );

    for (const normalizedItem of normalizedGroup) {
      const alternatives = normalizedGroup.filter((candidate) => candidate !== normalizedItem);
      index.set(normalizedItem, alternatives);
    }
  }

  return index;
}

function resolveResponseLanguage(language?: string): string {
  return (language ?? '').toLowerCase().startsWith('es') ? 'Spanish' : 'English';
}

function normalizeLegacyTerm(value: string): string {
  return value.replace(/\bsonador\b/gi, 'soñador');
}

function normalizeStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  return value
    .map((item) => normalizeLegacyTerm(String(item ?? '').trim()))
    .filter((item) => item.length > 0);
}

function normalizeLabelForMatching(value: string): string {
  return normalizeLegacyTerm(value)
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, ' ');
}

function getSimplePluralSingularVariants(normalizedLabel: string): string[] {
  if (!normalizedLabel) return [];

  if (normalizedLabel.endsWith('s') && normalizedLabel.length > 1) {
    return [normalizedLabel.slice(0, -1)];
  }

  return [`${normalizedLabel}s`];
}

function getFacetSynonymVariants(normalizedLabel: string): string[] {
  return FACET_SYNONYM_INDEX.get(normalizedLabel) ?? [];
}

function buildFacetMatchKeys(label: string): string[] {
  const normalized = normalizeLabelForMatching(label);
  if (!normalized) return [];

  const allKeys = new Set<string>([normalized]);
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

function parseAnalysisObject(value: unknown): Record<string, unknown> | null {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }

  if (typeof value !== 'string') {
    return null;
  }

  try {
    const parsed = JSON.parse(value) as unknown;
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed as Record<string, unknown>;
    }
  } catch (_err) {
    return null;
  }

  return null;
}

function extractAnalysesFromDreamData(dreamData: Record<string, unknown>): Record<string, unknown>[] {
  const analyses: Record<string, unknown>[] = [];

  const aiAnalysis = parseAnalysisObject(dreamData['aiAnalysis']);
  if (aiAnalysis) {
    analyses.push(aiAnalysis);
  }

  const aiAnalysisByLanguage = dreamData['aiAnalysisByLanguage'];
  if (aiAnalysisByLanguage && typeof aiAnalysisByLanguage === 'object' && !Array.isArray(aiAnalysisByLanguage)) {
    for (const value of Object.values(aiAnalysisByLanguage as Record<string, unknown>)) {
      const parsed = parseAnalysisObject(value);
      if (parsed) {
        analyses.push(parsed);
      }
    }
  }

  return analyses;
}

function dedupeLabelsPreservingOrder(labels: string[]): string[] {
  const seen = new Set<string>();
  const output: string[] = [];

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

function resolveCanonicalLabel(label: string, inventory: Map<string, string>): string {
  for (const key of buildFacetMatchKeys(label)) {
    const matched = inventory.get(key);
    if (matched) {
      return matched;
    }
  }

  return label;
}

async function buildHistoricalFacetInventory(
  uid: string,
): Promise<Record<FacetToUnify, Map<string, string>>> {
  const inventory: Record<FacetToUnify, Map<string, string>> = {
    emotions: new Map<string, string>(),
    characters: new Map<string, string>(),
    places: new Map<string, string>(),
    themes: new Map<string, string>(),
  };

  const dreamsSnap = await db
    .collection('users')
    .doc(uid)
    .collection('dreams')
    .orderBy('createdAt', 'desc')
    .limit(HISTORY_DREAMS_LIMIT)
    .get();

  for (const dreamDoc of dreamsSnap.docs) {
    const dreamData = dreamDoc.data() as Record<string, unknown>;
    const analyses = extractAnalysesFromDreamData(dreamData);

    for (const analysis of analyses) {
      for (const facet of FACETS_TO_UNIFY) {
        const labels = normalizeStringList(analysis[facet]);
        for (const label of labels) {
          const canonical = label.trim();
          if (!canonical) continue;

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

async function unifyAnalysisFacetsWithHistory(
  uid: string,
  normalizedAnalysisJson: string,
): Promise<string> {
  const parsed = JSON.parse(normalizedAnalysisJson) as DreamAnalysisResult;
  const inventory = await buildHistoricalFacetInventory(uid);

  for (const facet of FACETS_TO_UNIFY) {
    const labels = normalizeStringList(parsed[facet]);
    const unifiedLabels = labels.map((label) => resolveCanonicalLabel(label, inventory[facet]));
    parsed[facet] = dedupeLabelsPreservingOrder(unifiedLabels);
  }

  return JSON.stringify(parsed);
}

function extractJsonCandidate(rawText: string): string {
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

function normalizeAnalysisJson(rawText: string): string {
  const candidate = extractJsonCandidate(rawText);
  const parsed = JSON.parse(candidate) as Record<string, unknown>;

  return JSON.stringify({
    sentiment: normalizeLegacyTerm(String(parsed['sentiment'] ?? '')),
    category: normalizeLegacyTerm(String(parsed['category'] ?? '')),
    emotions: normalizeStringList(parsed['emotions']),
    characters: normalizeStringList(parsed['characters']),
    places: normalizeStringList(parsed['places']),
    themes: normalizeStringList(parsed['themes']),
    psychologicalNote: normalizeLegacyTerm(String(parsed['psychologicalNote'] ?? '')),
    summary: normalizeLegacyTerm(String(parsed['summary'] ?? '')),
  });
}

function buildJsonRepairPrompt(rawOutput: string, responseLanguage: string): string {
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

function toLogPreview(value: string, maxChars = 320): string {
  const compact = value.replace(/\s+/g, ' ').trim();
  if (compact.length <= maxChars) {
    return compact;
  }
  return `${compact.slice(0, maxChars)}...`;
}

function buildStrictJsonAnalysisPrompt(params: {
  title: string;
  text: string;
  moodScore?: number;
  contextNotes?: string;
  responseLanguage: string;
}): string {
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
Mood score (1-5): ${params.moodScore?.toString() ?? 'not specified'}
Context notes: ${params.contextNotes?.trim() || 'none'}
`.trim();
}

async function runGeminiPrompt(
  prompt: string,
  options: { jsonMode?: boolean; temperature?: number; maxOutputTokens?: number } = {},
): Promise<string> {
  const genAI = new GoogleGenerativeAI(geminiApiKey.value());
  const generationConfig: {
    temperature: number;
    maxOutputTokens: number;
    responseMimeType?: string;
  } = {
    temperature: options.temperature ?? 0.7,
    maxOutputTokens: options.maxOutputTokens ?? 768,
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

async function deleteDocsByQuery(
  query: FirebaseFirestore.Query<FirebaseFirestore.DocumentData>,
): Promise<number> {
  const snap = await query.get();
  if (snap.empty) return 0;

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

async function sendPushToUser({
  userId,
  title,
  body,
  data,
  preferenceField,
}: {
  userId: string;
  title: string;
  body: string;
  data: Record<string, string>;
  preferenceField?: 'notifyFollowRequests' | 'notifyNewFollowers' | 'notifyFollowingDreams';
}): Promise<void> {
  if (!userId) return;

  const userSnap = await db.collection('users').doc(userId).get();
  const userData = userSnap.data();
  if (!userData) return;

  if (preferenceField && userData[preferenceField] === false) return;

  const token = userData['fcmToken'] as string | undefined;
  if (!token) return;

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
  } catch (err) {
    console.error('sendPushToUser FCM error:', err);
  }
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
    const moodScore = payload.moodScore;
    const contextNotes = payload.contextNotes;
    const responseLanguage = resolveResponseLanguage(payload.language);

    console.info('[analyzeDream] Request received', {
      uid: request.auth.uid,
      language: payload.language ?? 'not_provided',
      responseLanguage,
      titleLength: title.length,
      textLength: text.length,
      contextLength: (contextNotes ?? '').trim().length,
      moodScore: moodScore ?? null,
    });

    if (!text) {
      throw new HttpsError('invalid-argument', 'Dream text is required for Gemini analysis.');
    }

    const prompt = ANALYSIS_PROMPT_TEMPLATE
      .replace('{responseLanguage}', responseLanguage)
      .replace('{title}', title)
      .replace('{text}', text)
      .replace('{moodScore}', moodScore?.toString() ?? 'not specified')
      .replace('{context}', contextNotes?.trim() ?? 'none');

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

      let normalized: string;
      let normalizationPath: 'first-pass' | 'strict-pass' | 'repair-pass' = 'first-pass';

      try {
        normalized = normalizeAnalysisJson(rawText);
      } catch (firstParseErr) {
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
        } catch (strictErr) {
          console.warn('[analyzeDream] Strict parse failed, retrying with repair prompt', {
            error: String(strictErr),
          });
          const repairPrompt = buildJsonRepairPrompt(
            `First output:\n${rawText}\n\nStrict output:\n${String(strictErr)}`,
            responseLanguage,
          );
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

      const normalizedWithHistory = await unifyAnalysisFacetsWithHistory(
        request.auth.uid,
        normalized,
      );

      try {
        const parsed = JSON.parse(normalizedWithHistory) as DreamAnalysisResult;
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
      } catch (finalParseErr) {
        console.warn('[analyzeDream] Could not parse normalizedWithHistory for stats', {
          error: String(finalParseErr),
        });
      }

      return {
        analysisText: normalizedWithHistory,
        quality: 'high',
      };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error('analyzeDream Gemini error:', msg);
      throw new HttpsError('internal', `Gemini analyze error: ${msg}`);
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

export const notifyFollowRequestCreated = onDocumentCreated(
  { document: 'followRequests/{requestId}', region: 'us-central1' },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const status = (data['status'] as string | undefined) ?? 'pending';
    if (status !== 'pending') return;

    const targetId = (data['targetId'] as string | undefined) ?? '';
    const requesterId = (data['requesterId'] as string | undefined) ?? '';
    const requesterName = (data['requesterName'] as string | undefined) ?? 'Alguien';

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
  },
);

export const notifyNewFollower = onDocumentCreated(
  { document: 'follows/{followId}', region: 'us-central1' },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const followerId = (data['followerId'] as string | undefined) ?? '';
    const followingId = (data['followingId'] as string | undefined) ?? '';
    if (!followerId || !followingId || followerId === followingId) return;

    const followerSnap = await db.collection('users').doc(followerId).get();
    const followerName = (followerSnap.data()?.['displayName'] as string | undefined) ?? 'Alguien';

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

export const cleanupUserDataOnAuthDelete = functionsV1
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
    } catch (err) {
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
    } catch (err) {
      console.error('[cleanupUserDataOnAuthDelete] Firestore cleanup error', {
        uid,
        error: String(err),
      });
    }

    try {
      await admin.storage().bucket().deleteFiles({ prefix: `users/${uid}/` });
    } catch (err) {
      console.warn('[cleanupUserDataOnAuthDelete] Storage cleanup warning', {
        uid,
        error: String(err),
      });
    }

    console.info('[cleanupUserDataOnAuthDelete] Completed', { uid });
  });

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

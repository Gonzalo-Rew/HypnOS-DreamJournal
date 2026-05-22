import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';

// Helper that mimics a Firestore Timestamp so tests don't require a live SDK.
class _FakeTs {
  _FakeTs(this._dt);
  final DateTime _dt;
  DateTime toDate() => _dt;
}

void main() {
  final jan1 = DateTime(2025, 1, 1);
  final jan2 = DateTime(2025, 1, 2);
  final jan3 = DateTime(2025, 1, 3);

  Map<String, dynamic> _fullData() => {
    'title': 'Flying over the ocean',
    'text': 'I was flying...',
    'dreamDate': _FakeTs(jan1),
    'createdAt': _FakeTs(jan2),
    'updatedAt': _FakeTs(jan3),
    'moodScore': 8,
    'tags': ['lucid', 'flying', 'mood:happy'],
    'contextNotes': 'Slept early',
    'aiCategory': 'Adventure',
    'audioPaths': ['gs://bucket/audio1.aac'],
    'transcription': 'I was flying over the ocean',
    'aiSummary': 'An adventure dream',
    'aiAnalysis': {
      'emotions': ['joy'],
    },
    'isPublished': true,
    'visibility': 'public',
    'likesCount': 5,
    'commentsCount': 2,
  };

  // ── fromFirestore ──────────────────────────────────────────────────────────

  group('Dream.fromFirestore – full data', () {
    late Dream dream;
    setUp(
      () => dream = Dream.fromFirestore(_fullData(), 'dream-01', 'user-01'),
    );

    test('id and userId are set', () {
      expect(dream.id, 'dream-01');
      expect(dream.userId, 'user-01');
    });

    test('title and text', () {
      expect(dream.title, 'Flying over the ocean');
      expect(dream.text, 'I was flying...');
    });

    test('dreamDate is parsed from fake timestamp', () {
      expect(dream.dreamDate, jan1);
    });

    test('createdAt / updatedAt are parsed', () {
      expect(dream.createdAt, jan2);
      expect(dream.updatedAt, jan3);
    });

    test('moodScore', () => expect(dream.moodScore, 8));

    test('tags list is preserved', () {
      expect(dream.tags, ['lucid', 'flying', 'mood:happy']);
    });

    test('contextNotes', () => expect(dream.contextNotes, 'Slept early'));
    test('aiCategory', () => expect(dream.aiCategory, 'Adventure'));

    test('audioPaths list', () {
      expect(dream.audioPaths, ['gs://bucket/audio1.aac']);
    });

    test('transcription', () {
      expect(dream.transcription, 'I was flying over the ocean');
    });

    test('aiSummary', () => expect(dream.aiSummary, 'An adventure dream'));

    test('aiAnalysis map', () {
      expect(dream.aiAnalysis, {
        'emotions': ['joy'],
      });
    });

    test('isPublished = true', () => expect(dream.isPublished, isTrue));
    test('visibility = public', () {
      expect(dream.visibility, DreamVisibility.public);
    });
    test('likesCount = 5', () => expect(dream.likesCount, 5));
    test('commentsCount = 2', () => expect(dream.commentsCount, 2));
  });

  group('Dream.fromFirestore – defaults when fields are null/missing', () {
    late Dream dream;
    setUp(() => dream = Dream.fromFirestore({}, 'id', 'uid'));

    test('title defaults to empty string', () => expect(dream.title, ''));
    test('text defaults to empty string', () => expect(dream.text, ''));
    test('moodScore defaults to null', () => expect(dream.moodScore, isNull));
    test('tags defaults to empty list', () => expect(dream.tags, isEmpty));
    test('contextNotes defaults to null', () {
      expect(dream.contextNotes, isNull);
    });
    test('aiCategory defaults to null', () => expect(dream.aiCategory, isNull));
    test(
      'audioPaths defaults to empty',
      () => expect(dream.audioPaths, isEmpty),
    );
    test(
      'isPublished defaults to false',
      () => expect(dream.isPublished, isFalse),
    );
    test('visibility defaults to private', () {
      expect(dream.visibility, DreamVisibility.private);
    });
    test('likesCount defaults to 0', () => expect(dream.likesCount, 0));
    test('commentsCount defaults to 0', () => expect(dream.commentsCount, 0));
  });

  group('Dream._visibilityFromString', () {
    Dream _parse(String? v) => Dream.fromFirestore({'visibility': v}, 'x', 'u');

    test('"public" → DreamVisibility.public', () {
      expect(_parse('public').visibility, DreamVisibility.public);
    });

    test('"followers" → DreamVisibility.followers', () {
      expect(_parse('followers').visibility, DreamVisibility.followers);
    });

    test('"private" → DreamVisibility.private', () {
      expect(_parse('private').visibility, DreamVisibility.private);
    });

    test('null → DreamVisibility.private', () {
      expect(_parse(null).visibility, DreamVisibility.private);
    });

    test('unknown string → DreamVisibility.private', () {
      expect(_parse('unknown').visibility, DreamVisibility.private);
    });
  });

  group('Dream._readAudioPaths (legacy audioPath fallback)', () {
    test('uses audioPaths list when present and non-empty', () {
      final d = Dream.fromFirestore(
        {
          'audioPaths': ['a.aac', 'b.aac'],
        },
        'x',
        'u',
      );
      expect(d.audioPaths, ['a.aac', 'b.aac']);
    });

    test('falls back to legacy audioPath when audioPaths is empty', () {
      final d = Dream.fromFirestore(
        {'audioPaths': [], 'audioPath': 'legacy.aac'},
        'x',
        'u',
      );
      expect(d.audioPaths, ['legacy.aac']);
    });

    test('falls back to legacy audioPath when audioPaths is missing', () {
      final d = Dream.fromFirestore({'audioPath': 'legacy.aac'}, 'x', 'u');
      expect(d.audioPaths, ['legacy.aac']);
    });

    test('returns empty list when both are absent', () {
      final d = Dream.fromFirestore({}, 'x', 'u');
      expect(d.audioPaths, isEmpty);
    });
  });

  // ── hasAudio getter ────────────────────────────────────────────────────────

  group('Dream.hasAudio', () {
    test('true when audioPaths is non-empty', () {
      final d = Dream.fromFirestore(
        {
          'audioPaths': ['audio.aac'],
        },
        'x',
        'u',
      );
      expect(d.hasAudio, isTrue);
    });

    test('false when audioPaths is empty', () {
      final d = Dream.fromFirestore({}, 'x', 'u');
      expect(d.hasAudio, isFalse);
    });
  });

  // ── toFirestore ────────────────────────────────────────────────────────────

  group('Dream.toFirestore', () {
    late Map<String, dynamic> map;
    setUp(() {
      map = Dream(
        id: 'd1',
        userId: 'u1',
        title: 'Test dream',
        text: 'Some text',
        dreamDate: jan1,
        createdAt: jan2,
        updatedAt: jan3,
        tags: ['flying'],
        moodScore: 7,
        isPublished: true,
        visibility: DreamVisibility.followers,
        likesCount: 3,
        commentsCount: 1,
      ).toFirestore();
    });

    test('includes title', () => expect(map['title'], 'Test dream'));
    test('includes text', () => expect(map['text'], 'Some text'));
    test('includes dreamDate', () => expect(map['dreamDate'], jan1));
    test('includes tags', () => expect(map['tags'], ['flying']));
    test('includes moodScore', () => expect(map['moodScore'], 7));
    test('includes isPublished', () => expect(map['isPublished'], isTrue));
    test('includes visibility name', () {
      expect(map['visibility'], 'followers');
    });
    test('includes hasAudio = false', () => expect(map['hasAudio'], isFalse));
    test('includes likesCount', () => expect(map['likesCount'], 3));
    test('includes commentsCount', () => expect(map['commentsCount'], 1));
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  group('Dream.copyWith', () {
    late Dream original;
    setUp(() {
      original = Dream(
        id: 'd1',
        userId: 'u1',
        title: 'Original',
        text: 'Old text',
        dreamDate: jan1,
        createdAt: jan1,
        updatedAt: jan1,
        tags: const [],
        moodScore: 5,
        isPublished: false,
        visibility: DreamVisibility.private,
      );
    });

    test('changing title leaves other fields untouched', () {
      final copy = original.copyWith(title: 'New title');
      expect(copy.title, 'New title');
      expect(copy.text, 'Old text');
      expect(copy.id, 'd1');
    });

    test('changing visibility', () {
      final copy = original.copyWith(visibility: DreamVisibility.public);
      expect(copy.visibility, DreamVisibility.public);
      expect(original.visibility, DreamVisibility.private);
    });

    test('changing isPublished', () {
      final copy = original.copyWith(isPublished: true);
      expect(copy.isPublished, isTrue);
    });

    test('changing moodScore', () {
      final copy = original.copyWith(moodScore: 10);
      expect(copy.moodScore, 10);
    });

    test('no-arg copyWith returns equivalent dream', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.title, original.title);
    });
  });

  // ── DreamVisibility enum ───────────────────────────────────────────────────

  group('DreamVisibility', () {
    test('has three values', () {
      expect(DreamVisibility.values.length, 3);
    });

    test('.name returns the identifier', () {
      expect(DreamVisibility.public.name, 'public');
      expect(DreamVisibility.followers.name, 'followers');
      expect(DreamVisibility.private.name, 'private');
    });
  });
}

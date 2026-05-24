import 'package:hypnos_dreamjournal/data/services/gemini_service.dart';

class AnalysisLanguageUtils {
  static String normalizeLocaleCode(String localeCode) {
    final code = localeCode.toLowerCase();
    return code.startsWith('es') ? 'es' : 'en';
  }

  static DreamAnalysis coerceToLocale({
    required DreamAnalysis analysis,
    required String localeCode,
    required String dreamText,
  }) {
    final normalizedAnalysis = _normalizeLegacyTerms(analysis);
    final normalizedLocale = normalizeLocaleCode(localeCode);
    final wantsSpanish = normalizedLocale == 'es';

    if (wantsSpanish && _looksEnglish(normalizedAnalysis)) {
      return _buildHeuristicAnalysis(dreamText, isSpanish: true);
    }

    if (!wantsSpanish && _looksSpanish(normalizedAnalysis)) {
      return _buildHeuristicAnalysis(dreamText, isSpanish: false);
    }

    return normalizedAnalysis;
  }

  static DreamAnalysis _normalizeLegacyTerms(DreamAnalysis analysis) {
    String normalizeTerm(String value) {
      return value.replaceAll(
        RegExp(r'\bsonador\b', caseSensitive: false),
        'soñador',
      );
    }

    List<String> normalizeList(List<String> values) {
      return values.map(normalizeTerm).toList(growable: false);
    }

    return DreamAnalysis(
      sentiment: normalizeTerm(analysis.sentiment),
      category: normalizeTerm(analysis.category),
      emotions: normalizeList(analysis.emotions),
      characters: normalizeList(analysis.characters),
      places: normalizeList(analysis.places),
      themes: normalizeList(analysis.themes),
      psychologicalNote: normalizeTerm(analysis.psychologicalNote),
      summary: normalizeTerm(analysis.summary),
    );
  }

  static DreamAnalysis alignWithDreamSignals({
    required DreamAnalysis analysis,
    required String dreamText,
    required String localeCode,
  }) {
    final isSpanish = normalizeLocaleCode(localeCode) == 'es';
    final normalized = dreamText.toLowerCase();

    final hasPursuitStrong = RegExp(
      r'persig|hu[iu]a|pasos detr[aá]s|me sigue|amenaza|persec|chase|pursu',
    ).hasMatch(normalized);
    final hasFallStrong = RegExp(
      r'ca[ií]da|cayendo|precipicio|paso en falso|fall(ing)?|free fall',
    ).hasMatch(normalized);
    final hasWaterStrong = RegExp(
      r'mar|playa|inund|lluv|marea|r[ií]o|oc[eé]ano|agua.{0,24}(sub|inund|nivel|rodilla|tobillo|casa|habitaci)',
    ).hasMatch(normalized);
    final hasWeakWaterSimile = RegExp(
      r'como si.{0,40}agua|as if.{0,40}water|like.{0,40}water',
    ).hasMatch(normalized);

    final looksWater = _analysisLooksWater(analysis);
    final looksNoPattern = _analysisLooksNoPattern(analysis);

    if (hasPursuitStrong &&
        looksWater &&
        !hasWaterStrong &&
        hasWeakWaterSimile) {
      return _buildPursuitAnalysis(isSpanish: isSpanish);
    }

    if (hasPursuitStrong && looksNoPattern) {
      return _buildPursuitAnalysis(isSpanish: isSpanish);
    }

    if (hasFallStrong && looksNoPattern) {
      return _buildFallAnalysis(isSpanish: isSpanish);
    }

    return analysis;
  }

  static bool _looksEnglish(DreamAnalysis analysis) {
    final blob = _analysisBlob(analysis);
    const markers = <String>[
      'dream',
      'freedom',
      'anxiety',
      'fear',
      'pressure',
      'summary',
      'note',
      'water',
      'chase',
      'falling',
      'communication',
    ];
    return _countMatches(blob, markers) >= 2;
  }

  static bool _looksSpanish(DreamAnalysis analysis) {
    final blob = _analysisBlob(analysis);
    const markers = <String>[
      'sueno',
      'ansiedad',
      'miedo',
      'presion',
      'resumen',
      'nota',
      'agua',
      'persecucion',
      'caida',
      'comunicacion',
      'morfeo',
    ];
    return _countMatches(blob, markers) >= 2;
  }

  static int _countMatches(String text, List<String> markers) {
    var count = 0;
    for (final marker in markers) {
      if (text.contains(marker)) count++;
    }
    return count;
  }

  static String _analysisBlob(DreamAnalysis analysis) {
    return [
      analysis.sentiment,
      analysis.category,
      analysis.summary,
      analysis.psychologicalNote,
      analysis.emotions.join(' '),
      analysis.characters.join(' '),
      analysis.places.join(' '),
      analysis.themes.join(' '),
    ].join(' ').toLowerCase();
  }

  static bool _analysisLooksWater(DreamAnalysis analysis) {
    final blob = _analysisBlob(analysis);
    return blob.contains('agua') ||
        blob.contains('water') ||
        blob.contains('inund') ||
        blob.contains('marea') ||
        blob.contains('flood');
  }

  static bool _analysisLooksNoPattern(DreamAnalysis analysis) {
    final blob = _analysisBlob(analysis);
    return blob.contains('sin un patron') ||
        blob.contains('no encaja') ||
        blob.contains('no clear pattern') ||
        blob.contains('single dominant pattern') ||
        blob.contains('neutral');
  }

  static DreamAnalysis _buildPursuitAnalysis({required bool isSpanish}) {
    return DreamAnalysis(
      sentiment: isSpanish ? 'negativo' : 'negative',
      category: isSpanish ? 'Pesadilla' : 'Nightmare',
      emotions: isSpanish
          ? const ['miedo', 'vigilancia', 'impotencia']
          : const ['fear', 'vigilance', 'helplessness'],
      characters: isSpanish
          ? const ['soñador', 'perseguidor']
          : const ['dreamer', 'pursuer'],
      places: isSpanish
          ? const ['bosque', 'pasillos', 'exteriores oscuros']
          : const ['forest', 'corridors', 'dark exteriors'],
      themes: isSpanish
          ? const ['persecución', 'amenaza', 'evitación']
          : const ['pursuit', 'threat', 'avoidance'],
      psychologicalNote: isSpanish
          ? 'El patrón dominante es de persecución: refleja tensión sostenida y sensación de amenaza no resuelta.'
          : 'The dominant pattern is pursuit: it reflects sustained tension and unresolved threat perception.',
      summary: isSpanish
          ? 'Morfeo detecta un sueño de persecución y amenaza latente.'
          : 'Morpheus detects a pursuit dream with latent threat.',
    );
  }

  static DreamAnalysis _buildFallAnalysis({required bool isSpanish}) {
    return DreamAnalysis(
      sentiment: isSpanish ? 'negativo' : 'negative',
      category: 'Surreal',
      emotions: isSpanish
          ? const ['vértigo', 'pánico', 'pérdida de control']
          : const ['vertigo', 'panic', 'loss of control'],
      characters: isSpanish ? const ['soñador'] : const ['dreamer'],
      places: isSpanish ? const ['altura', 'caida'] : const ['height', 'fall'],
      themes: isSpanish
          ? const ['caída', 'descontrol', 'despertar brusco']
          : const ['falling', 'loss of control', 'abrupt awakening'],
      psychologicalNote: isSpanish
          ? 'El patrón dominante es de caída: suele indicar inseguridad y sensación de pérdida de control.'
          : 'The dominant pattern is falling: it often indicates insecurity and perceived loss of control.',
      summary: isSpanish
          ? 'Morfeo detecta un sueño de caída con alta tensión emocional.'
          : 'Morpheus detects a falling dream with high emotional tension.',
    );
  }

  static DreamAnalysis _buildHeuristicAnalysis(
    String dreamText, {
    required bool isSpanish,
  }) {
    final normalized = dreamText.toLowerCase();
    final hasWater = RegExp(
      r'agua|mar|inund|lluv|marea|oceano|river|flood|water',
    ).hasMatch(normalized);
    final hasPursuit = RegExp(
      r'persig|huia|amenaza|persec|chase|pursu',
    ).hasMatch(normalized);
    final hasFall = RegExp(r'caida|cayendo|fall|precip').hasMatch(normalized);
    final hasFlight = RegExp(
      r'volar|volaba|nubes|fly|flying|sky',
    ).hasMatch(normalized);
    final hasTeeth = RegExp(r'diente|dientes|teeth|tooth').hasMatch(normalized);
    final hasExam = RegExp(
      r'examen|aula|exam|classroom|test',
    ).hasMatch(normalized);
    final hasPhone = RegExp(
      r'telefono|llamar|senal|phone|call|signal',
    ).hasMatch(normalized);

    if (hasFlight) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'positivo' : 'positive',
        category: isSpanish ? 'Fantasía' : 'Fantasy',
        emotions: isSpanish
            ? const ['libertad', 'amplitud', 'ligereza']
            : const ['freedom', 'expansion', 'lightness'],
        characters: isSpanish ? const ['soñador'] : const ['dreamer'],
        places: isSpanish
            ? const ['ciudad', 'cielo', 'nubes']
            : const ['city', 'sky', 'clouds'],
        themes: isSpanish
            ? const ['libertad', 'escape', 'trascendencia']
            : const ['freedom', 'escape', 'transcendence'],
        psychologicalNote: isSpanish
            ? 'El vuelo suele reflejar alivio emocional y necesidad de expansión personal.'
            : 'Flying often reflects emotional relief and a need for personal expansion.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de libertad y apertura emocional.'
            : 'Morpheus detects a dream of freedom and emotional openness.',
      );
    }

    if (hasPursuit) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'negativo' : 'negative',
        category: isSpanish ? 'Pesadilla' : 'Nightmare',
        emotions: isSpanish
            ? const ['miedo', 'vigilancia', 'impotencia']
            : const ['fear', 'vigilance', 'helplessness'],
        characters: isSpanish
            ? const ['soñador', 'perseguidor']
            : const ['dreamer', 'pursuer'],
        places: isSpanish
            ? const ['pasillos', 'exteriores oscuros']
            : const ['corridors', 'dark exteriors'],
        themes: isSpanish
            ? const ['amenaza', 'evitación', 'ansiedad']
            : const ['threat', 'avoidance', 'anxiety'],
        psychologicalNote: isSpanish
            ? 'La persecución suele reflejar tensión sostenida o problemas no resueltos.'
            : 'Chase dreams often reflect sustained tension or unresolved stressors.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de persecución y amenaza latente.'
            : 'Morpheus detects a chase dream with latent threat.',
      );
    }

    if (hasFall) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'negativo' : 'negative',
        category: isSpanish ? 'Surreal' : 'Surreal',
        emotions: isSpanish
            ? const ['vértigo', 'pánico', 'pérdida de control']
            : const ['vertigo', 'panic', 'loss of control'],
        characters: isSpanish ? const ['soñador'] : const ['dreamer'],
        places: isSpanish
            ? const ['altura', 'caida']
            : const ['height', 'fall'],
        themes: isSpanish
            ? const ['caída', 'descontrol', 'despertar brusco']
            : const ['falling', 'loss of control', 'abrupt awakening'],
        psychologicalNote: isSpanish
            ? 'La caída onírica suele asociarse a inseguridad o pérdida de control.'
            : 'Falling dreams are often associated with insecurity or loss of control.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de caída con alta tensión emocional.'
            : 'Morpheus detects a falling dream with high emotional tension.',
      );
    }

    if (hasTeeth) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'negativo' : 'negative',
        category: isSpanish ? 'Ansiedad' : 'Anxiety',
        emotions: isSpanish
            ? const ['vergüenza', 'estrés', 'vulnerabilidad']
            : const ['embarrassment', 'stress', 'vulnerability'],
        characters: isSpanish
            ? const ['soñador', 'personas cercanas']
            : const ['dreamer', 'close people'],
        places: isSpanish ? const ['entorno social'] : const ['social setting'],
        themes: isSpanish
            ? const ['imagen personal', 'presion social']
            : const ['self-image', 'social pressure'],
        psychologicalNote: isSpanish
            ? 'Este sueño suele reflejar vulnerabilidad ante la evaluación externa.'
            : 'This dream often reflects vulnerability to external evaluation.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de vulnerabilidad e imagen personal.'
            : 'Morpheus detects a dream about vulnerability and self-image.',
      );
    }

    if (hasExam) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'negativo' : 'negative',
        category: isSpanish ? 'Ansiedad' : 'Anxiety',
        emotions: isSpanish
            ? const ['presión', 'confusión', 'inseguridad']
            : const ['pressure', 'confusion', 'insecurity'],
        characters: isSpanish
            ? const ['soñador', 'companeros']
            : const ['dreamer', 'classmates'],
        places: isSpanish ? const ['aula'] : const ['classroom'],
        themes: isSpanish
            ? const ['rendimiento', 'evaluacion']
            : const ['performance', 'evaluation'],
        psychologicalNote: isSpanish
            ? 'El sueño refleja ansiedad por rendimiento y miedo a no estar preparado.'
            : 'The dream reflects performance anxiety and fear of being unprepared.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de evaluación con presión académica o social.'
            : 'Morpheus detects an evaluation dream with academic or social pressure.',
      );
    }

    if (hasPhone) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'negativo' : 'negative',
        category: isSpanish ? 'Ansiedad' : 'Anxiety',
        emotions: isSpanish
            ? const ['urgencia', 'frustracion', 'impotencia']
            : const ['urgency', 'frustration', 'helplessness'],
        characters: isSpanish
            ? const ['soñador', 'persona inalcanzable']
            : const ['dreamer', 'unreachable person'],
        places: isSpanish
            ? const ['calle', 'tienda']
            : const ['street', 'shop'],
        themes: isSpanish
            ? const ['bloqueo de comunicacion', 'accion impedida']
            : const ['communication blockage', 'blocked action'],
        psychologicalNote: isSpanish
            ? 'La urgencia sin respuesta suele indicar sobrecarga emocional sostenida.'
            : 'Urgency without response often indicates sustained emotional overload.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de urgencia con bloqueo comunicativo.'
            : 'Morpheus detects an urgent dream with communication blockage.',
      );
    }

    if (hasWater) {
      return DreamAnalysis(
        sentiment: isSpanish ? 'mixto' : 'mixed',
        category: isSpanish ? 'Ansiedad' : 'Anxiety',
        emotions: isSpanish
            ? const ['miedo', 'tension', 'alerta']
            : const ['fear', 'tension', 'alertness'],
        characters: isSpanish
            ? const ['soñador', 'familia o testigos']
            : const ['dreamer', 'family or witnesses'],
        places: isSpanish
            ? const ['orilla', 'casa', 'espacio inundado']
            : const ['shore', 'house', 'flooded space'],
        themes: isSpanish
            ? const ['agua', 'presion', 'perdida de limites']
            : const ['water', 'pressure', 'boundary loss'],
        psychologicalNote: isSpanish
            ? 'La presencia de agua sugiere carga emocional y sensación de sobrepaso.'
            : 'Water imagery suggests emotional overload and pressure.',
        summary: isSpanish
            ? 'Morfeo detecta un sueño de presión emocional vinculada al agua.'
            : 'Morpheus detects a dream of emotional pressure linked to water.',
      );
    }

    return DreamAnalysis(
      sentiment: isSpanish ? 'neutral' : 'neutral',
      category: isSpanish ? 'Neutral' : 'Neutral',
      emotions: isSpanish
          ? const ['reflexion', 'incertidumbre']
          : const ['reflection', 'uncertainty'],
      characters: isSpanish ? const ['soñador'] : const ['dreamer'],
      places: isSpanish ? const ['escenario onirico'] : const ['dream setting'],
      themes: isSpanish
          ? const ['procesamiento emocional']
          : const ['emotional processing'],
      psychologicalNote: isSpanish
          ? 'El contenido sugiere procesamiento emocional sin un patrón dominante claro.'
          : 'The content suggests emotional processing without a clear dominant pattern.',
      summary: isSpanish
          ? 'Morfeo detecta un sueño sin un patrón único dominante.'
          : 'Morpheus detects a dream without a single dominant pattern.',
    );
  }
}

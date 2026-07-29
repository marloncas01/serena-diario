import '../models/memory_item.dart';

class _ExtractionPattern {
  const _ExtractionPattern({
    required this.category,
    required this.patterns,
    required this.keywords,
    this.confidence = 0.7,
  });

  final MemoryCategory category;
  final List<RegExp> patterns;
  final List<String> keywords;
  final double confidence;
}

class ExtractionResult {
  const ExtractionResult({
    required this.items,
    required this.extractedFrom,
  });

  final List<MemoryItem> items;
  final String extractedFrom;
}

class MemoryExtractor {
  const MemoryExtractor._();

  static final List<_ExtractionPattern> _patterns = [
    _ExtractionPattern(
      category: MemoryCategory.familia,
      patterns: [
        RegExp(r'm[ia](?:\s+)?(?:m[aá]|padre|herman[oa]|t[ií]o|abuel[oa]|primo|suegr[oa]|cuñad[oa])', caseSensitive: false),
        RegExp(r'mi\s+familia', caseSensitive: false),
        RegExp(r'(?:mi|el|la|mis)\s+(?:mam[aá]|pap[aá]|padre|madre|hermano|hermana|t[ií]o|t[ií]a|abuelo|abuela|primo|prima|suegro|suegra|cuñado|cuñada)', caseSensitive: false),
        RegExp(r'(?:est[aá]|s[eé]?)\s+(?:enferm[oa]|hospitalizad[oa]|operad[oa]|de Hospital)', caseSensitive: false),
        RegExp(r'(?:nac(?:ió|imiento)|bautiz|cas(?:o|amiento|arse)|divorc|muert[oa]|fallec)', caseSensitive: false),
      ],
      keywords: [
        'mamá', 'papá', 'madre', 'padre', 'hermano', 'hermana',
        'tío', 'tía', 'abuelo', 'abuela', 'primo', 'prima',
        'suegro', 'suegra', 'cuñado', 'cuñada', 'familia',
        'enferma', 'enfermo', 'hospital', 'operación', 'nacimiento',
        'boda', 'casamiento', 'divorcio', 'funeral', 'velorio',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.relacion,
      patterns: [
        RegExp(r'(?:mi|el|la)\s+(?:novio|novia|esposo|esposa|pareja|marido|compañero|compañera)', caseSensitive: false),
        RegExp(r'(?:me\s+)?(?:enamor(?:é|o|ad[oa])|separ(?:é|o|ad[oa])|divorci(?:é|o|ad[oa]))', caseSensitive: false),
        RegExp(r'(?:pele(?:é|a|ar)|reconcili(?:é|a|ar)|romp(?:í|e|er))', caseSensitive: false),
      ],
      keywords: [
        'novio', 'novia', 'esposo', 'esposa', 'pareja', 'marido',
        'enamorado', 'enamorada', 'casé', 'divorcio', 'separación',
        'pelea', 'reconciliación', 'rompí', 'amor', 'relación',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.persona,
      patterns: [
        RegExp(r'(?:mi|un[oa]?)\s+(?:amig[oa]|compañer[oa]|jefe|vecin[oa]|profesor|doctor|colega)', caseSensitive: false),
        RegExp(r'(?:se\s+llama|conoc[ií]|llam(?:é|a))\s+\w+', caseSensitive: false),
      ],
      keywords: [
        'amigo', 'amiga', 'compañero', 'compañera', 'jefe', 'vecino',
        'vecina', 'profesor', 'doctor', 'colega', 'conocí', 'llamé',
        'se llama', 'persona', 'gente', 'alguien',
      ],
      confidence: 0.7,
    ),

    _ExtractionPattern(
      category: MemoryCategory.mascota,
      patterns: [
        RegExp(r'(?:mi|el|la|nuestro[as]?)\s+(?:perro|gat[oa]|loro|hamster|conejo|pez|tortuga|mascota)', caseSensitive: false),
        RegExp(r'(?:se\s+llama|llam(?:é|a)|tengo)\s+(?:un|una|el|la)\s+(?:perro|gat[oa]|loro|hamster|conejo|pez)', caseSensitive: false),
        RegExp(r'(?:mascota|peludo|fur[- ]?baby)', caseSensitive: false),
      ],
      keywords: [
        'perro', 'gato', 'gata', 'loro', 'hamster', 'conejo',
        'pez', 'tortuga', 'mascota', 'peludo', 'fur baby',
      ],
      confidence: 0.8,
    ),

    _ExtractionPattern(
      category: MemoryCategory.evento,
      patterns: [
        RegExp(r'(?:ma[nñ]ana|el\s+lunes|el\s+martes|el\s+mi[eé]rcoles|el\s+jueves|el\s+viernes|el\s+s[aá]bado|el\s+domingo|pr[oó]xim[oa])\s+\w+', caseSensitive: false),
        RegExp(r'(?:tengo|hay|es|ser[aá])\s+(?:una?\s+)?(?:entrevista|examen|reuni[oó]n|cita|viaje|evento|presentaci[oó]n|boda|cumplea[nñ]os|fiesta|conferencia)', caseSensitive: false),
        RegExp(r'(?:el\s+|la\s+|los\s+|las\s+)?\d{1,2}\s+(?:de\s+)?\w+', caseSensitive: false),
        RegExp(r'(?:hoy|ayer|la\s+semana\s+pasada|el\s+mes\s+pasado)\s+\w+', caseSensitive: false),
      ],
      keywords: [
        'mañana', 'próximo', 'entrevista', 'examen', 'reunión',
        'cita', 'viaje', 'evento', 'presentación', 'boda',
        'cumpleaños', 'fiesta', 'conferencia', 'hoy', 'ayer',
        'semana', 'lunes', 'martes', 'miércoles', 'jueves',
        'viernes', 'sábado', 'domingo',
      ],
      confidence: 0.7,
    ),

    _ExtractionPattern(
      category: MemoryCategory.meta,
      patterns: [
        RegExp(r'(?:quiero|deseo|necesito|me\s+gustar[ií]a|voy\s+a|pienso|planeo|objetivo|meta)\s+\w+', caseSensitive: false),
        RegExp(r'(?:aprender|mejorar|lograr|conseguir|alcanzar|terminar|completar|empezar|iniciar|crecer)\s+\w+', caseSensitive: false),
        RegExp(r'(?:pr[oó]xim[oa]?\s+(?:meta|objetivo|año))', caseSensitive: false),
      ],
      keywords: [
        'quiero', 'deseo', 'necesito', 'me gustaría', 'voy a',
        'pienso', 'planeo', 'objetivo', 'meta', 'aprender',
        'mejorar', 'lograr', 'conseguir', 'alcanzar', 'terminar',
        'completar', 'empezar', 'iniciar', 'crecer', 'soñar',
      ],
      confidence: 0.7,
    ),

    _ExtractionPattern(
      category: MemoryCategory.miedo,
      patterns: [
        RegExp(r'(?:tengo\s+miedo|me\s+(?:da|dan)\s+(?:miedo|panico|terror|fobia)|me\s+asusta)', caseSensitive: false),
        RegExp(r'(?:me\s+(?:da|dan)\s+(?:miedo|panico|terror|fobia))', caseSensitive: false),
        RegExp(r'(?:temo|temo\s+a|me\s+preocupa|me\s+preocupan)', caseSensitive: false),
        RegExp(r'(?:miedo|panico|terror|fobia|temor)', caseSensitive: false),
      ],
      keywords: [
        'miedo', 'pánico', 'terror', 'fobia', 'temor', 'asusta',
        'preocupa', 'preocupación', 'angustia', 'temo',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.problema,
      patterns: [
        RegExp(r'(?:tengo\s+(?:un|una)\s+problema|se\s+(?:me\s+)?(?:rompi[óo]|cay[óo]|perdi[óo]|dañ[óo]))', caseSensitive: false),
        RegExp(r'(?:no\s+(?:puedo|logro|consigo|funciona|sale|anda))\s+\w+', caseSensitive: false),
        RegExp(r'(?:problema|difficultad|complicad[oa]|complicación|conflicto)', caseSensitive: false),
        RegExp(r'(?:se\s+(?:me\s+)?(?:rompe|cae|pierde|daña))', caseSensitive: false),
      ],
      keywords: [
        'problema', 'dificultad', 'complicado', 'complicación',
        'conflicto', 'rompió', 'cayó', 'perdí', 'dañó', 'no puedo',
        'no logro', 'no consigo', 'no funciona', 'no sale',
      ],
      confidence: 0.7,
    ),

    _ExtractionPattern(
      category: MemoryCategory.logro,
      patterns: [
        RegExp(r'(?:logr[éeo]|consegu[ií]|gan[éeo]|aprob[éeo]|termin[éeo]|complet[éeo]|alcanc[éeo]|super[éeo])\s+\w+', caseSensitive: false),
        RegExp(r'(?:me\s+(?:gradu[éeo]|promovieron|ascendieron|reconocieron))', caseSensitive: false),
        RegExp(r'(?:[ée]xito|logro|triunfo|victoria|medalla|premio|reconocimiento)', caseSensitive: false),
      ],
      keywords: [
        'logré', 'conseguí', 'gané', 'aprobé', 'terminé',
        'completé', 'alcancé', 'superé', 'gradué', 'promovieron',
        'ascendieron', 'éxito', 'logro', 'triunfo', 'victoria',
        'premio', 'reconocimiento',
      ],
      confidence: 0.8,
    ),

    _ExtractionPattern(
      category: MemoryCategory.gusto,
      patterns: [
        RegExp(r'(?:me\s+(?:gust[áa]|encanta|fascina|adora|disfruto|encantó))\s+\w+', caseSensitive: false),
        RegExp(r'(?:mi\s+(?:comida|color|canción|película|libro|lugar|sabor|animal)\s+(?:favorit[oa]|es))', caseSensitive: false),
        RegExp(r'(?:favorit[oa]|preferid[oa])', caseSensitive: false),
      ],
      keywords: [
        'me gusta', 'me encanta', 'me fascina', 'adoro', 'disfruto',
        'favorito', 'favorita', 'preferido', 'preferida', 'encantó',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.rutina,
      patterns: [
        RegExp(r'(?:siempre|cada\s+(?:d[ií]a|ma[nñ]ana|tarde|noche|semana|mes))\s+\w+', caseSensitive: false),
        RegExp(r'(?:mi\s+(?:rutina|horario|costumbre))\s+\w+', caseSensitive: false),
        RegExp(r'(?:suelo|acostumbr[éeo]|sac[éeo])\s+\w+', caseSensitive: false),
      ],
      keywords: [
        'siempre', 'cada día', 'cada mañana', 'cada tarde',
        'cada noche', 'rutina', 'horario', 'costumbre', 'suelo',
        'acostumbré', 'saco',
      ],
      confidence: 0.65,
    ),

    _ExtractionPattern(
      category: MemoryCategory.salud,
      patterns: [
        RegExp(r'(?:estoy|siento|me\s+(?:duele|duelen|duele))\s+(?:enferm[oa]|mal|cansad[oa]|maread[oa]|dolor)', caseSensitive: false),
        RegExp(r'(?:tengo\s+(?:fiebre|dolor|gripe|resfriado|alergia|infección|ansiedad|depresión|insomnio))', caseSensitive: false),
        RegExp(r'(?:me\s+(?:operan|operaron|medican|medicaron|diagnosticaron))', caseSensitive: false),
        RegExp(r'(?:doctor|m[eé]dic[oa]|hospital|clínica|farmacia|medicina|tratamiento)', caseSensitive: false),
        RegExp(r'(?:no\s+(?:puedo|logro)\s+(?:dormir|comer|camina))', caseSensitive: false),
        RegExp(r'(?:terapia|psic[oó]log[oa]|psiquiatr)', caseSensitive: false),
      ],
      keywords: [
        'enfermo', 'enferma', 'duele', 'dolor', 'fiebre', 'gripe',
        'resfriado', 'alergia', 'infección', 'ansiedad', 'depresión',
        'insomnio', 'operaron', 'medican', 'doctor', 'médico',
        'hospital', 'clínica', 'farmacia', 'medicina', 'tratamiento',
        'terapia', 'psicólogo', 'psicóloga', 'psiquiatra',
        'no puedo dormir', 'cansado', 'mareado',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.trabajo,
      patterns: [
        RegExp(r'(?:mi\s+(?:trabajo|empleo|jefe|oficina|empresa|colegas))', caseSensitive: false),
        RegExp(r'(?:trabajo(?:n|o|ando|é)?|emple[ao]|jef[ea]|oficina|empresa|colegas|compañeros)', caseSensitive: false),
        RegExp(r'(?:me\s+(?:ascendieron|despidieron|contrataron|renunci[éeo]))', caseSensitive: false),
        RegExp(r'(?:entrevista\s+de\s+trabajo|reuni[oó]n|proyecto|deadlin|sueldo|salario|nómina)', caseSensitive: false),
      ],
      keywords: [
        'trabajo', 'empleo', 'jefe', 'oficina', 'empresa',
        'colegas', 'compañeros', 'ascendieron', 'despidieron',
        'contrataron', 'renuncié', 'entrevista de trabajo',
        'reunión', 'proyecto', 'deadline', 'sueldo', 'salario',
      ],
      confidence: 0.75,
    ),

    _ExtractionPattern(
      category: MemoryCategory.estudio,
      patterns: [
        RegExp(r'(?:estud(?:io|iar|iando|i[ée])|clase|clases|universidad|colegio|escuela|tarea|tareas|examen|exámenes|profesor|profesora|materia|carrera|tesis|título)', caseSensitive: false),
        RegExp(r'(?:aprend(?:o|iendo|i[ée])|investiga(?:ción|cando))', caseSensitive: false),
        RegExp(r'(?:me\s+(?:gradu[éeo]|graduando|promovieron))', caseSensitive: false),
      ],
      keywords: [
        'estudiar', 'estudio', 'clase', 'clases', 'universidad',
        'colegio', 'escuela', 'tarea', 'tareas', 'examen',
        'exámenes', 'profesor', 'profesora', 'materia', 'carrera',
        'tesis', 'título', 'aprendiendo', 'investigación', 'gradué',
      ],
      confidence: 0.75,
    ),
  ];

  static ExtractionResult extract(String text) {
    if (text.trim().isEmpty) {
      return ExtractionResult(items: const [], extractedFrom: text);
    }

    final normalized = _normalize(text);
    final items = <MemoryItem>[];

    for (final pattern in _patterns) {
      final matches = _findMatches(normalized, pattern);
      if (matches.isEmpty) continue;

      final keywords = _extractKeywords(normalized, pattern.keywords);
      final value = _buildValue(text, matches, pattern.category);
      final confidence = _calculateConfidence(
        pattern.confidence,
        matches.length,
        keywords.length,
      );

      items.add(MemoryItem(
        id: _generateId(pattern.category, value),
        category: pattern.category,
        value: value,
        confidence: confidence,
        createdAt: DateTime.now(),
        lastMention: DateTime.now(),
        originalText: text,
        keywords: keywords,
      ));
    }

    return ExtractionResult(items: items, extractedFrom: text);
  }

  static String _normalize(String text) {
    var t = text.toLowerCase().trim();
    t = t.replaceAll(RegExp(r'[¿¡!?.;:,()\[\]{}\u00AB\u00BB\u2013\u2014\u2012\-]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  static List<RegExp> _findMatches(String text, _ExtractionPattern pattern) {
    final matches = <RegExp>[];
    for (final regex in pattern.patterns) {
      if (regex.hasMatch(text)) matches.add(regex);
    }
    return matches;
  }

  static List<String> _extractKeywords(String text, List<String> keywords) {
    final found = <String>[];
    for (final kw in keywords) {
      if (text.contains(kw.toLowerCase())) found.add(kw);
    }
    return found;
  }

  static String _buildValue(
    String originalText,
    List<RegExp> matches,
    MemoryCategory category,
  ) {
    final sentences = originalText
        .split(RegExp(r'[.!?;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.isEmpty) return originalText.trim();

    final scored = <_ScoredSentence>[];
    for (final sentence in sentences) {
      var score = 0;
      final lower = sentence.toLowerCase();
      for (final match in matches) {
        if (match.hasMatch(lower)) score += 2;
      }
      scored.add(_ScoredSentence(sentence, score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final best = scored.first.sentence;

    return _capitalize(best);
  }

  static double _calculateConfidence(
    double baseConfidence,
    int matchCount,
    int keywordCount,
  ) {
    final matchBoost = (matchCount * 0.05).clamp(0.0, 0.15);
    final keywordBoost = (keywordCount * 0.03).clamp(0.0, 0.1);
    return (baseConfidence + matchBoost + keywordBoost).clamp(0.0, 1.0);
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _generateId(MemoryCategory category, String value) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = value.hashCode.abs().toRadixString(16);
    return '${category.name}_${hash}_$timestamp';
  }
}

class _ScoredSentence {
  const _ScoredSentence(this.sentence, this.score);

  final String sentence;
  final int score;
}

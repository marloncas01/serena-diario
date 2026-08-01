class LexiconEntry {
  const LexiconEntry(this.emotionId, this.weight);

  final String emotionId;
  final double weight;
}

class EmotionLexicon {
  const EmotionLexicon._();

  static final Map<String, List<LexiconEntry>> _keywords = {
    // ── Positivas ──
    'alegria': [
      const LexiconEntry('alegria', 1.0),
      const LexiconEntry('felicidad', 0.5),
      const LexiconEntry('motivacion', 0.2),
    ],
    'feliz': [
      const LexiconEntry('felicidad', 1.0),
      const LexiconEntry('alegria', 0.6),
      const LexiconEntry('calma', 0.15),
    ],
    'contento': [
      const LexiconEntry('felicidad', 0.9),
      const LexiconEntry('alegria', 0.7),
    ],
    'alegre': [
      const LexiconEntry('alegria', 1.0),
      const LexiconEntry('felicidad', 0.6),
    ],
    'genial': [
      const LexiconEntry('alegria', 0.9),
      const LexiconEntry('felicidad', 0.8),
      const LexiconEntry('motivacion', 0.3),
    ],
    'increible': [
      const LexiconEntry('alegria', 0.8),
      const LexiconEntry('felicidad', 0.7),
      const LexiconEntry('inspiracion', 0.3),
    ],
    'maravilloso': [
      const LexiconEntry('felicidad', 0.9),
      const LexiconEntry('gratitud', 0.4),
      const LexiconEntry('inspiracion', 0.3),
    ],
    'fantastico': [
      const LexiconEntry('alegria', 0.85),
      const LexiconEntry('felicidad', 0.75),
    ],
    'excelente': [
      const LexiconEntry('alegria', 0.8),
      const LexiconEntry('felicidad', 0.7),
      const LexiconEntry('orgullo', 0.3),
    ],
    'bien': [
      const LexiconEntry('felicidad', 0.4),
      const LexiconEntry('calma', 0.3),
    ],
    'divertido': [
      const LexiconEntry('alegria', 0.8),
      const LexiconEntry('felicidad', 0.6),
      const LexiconEntry('diversion', 0.8),
    ],
    'reir': [
      const LexiconEntry('alegria', 0.9),
      const LexiconEntry('felicidad', 0.5),
    ],
    'sonreir': [
      const LexiconEntry('alegria', 0.85),
      const LexiconEntry('felicidad', 0.5),
    ],
    'celebrar': [
      const LexiconEntry('alegria', 0.8),
      const LexiconEntry('felicidad', 0.7),
      const LexiconEntry('orgullo', 0.3),
    ],
    'bailar': [
      const LexiconEntry('alegria', 0.7),
      const LexiconEntry('felicidad', 0.6),
    ],
    'fiesta': [
      const LexiconEntry('alegria', 0.6),
      const LexiconEntry('felicidad', 0.5),
      const LexiconEntry('diversion', 0.7),
    ],

    'amor': [
      const LexiconEntry('amor', 1.0),
      const LexiconEntry('felicidad', 0.3),
      const LexiconEntry('gratitud', 0.2),
    ],
    'amar': [
      const LexiconEntry('amor', 1.0),
      const LexiconEntry('felicidad', 0.3),
    ],
    'querer': [
      const LexiconEntry('amor', 0.7),
      const LexiconEntry('felicidad', 0.2),
    ],
    'cariño': [
      const LexiconEntry('amor', 0.9),
      const LexiconEntry('calma', 0.3),
    ],
    'abrazo': [
      const LexiconEntry('amor', 0.8),
      const LexiconEntry('calma', 0.4),
      const LexiconEntry('gratitud', 0.2),
    ],
    'beso': [
      const LexiconEntry('amor', 0.8),
      const LexiconEntry('felicidad', 0.3),
    ],
    'pareja': [
      const LexiconEntry('amor', 0.6),
      const LexiconEntry('felicidad', 0.3),
    ],
    'corazon': [
      const LexiconEntry('amor', 0.7),
      const LexiconEntry('felicidad', 0.3),
    ],
    'enamorado': [
      const LexiconEntry('amor', 1.0),
      const LexiconEntry('alegria', 0.4),
    ],
    'amiga': [
      const LexiconEntry('amor', 0.4),
      const LexiconEntry('gratitud', 0.3),
      const LexiconEntry('felicidad', 0.3),
    ],
    'amigo': [
      const LexiconEntry('amor', 0.4),
      const LexiconEntry('gratitud', 0.3),
      const LexiconEntry('felicidad', 0.3),
    ],
    'hijo': [
      const LexiconEntry('amor', 0.6),
      const LexiconEntry('felicidad', 0.3),
    ],
    'hija': [
      const LexiconEntry('amor', 0.6),
      const LexiconEntry('felicidad', 0.3),
    ],
    'familia': [
      const LexiconEntry('amor', 0.5),
      const LexiconEntry('gratitud', 0.3),
      const LexiconEntry('calma', 0.2),
    ],

    'agradecido': [
      const LexiconEntry('gratitud', 1.0),
      const LexiconEntry('calma', 0.3),
      const LexiconEntry('felicidad', 0.3),
    ],
    'agradecida': [
      const LexiconEntry('gratitud', 1.0),
      const LexiconEntry('calma', 0.3),
      const LexiconEntry('felicidad', 0.3),
    ],
    'gratitud': [
      const LexiconEntry('gratitud', 1.0),
      const LexiconEntry('calma', 0.2),
    ],
    'bendecido': [
      const LexiconEntry('gratitud', 0.9),
      const LexiconEntry('felicidad', 0.4),
    ],
    'bendecida': [
      const LexiconEntry('gratitud', 0.9),
      const LexiconEntry('felicidad', 0.4),
    ],
    'apreciar': [
      const LexiconEntry('gratitud', 0.8),
      const LexiconEntry('amor', 0.3),
    ],
    'valoro': [
      const LexiconEntry('gratitud', 0.7),
      const LexiconEntry('amor', 0.2),
    ],
    'regalo': [
      const LexiconEntry('gratitud', 0.5),
      const LexiconEntry('felicidad', 0.4),
    ],
    'oportunidad': [
      const LexiconEntry('gratitud', 0.4),
      const LexiconEntry('esperanza', 0.4),
    ],

    'esperanza': [
      const LexiconEntry('esperanza', 1.0),
      const LexiconEntry('motivacion', 0.3),
    ],
    'espero': [
      const LexiconEntry('esperanza', 0.8),
      const LexiconEntry('incertidumbre', 0.2),
    ],
    'confio': [
      const LexiconEntry('esperanza', 0.9),
      const LexiconEntry('calma', 0.2),
      const LexiconEntry('confianza', 0.9),
    ],
    'confianza': [
      const LexiconEntry('esperanza', 0.7),
      const LexiconEntry('calma', 0.3),
      const LexiconEntry('confianza', 1.0),
    ],
    'futuro': [
      const LexiconEntry('esperanza', 0.5),
      const LexiconEntry('incertidumbre', 0.3),
    ],
    'sueño': [
      const LexiconEntry('esperanza', 0.5),
      const LexiconEntry('inspiracion', 0.3),
    ],
    'anho': [
      const LexiconEntry('esperanza', 0.4),
      const LexiconEntry('incertidumbre', 0.2),
    ],
    'anhelo': [
      const LexiconEntry('esperanza', 0.7),
      const LexiconEntry('amor', 0.2),
    ],
    'ilusion': [
      const LexiconEntry('esperanza', 0.8),
      const LexiconEntry('alegria', 0.3),
      const LexiconEntry('ilusion', 0.9),
    ],
    'meta': [
      const LexiconEntry('esperanza', 0.4),
      const LexiconEntry('motivacion', 0.5),
    ],
    'objetivo': [
      const LexiconEntry('esperanza', 0.3),
      const LexiconEntry('motivacion', 0.5),
    ],

    'calma': [
      const LexiconEntry('calma', 1.0),
      const LexiconEntry('gratitud', 0.15),
    ],
    'tranquilo': [
      const LexiconEntry('calma', 1.0),
    ],
    'tranquila': [
      const LexiconEntry('calma', 1.0),
    ],
    'paz': [
      const LexiconEntry('calma', 0.9),
      const LexiconEntry('gratitud', 0.2),
      const LexiconEntry('paz', 1.0),
    ],
    'sereno': [
      const LexiconEntry('calma', 0.95),
    ],
    'relajado': [
      const LexiconEntry('calma', 0.9),
    ],
    'relajada': [
      const LexiconEntry('calma', 0.9),
    ],
    'descanso': [
      const LexiconEntry('calma', 0.7),
      const LexiconEntry('agotamiento', 0.2),
    ],
    'meditar': [
      const LexiconEntry('calma', 0.8),
    ],
    'respirar': [
      const LexiconEntry('calma', 0.6),
      const LexiconEntry('ansiedad', 0.2),
    ],
    'armonia': [
      const LexiconEntry('calma', 0.8),
      const LexiconEntry('felicidad', 0.2),
      const LexiconEntry('paz', 0.5),
    ],
    'equilibrio': [
      const LexiconEntry('calma', 0.7),
      const LexiconEntry('felicidad', 0.2),
    ],
    'silencio': [
      const LexiconEntry('calma', 0.5),
      const LexiconEntry('soledad', 0.2),
    ],
    'meditacion': [
      const LexiconEntry('calma', 0.8),
    ],
    'mindfulness': [
      const LexiconEntry('calma', 0.8),
    ],
    'natureza': [
      const LexiconEntry('calma', 0.5),
    ],
    'naturaleza': [
      const LexiconEntry('calma', 0.5),
    ],
    'mar': [
      const LexiconEntry('calma', 0.5),
      const LexiconEntry('nostalgia', 0.2),
    ],
    'atardecer': [
      const LexiconEntry('calma', 0.5),
      const LexiconEntry('nostalgia', 0.3),
    ],

    'orgulloso': [
      const LexiconEntry('orgullo', 1.0),
      const LexiconEntry('felicidad', 0.3),
    ],
    'orgullosa': [
      const LexiconEntry('orgullo', 1.0),
      const LexiconEntry('felicidad', 0.3),
    ],
    'logro': [
      const LexiconEntry('orgullo', 0.8),
      const LexiconEntry('motivacion', 0.3),
    ],
    'logre': [
      const LexiconEntry('orgullo', 0.9),
      const LexiconEntry('felicidad', 0.4),
    ],
    'consegui': [
      const LexiconEntry('orgullo', 0.8),
      const LexiconEntry('felicidad', 0.3),
    ],
    'superado': [
      const LexiconEntry('orgullo', 0.8),
      const LexiconEntry('motivacion', 0.4),
    ],
    'capaz': [
      const LexiconEntry('orgullo', 0.6),
      const LexiconEntry('motivacion', 0.4),
    ],
    'triunfo': [
      const LexiconEntry('orgullo', 0.9),
      const LexiconEntry('alegria', 0.4),
    ],
    'exito': [
      const LexiconEntry('orgullo', 0.8),
      const LexiconEntry('felicidad', 0.4),
    ],
    'venci': [
      const LexiconEntry('orgullo', 0.9),
      const LexiconEntry('motivacion', 0.3),
    ],
    'lokre': [
      const LexiconEntry('orgullo', 0.9),
      const LexiconEntry('felicidad', 0.4),
    ],

    'motivado': [
      const LexiconEntry('motivacion', 1.0),
      const LexiconEntry('esperanza', 0.3),
    ],
    'motivada': [
      const LexiconEntry('motivacion', 1.0),
      const LexiconEntry('esperanza', 0.3),
    ],
    'empezar': [
      const LexiconEntry('motivacion', 0.6),
      const LexiconEntry('esperanza', 0.3),
    ],
    'comenzar': [
      const LexiconEntry('motivacion', 0.6),
      const LexiconEntry('esperanza', 0.3),
    ],
    'luchar': [
      const LexiconEntry('motivacion', 0.8),
      const LexiconEntry('frustracion', 0.2),
    ],
    'esforzo': [
      const LexiconEntry('motivacion', 0.7),
      const LexiconEntry('agotamiento', 0.2),
    ],
    'avanzar': [
      const LexiconEntry('motivacion', 0.7),
      const LexiconEntry('esperanza', 0.3),
    ],
    'crecer': [
      const LexiconEntry('motivacion', 0.6),
      const LexiconEntry('esperanza', 0.4),
    ],
    'progreso': [
      const LexiconEntry('motivacion', 0.7),
      const LexiconEntry('orgullo', 0.4),
    ],
    'constante': [
      const LexiconEntry('motivacion', 0.5),
    ],
    'disciplina': [
      const LexiconEntry('motivacion', 0.6),
    ],
    'proposito': [
      const LexiconEntry('motivacion', 0.6),
      const LexiconEntry('esperanza', 0.3),
    ],
    'propósito': [
      const LexiconEntry('motivacion', 0.6),
      const LexiconEntry('esperanza', 0.3),
    ],
    'rendirse': [
      const LexiconEntry('motivacion', 0.3),
      const LexiconEntry('desesperanza', 0.4),
    ],
    'rendir': [
      const LexiconEntry('motivacion', 0.3),
      const LexiconEntry('desesperanza', 0.4),
    ],
    'seguir': [
      const LexiconEntry('motivacion', 0.5),
      const LexiconEntry('esperanza', 0.3),
    ],
    'intentar': [
      const LexiconEntry('motivacion', 0.5),
      const LexiconEntry('incertidumbre', 0.2),
    ],
    'poder': [
      const LexiconEntry('motivacion', 0.5),
      const LexiconEntry('orgullo', 0.2),
    ],

    'inspirado': [
      const LexiconEntry('inspiracion', 1.0),
      const LexiconEntry('motivacion', 0.5),
    ],
    'inspirada': [
      const LexiconEntry('inspiracion', 1.0),
      const LexiconEntry('motivacion', 0.5),
    ],
    'creatividad': [
      const LexiconEntry('inspiracion', 0.8),
      const LexiconEntry('motivacion', 0.3),
    ],
    'creativo': [
      const LexiconEntry('inspiracion', 0.7),
      const LexiconEntry('motivacion', 0.3),
    ],
    'ideas': [
      const LexiconEntry('inspiracion', 0.5),
      const LexiconEntry('motivacion', 0.3),
    ],
    'descubrir': [
      const LexiconEntry('inspiracion', 0.6),
      const LexiconEntry('esperanza', 0.3),
    ],
    'aprender': [
      const LexiconEntry('inspiracion', 0.5),
      const LexiconEntry('motivacion', 0.4),
    ],
    'curiosidad': [
      const LexiconEntry('inspiracion', 0.4),
      const LexiconEntry('curiosidad', 1.0),
    ],
    'arte': [
      const LexiconEntry('inspiracion', 0.5),
      const LexiconEntry('calma', 0.2),
    ],
    'musica': [
      const LexiconEntry('inspiracion', 0.4),
      const LexiconEntry('calma', 0.3),
    ],
    'escribir': [
      const LexiconEntry('inspiracion', 0.4),
      const LexiconEntry('calma', 0.2),
    ],
    'poesia': [
      const LexiconEntry('inspiracion', 0.5),
      const LexiconEntry('nostalgia', 0.3),
    ],

    // ── Nuevas emociones ──
    'entusiasmo': [
      const LexiconEntry('entusiasmo', 1.0),
      const LexiconEntry('alegria', 0.4),
    ],
    'entusiasmado': [
      const LexiconEntry('entusiasmo', 1.0),
      const LexiconEntry('alegria', 0.4),
    ],
    'entusiasmada': [
      const LexiconEntry('entusiasmo', 1.0),
      const LexiconEntry('alegria', 0.4),
    ],
    'emocionado': [
      const LexiconEntry('entusiasmo', 0.9),
      const LexiconEntry('alegria', 0.4),
      const LexiconEntry('anticipacion', 0.3),
    ],
    'emocionada': [
      const LexiconEntry('entusiasmo', 0.9),
      const LexiconEntry('alegria', 0.4),
      const LexiconEntry('anticipacion', 0.3),
    ],

    'ternura': [
      const LexiconEntry('ternura', 1.0),
      const LexiconEntry('amor', 0.6),
    ],
    'tierno': [
      const LexiconEntry('ternura', 0.8),
      const LexiconEntry('amor', 0.4),
    ],
    'tierna': [
      const LexiconEntry('ternura', 0.8),
      const LexiconEntry('amor', 0.4),
    ],
    'conmovedor': [
      const LexiconEntry('ternura', 0.7),
      const LexiconEntry('tristeza', 0.2),
    ],
    'conmovedora': [
      const LexiconEntry('ternura', 0.7),
      const LexiconEntry('tristeza', 0.2),
    ],
    'mimo': [
      const LexiconEntry('ternura', 0.6),
      const LexiconEntry('amor', 0.4),
    ],
    'mimos': [
      const LexiconEntry('ternura', 0.6),
      const LexiconEntry('amor', 0.4),
    ],

    'ilusionado': [
      const LexiconEntry('ilusion', 0.9),
      const LexiconEntry('esperanza', 0.4),
      const LexiconEntry('alegria', 0.3),
    ],
    'ilusionada': [
      const LexiconEntry('ilusion', 0.9),
      const LexiconEntry('esperanza', 0.4),
      const LexiconEntry('alegria', 0.3),
    ],

    'alivio': [
      const LexiconEntry('alivio', 1.0),
      const LexiconEntry('calma', 0.4),
    ],
    'aliviado': [
      const LexiconEntry('alivio', 0.9),
      const LexiconEntry('calma', 0.3),
    ],
    'aliviada': [
      const LexiconEntry('alivio', 0.9),
      const LexiconEntry('calma', 0.3),
    ],
    'respiro': [
      const LexiconEntry('alivio', 0.7),
      const LexiconEntry('calma', 0.3),
    ],
    'tranquilidad': [
      const LexiconEntry('calma', 0.6),
      const LexiconEntry('alivio', 0.3),
    ],

    'optimista': [
      const LexiconEntry('optimismo', 0.9),
      const LexiconEntry('esperanza', 0.4),
    ],
    'optimismo': [
      const LexiconEntry('optimismo', 1.0),
      const LexiconEntry('esperanza', 0.3),
    ],
    'positivo': [
      const LexiconEntry('optimismo', 0.5),
      const LexiconEntry('alegria', 0.3),
    ],
    'positiva': [
      const LexiconEntry('optimismo', 0.5),
      const LexiconEntry('alegria', 0.3),
    ],
    'todo saldrá bien': [
      const LexiconEntry('optimismo', 0.9),
      const LexiconEntry('esperanza', 0.6),
    ],
    'todo va a estar bien': [
      const LexiconEntry('optimismo', 0.8),
      const LexiconEntry('esperanza', 0.6),
      const LexiconEntry('calma', 0.3),
    ],
    'salir adelante': [
      const LexiconEntry('optimismo', 0.7),
      const LexiconEntry('esperanza', 0.5),
      const LexiconEntry('motivacion', 0.3),
    ],

    'seguridad': [
      const LexiconEntry('confianza', 0.7),
      const LexiconEntry('calma', 0.3),
    ],
    'seguro de mi': [
      const LexiconEntry('confianza', 0.8),
      const LexiconEntry('orgullo', 0.3),
    ],
    'segura de mi': [
      const LexiconEntry('confianza', 0.8),
      const LexiconEntry('orgullo', 0.3),
    ],
    'creo en mi': [
      const LexiconEntry('confianza', 0.8),
      const LexiconEntry('orgullo', 0.3),
    ],

    'diversión': [
      const LexiconEntry('diversion', 1.0),
      const LexiconEntry('alegria', 0.6),
    ],
    'divertirme': [
      const LexiconEntry('diversion', 0.9),
      const LexiconEntry('alegria', 0.5),
    ],
    'divertida': [
      const LexiconEntry('diversion', 0.8),
      const LexiconEntry('alegria', 0.5),
    ],
    'pasarla bien': [
      const LexiconEntry('diversion', 0.8),
      const LexiconEntry('alegria', 0.5),
    ],
    'me la pasé bien': [
      const LexiconEntry('diversion', 0.9),
      const LexiconEntry('alegria', 0.5),
    ],

    'en paz': [
      const LexiconEntry('paz', 0.9),
      const LexiconEntry('calma', 0.7),
    ],

    'vulnerable': [
      const LexiconEntry('vulnerabilidad', 0.9),
      const LexiconEntry('miedo', 0.3),
    ],
    'expuesto': [
      const LexiconEntry('vulnerabilidad', 0.6),
      const LexiconEntry('miedo', 0.3),
    ],
    'expuesta': [
      const LexiconEntry('vulnerabilidad', 0.6),
      const LexiconEntry('miedo', 0.3),
    ],
    'me siento débil': [
      const LexiconEntry('vulnerabilidad', 0.8),
      const LexiconEntry('agotamiento', 0.3),
    ],

    'irritable': [
      const LexiconEntry('irritabilidad', 0.9),
      const LexiconEntry('enojo', 0.5),
    ],
    'irritabilidad': [
      const LexiconEntry('irritabilidad', 1.0),
      const LexiconEntry('enojo', 0.4),
    ],
    'malhumorado': [
      const LexiconEntry('irritabilidad', 0.8),
      const LexiconEntry('enojo', 0.4),
    ],
    'malhumorada': [
      const LexiconEntry('irritabilidad', 0.8),
      const LexiconEntry('enojo', 0.4),
    ],
    'me molesta todo': [
      const LexiconEntry('irritabilidad', 0.9),
      const LexiconEntry('enojo', 0.4),
    ],
    'todo me molesta': [
      const LexiconEntry('irritabilidad', 0.9),
      const LexiconEntry('enojo', 0.4),
    ],
    'de malas': [
      const LexiconEntry('irritabilidad', 0.8),
      const LexiconEntry('enojo', 0.3),
    ],

    'inseguridad': [
      const LexiconEntry('inseguridad', 1.0),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'dudo de mi': [
      const LexiconEntry('inseguridad', 0.8),
      const LexiconEntry('confusion', 0.3),
    ],
    'no me siento capaz': [
      const LexiconEntry('inseguridad', 0.8),
      const LexiconEntry('frustracion', 0.3),
    ],

    'decepcion': [
      const LexiconEntry('decepcion', 0.9),
      const LexiconEntry('tristeza', 0.5),
    ],
    'me decepcionó': [
      const LexiconEntry('decepcion', 0.9),
      const LexiconEntry('tristeza', 0.4),
    ],
    'me decepciono': [
      const LexiconEntry('decepcion', 0.9),
      const LexiconEntry('tristeza', 0.4),
    ],
    'me falló': [
      const LexiconEntry('decepcion', 0.7),
      const LexiconEntry('tristeza', 0.4),
    ],
    'me fallo': [
      const LexiconEntry('decepcion', 0.7),
      const LexiconEntry('tristeza', 0.4),
    ],
    'desilusionado': [
      const LexiconEntry('decepcion', 0.8),
      const LexiconEntry('tristeza', 0.4),
    ],
    'desilusionada': [
      const LexiconEntry('decepcion', 0.8),
      const LexiconEntry('tristeza', 0.4),
    ],

    'aburrido': [
      const LexiconEntry('aburrimiento', 0.9),
      const LexiconEntry('vacio', 0.3),
    ],
    'aburrida': [
      const LexiconEntry('aburrimiento', 0.9),
      const LexiconEntry('vacio', 0.3),
    ],
    'no hay nada que hacer': [
      const LexiconEntry('aburrimiento', 0.8),
      const LexiconEntry('vacio', 0.3),
    ],

    'melancolico': [
      const LexiconEntry('melancolia', 0.8),
      const LexiconEntry('nostalgia', 0.4),
      const LexiconEntry('tristeza', 0.3),
    ],
    'melancólico': [
      const LexiconEntry('melancolia', 0.8),
      const LexiconEntry('nostalgia', 0.4),
      const LexiconEntry('tristeza', 0.3),
    ],
    'melancólica': [
      const LexiconEntry('melancolia', 0.8),
      const LexiconEntry('nostalgia', 0.4),
      const LexiconEntry('tristeza', 0.3),
    ],

    'curioso': [
      const LexiconEntry('curiosidad', 0.9),
      const LexiconEntry('inspiracion', 0.3),
    ],
    'curiosa': [
      const LexiconEntry('curiosidad', 0.9),
      const LexiconEntry('inspiracion', 0.3),
    ],
    'me intriga': [
      const LexiconEntry('curiosidad', 0.8),
      const LexiconEntry('anticipacion', 0.3),
    ],
    'me da curiosidad': [
      const LexiconEntry('curiosidad', 0.9),
    ],

    'anticipacion': [
      const LexiconEntry('anticipacion', 1.0),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'no veo la hora': [
      const LexiconEntry('anticipacion', 0.9),
      const LexiconEntry('entusiasmo', 0.4),
    ],
    'no puedo esperar': [
      const LexiconEntry('anticipacion', 0.9),
      const LexiconEntry('entusiasmo', 0.4),
    ],
    'impaciente': [
      const LexiconEntry('anticipacion', 0.7),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'impaciencia': [
      const LexiconEntry('anticipacion', 0.7),
      const LexiconEntry('ansiedad', 0.3),
    ],

    'normal': [
      const LexiconEntry('neutral', 0.5),
    ],
    'indiferente': [
      const LexiconEntry('neutral', 0.7),
      const LexiconEntry('vacio', 0.3),
    ],
    'sin más': [
      const LexiconEntry('neutral', 0.5),
    ],

    // ── Negativas ──
    'triste': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('soledad', 0.2),
    ],
    'tristeza': [
      const LexiconEntry('tristeza', 1.0),
    ],
    'mal': [
      const LexiconEntry('tristeza', 0.6),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'fatal': [
      const LexiconEntry('tristeza', 0.6),
      const LexiconEntry('agotamiento', 0.3),
    ],
    'murió': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'murio': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'muerte': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.2),
    ],
    'falleció': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'fallecio': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'duelo': [
      const LexiconEntry('tristeza', 1.0),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'funeral': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('nostalgia', 0.3),
    ],
    'entierro': [
      const LexiconEntry('tristeza', 0.9),
    ],
    'despedida': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('nostalgia', 0.4),
    ],
    'hospital': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('ansiedad', 0.4),
    ],
    'cáncer': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('miedo', 0.4),
    ],
    'cancer': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('miedo', 0.4),
    ],
    'accidente': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('miedo', 0.3),
    ],
    'ruptura': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('soledad', 0.3),
    ],
    'divorcio': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('soledad', 0.3),
    ],
    'despedido': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('frustracion', 0.4),
    ],
    'despedida laboral': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'llorar': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.2),
    ],
    'llanto': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.2),
    ],
    'pena': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('nostalgia', 0.3),
    ],
    'dolor': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('frustracion', 0.3),
    ],
    'llorando': [
      const LexiconEntry('tristeza', 0.95),
    ],
    'melancolia': [
      const LexiconEntry('tristeza', 0.4),
      const LexiconEntry('nostalgia', 0.5),
      const LexiconEntry('melancolia', 1.0),
    ],
    'deprimido': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'deprimida': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'lloré': [
      const LexiconEntry('tristeza', 0.9),
    ],
    'perder': [
      const LexiconEntry('tristeza', 0.6),
      const LexiconEntry('nostalgia', 0.3),
    ],
    'perdido': [
      const LexiconEntry('tristeza', 0.6),
      const LexiconEntry('confusion', 0.4),
    ],
    'perdida': [
      const LexiconEntry('tristeza', 0.6),
      const LexiconEntry('confusion', 0.4),
    ],
    'abatido': [
      const LexiconEntry('tristeza', 0.8),
    ],
    'abatida': [
      const LexiconEntry('tristeza', 0.8),
    ],
    'sentir mal': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('frustracion', 0.3),
    ],
    'me siento mal': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'me siento vacio': [
      const LexiconEntry('vacio', 1.0),
      const LexiconEntry('tristeza', 0.4),
    ],
    'me siento vacía': [
      const LexiconEntry('vacio', 1.0),
      const LexiconEntry('tristeza', 0.4),
    ],
    'me siento roto': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.5),
      const LexiconEntry('vacio', 0.4),
    ],
    'me siento rota': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.5),
      const LexiconEntry('vacio', 0.4),
    ],
    'no tengo ganas': [
      const LexiconEntry('agotamiento', 0.7),
      const LexiconEntry('burnout', 0.5),
      const LexiconEntry('vacio', 0.4),
    ],
    'sin ganas': [
      const LexiconEntry('agotamiento', 0.7),
      const LexiconEntry('vacio', 0.4),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'extraño mucho': [
      const LexiconEntry('nostalgia', 1.0),
      const LexiconEntry('tristeza', 0.5),
    ],
    'todo me da igual': [
      const LexiconEntry('vacio', 0.8),
      const LexiconEntry('desesperanza', 0.6),
      const LexiconEntry('apathy', 0.5),
    ],
    'no encuentro sentido': [
      const LexiconEntry('desesperanza', 0.8),
      const LexiconEntry('vacio', 0.7),
    ],
    'sin rumbo': [
      const LexiconEntry('incertidumbre', 0.7),
      const LexiconEntry('confusion', 0.5),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'no valgo': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('desesperanza', 0.6),
    ],
    'no sirvo': [
      const LexiconEntry('tristeza', 0.7),
      const LexiconEntry('frustracion', 0.5),
      const LexiconEntry('desesperanza', 0.5),
    ],
    'no merezco': [
      const LexiconEntry('culpa', 0.7),
      const LexiconEntry('tristeza', 0.5),
    ],
    'quiero llorar': [
      const LexiconEntry('tristeza', 0.9),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'no quiero hacer nada': [
      const LexiconEntry('agotamiento', 0.7),
      const LexiconEntry('burnout', 0.5),
      const LexiconEntry('vacio', 0.4),
    ],

    'solo': [
      const LexiconEntry('soledad', 0.9),
      const LexiconEntry('tristeza', 0.3),
    ],
    'sola': [
      const LexiconEntry('soledad', 0.9),
      const LexiconEntry('tristeza', 0.3),
    ],
    'soledad': [
      const LexiconEntry('soledad', 1.0),
    ],
    'aislado': [
      const LexiconEntry('soledad', 0.8),
    ],
    'aislada': [
      const LexiconEntry('soledad', 0.8),
    ],
    'abandonado': [
      const LexiconEntry('soledad', 0.9),
      const LexiconEntry('tristeza', 0.4),
    ],
    'abandonada': [
      const LexiconEntry('soledad', 0.9),
      const LexiconEntry('tristeza', 0.4),
    ],
    'olvidado': [
      const LexiconEntry('soledad', 0.7),
      const LexiconEntry('tristeza', 0.4),
    ],
    'olvidada': [
      const LexiconEntry('soledad', 0.7),
      const LexiconEntry('tristeza', 0.4),
    ],
    'desconectado': [
      const LexiconEntry('soledad', 0.7),
      const LexiconEntry('confusion', 0.2),
    ],
    'desconectada': [
      const LexiconEntry('soledad', 0.7),
      const LexiconEntry('confusion', 0.2),
    ],
    'nadie': [
      const LexiconEntry('soledad', 0.5),
    ],
    'sin amigos': [
      const LexiconEntry('soledad', 0.8),
    ],
    'no me entiende': [
      const LexiconEntry('soledad', 0.7),
    ],
    'no me comprende': [
      const LexiconEntry('soledad', 0.7),
    ],

    'vacio': [
      const LexiconEntry('vacio', 1.0),
      const LexiconEntry('tristeza', 0.3),
    ],
    'vacío': [
      const LexiconEntry('vacio', 1.0),
      const LexiconEntry('tristeza', 0.3),
    ],
    'sin sentido': [
      const LexiconEntry('vacio', 0.9),
      const LexiconEntry('desesperanza', 0.4),
    ],
    'nada': [
      const LexiconEntry('vacio', 0.5),
      const LexiconEntry('tristeza', 0.2),
    ],
    'hueco': [
      const LexiconEntry('vacio', 0.8),
    ],
    'apagado': [
      const LexiconEntry('vacio', 0.7),
      const LexiconEntry('agotamiento', 0.3),
    ],
    'apagada': [
      const LexiconEntry('vacio', 0.7),
      const LexiconEntry('agotamiento', 0.3),
    ],
    'insípido': [
      const LexiconEntry('vacio', 0.6),
    ],
    'monótono': [
      const LexiconEntry('vacio', 0.5),
      const LexiconEntry('aburrimiento', 0.6),
    ],
    'monotonía': [
      const LexiconEntry('vacio', 0.5),
    ],
    'aburrimiento': [
      const LexiconEntry('vacio', 0.3),
      const LexiconEntry('aburrimiento', 0.9),
    ],

    'desesperanza': [
      const LexiconEntry('desesperanza', 1.0),
      const LexiconEntry('tristeza', 0.4),
    ],
    'sin esperanza': [
      const LexiconEntry('desesperanza', 0.95),
    ],
    'no tiene sentido': [
      const LexiconEntry('desesperanza', 0.8),
      const LexiconEntry('vacio', 0.3),
    ],
    'ya no puedo': [
      const LexiconEntry('desesperanza', 0.8),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'no aguanto': [
      const LexiconEntry('desesperanza', 0.7),
      const LexiconEntry('frustracion', 0.4),
    ],
    'rendido': [
      const LexiconEntry('desesperanza', 0.7),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'rendida': [
      const LexiconEntry('desesperanza', 0.7),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'sin salida': [
      const LexiconEntry('desesperanza', 0.9),
    ],
    'imposible': [
      const LexiconEntry('desesperanza', 0.6),
      const LexiconEntry('frustracion', 0.3),
    ],
    'depresion': [
      const LexiconEntry('desesperanza', 0.8),
      const LexiconEntry('tristeza', 0.7),
    ],

    'ansioso': [
      const LexiconEntry('ansiedad', 1.0),
      const LexiconEntry('estres', 0.4),
    ],
    'ansiosa': [
      const LexiconEntry('ansiedad', 1.0),
      const LexiconEntry('estres', 0.4),
    ],
    'ansiedad': [
      const LexiconEntry('ansiedad', 1.0),
    ],
    'preocupado': [
      const LexiconEntry('ansiedad', 0.8),
      const LexiconEntry('miedo', 0.3),
    ],
    'preocupada': [
      const LexiconEntry('ansiedad', 0.8),
      const LexiconEntry('miedo', 0.3),
    ],
    'nervioso': [
      const LexiconEntry('ansiedad', 0.8),
      const LexiconEntry('miedo', 0.2),
    ],
    'nerviosa': [
      const LexiconEntry('ansiedad', 0.8),
      const LexiconEntry('miedo', 0.2),
    ],
    'panico': [
      const LexiconEntry('ansiedad', 0.9),
      const LexiconEntry('miedo', 0.7),
    ],
    'angustia': [
      const LexiconEntry('ansiedad', 0.85),
      const LexiconEntry('tristeza', 0.3),
    ],
    'angustiado': [
      const LexiconEntry('ansiedad', 0.85),
      const LexiconEntry('tristeza', 0.3),
    ],
    'angustiada': [
      const LexiconEntry('ansiedad', 0.85),
      const LexiconEntry('tristeza', 0.3),
    ],
    'pensamientos': [
      const LexiconEntry('ansiedad', 0.3),
      const LexiconEntry('confusion', 0.2),
    ],
    'no puedo dormir': [
      const LexiconEntry('ansiedad', 0.8),
      const LexiconEntry('estres', 0.4),
    ],
    'insomnio': [
      const LexiconEntry('ansiedad', 0.7),
      const LexiconEntry('estres', 0.5),
    ],
    'palpitaciones': [
      const LexiconEntry('ansiedad', 0.8),
    ],
    'taquicardia': [
      const LexiconEntry('ansiedad', 0.8),
    ],
    'mareo': [
      const LexiconEntry('ansiedad', 0.5),
      const LexiconEntry('agotamiento', 0.3),
    ],
    'ataque de panico': [
      const LexiconEntry('ansiedad', 0.95),
      const LexiconEntry('miedo', 0.5),
    ],
    'inquieto': [
      const LexiconEntry('ansiedad', 0.7),
    ],
    'inquieta': [
      const LexiconEntry('ansiedad', 0.7),
    ],
    'tenso': [
      const LexiconEntry('ansiedad', 0.6),
      const LexiconEntry('estres', 0.5),
    ],
    'tensa': [
      const LexiconEntry('ansiedad', 0.6),
      const LexiconEntry('estres', 0.5),
    ],
    'ahogo': [
      const LexiconEntry('ansiedad', 0.7),
    ],
    'ahogada': [
      const LexiconEntry('ansiedad', 0.7),
    ],
    'acelerado': [
      const LexiconEntry('ansiedad', 0.7),
      const LexiconEntry('estres', 0.4),
    ],
    'acelerada': [
      const LexiconEntry('ansiedad', 0.7),
      const LexiconEntry('estres', 0.4),
    ],
    'abrumado': [
      const LexiconEntry('ansiedad', 0.6),
      const LexiconEntry('estres', 0.5),
    ],
    'abrumada': [
      const LexiconEntry('ansiedad', 0.6),
      const LexiconEntry('estres', 0.5),
    ],

    'estresado': [
      const LexiconEntry('estres', 1.0),
      const LexiconEntry('ansiedad', 0.4),
    ],
    'estresada': [
      const LexiconEntry('estres', 1.0),
      const LexiconEntry('ansiedad', 0.4),
    ],
    'estres': [
      const LexiconEntry('estres', 1.0),
    ],
    'estrés': [
      const LexiconEntry('estres', 1.0),
    ],
    'presion': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'presión': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'sobrecargado': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'sobrecargada': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'trabajo': [
      const LexiconEntry('estres', 0.3),
    ],
    'deadline': [
      const LexiconEntry('estres', 0.7),
    ],
    'examen': [
      const LexiconEntry('estres', 0.5),
      const LexiconEntry('ansiedad', 0.4),
    ],
    'exámenes': [
      const LexiconEntry('estres', 0.5),
      const LexiconEntry('ansiedad', 0.4),
    ],
    'urgencia': [
      const LexiconEntry('estres', 0.6),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'colapso': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('ansiedad', 0.5),
    ],
    'desbordado': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'desbordada': [
      const LexiconEntry('estres', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],

    'miedo': [
      const LexiconEntry('miedo', 1.0),
    ],
    'asustado': [
      const LexiconEntry('miedo', 0.9),
    ],
    'asustada': [
      const LexiconEntry('miedo', 0.9),
    ],
    'temor': [
      const LexiconEntry('miedo', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'temo': [
      const LexiconEntry('miedo', 0.8),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'terror': [
      const LexiconEntry('miedo', 0.95),
    ],
    'horror': [
      const LexiconEntry('miedo', 0.9),
    ],
    'amenaza': [
      const LexiconEntry('miedo', 0.7),
    ],
    'peligro': [
      const LexiconEntry('miedo', 0.7),
    ],
    'riesgo': [
      const LexiconEntry('miedo', 0.5),
      const LexiconEntry('ansiedad', 0.3),
    ],
    'inseguro': [
      const LexiconEntry('miedo', 0.6),
      const LexiconEntry('ansiedad', 0.3),
      const LexiconEntry('inseguridad', 0.9),
    ],
    'insegura': [
      const LexiconEntry('miedo', 0.6),
      const LexiconEntry('ansiedad', 0.3),
      const LexiconEntry('inseguridad', 0.9),
    ],
    'vulnerabilidad': [
      const LexiconEntry('miedo', 0.5),
      const LexiconEntry('ansiedad', 0.3),
      const LexiconEntry('vulnerabilidad', 1.0),
    ],
    'acosado': [
      const LexiconEntry('miedo', 0.8),
    ],
    'acosada': [
      const LexiconEntry('miedo', 0.8),
    ],
    'amenazado': [
      const LexiconEntry('miedo', 0.8),
    ],
    'amenazada': [
      const LexiconEntry('miedo', 0.8),
    ],

    'frustrado': [
      const LexiconEntry('frustracion', 1.0),
      const LexiconEntry('enojo', 0.3),
    ],
    'frustrada': [
      const LexiconEntry('frustracion', 1.0),
      const LexiconEntry('enojo', 0.3),
    ],
    'frustración': [
      const LexiconEntry('frustracion', 1.0),
    ],
    'frustracion': [
      const LexiconEntry('frustracion', 1.0),
    ],
    'impotente': [
      const LexiconEntry('frustracion', 0.8),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'impotencia': [
      const LexiconEntry('frustracion', 0.8),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'bloqueado': [
      const LexiconEntry('frustracion', 0.7),
      const LexiconEntry('confusion', 0.3),
    ],
    'bloqueada': [
      const LexiconEntry('frustracion', 0.7),
      const LexiconEntry('confusion', 0.3),
    ],
    'no logro': [
      const LexiconEntry('frustracion', 0.7),
    ],
    'no puedo': [
      const LexiconEntry('frustracion', 0.5),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'fracaso': [
      const LexiconEntry('frustracion', 0.8),
      const LexiconEntry('tristeza', 0.3),
    ],
    'fracasé': [
      const LexiconEntry('frustracion', 0.8),
      const LexiconEntry('tristeza', 0.3),
    ],
    'error': [
      const LexiconEntry('frustracion', 0.5),
    ],
    'equivocar': [
      const LexiconEntry('frustracion', 0.5),
    ],
    'equivocado': [
      const LexiconEntry('frustracion', 0.5),
    ],
    'estancado': [
      const LexiconEntry('frustracion', 0.7),
    ],
    'estancada': [
      const LexiconEntry('frustracion', 0.7),
    ],
    'atascado': [
      const LexiconEntry('frustracion', 0.7),
    ],

    'enojado': [
      const LexiconEntry('enojo', 1.0),
    ],
    'enojada': [
      const LexiconEntry('enojo', 1.0),
    ],
    'furioso': [
      const LexiconEntry('enojo', 0.95),
    ],
    'furiosa': [
      const LexiconEntry('enojo', 0.95),
    ],
    'rabia': [
      const LexiconEntry('enojo', 0.9),
    ],
    'odio': [
      const LexiconEntry('enojo', 0.9),
    ],
    'irritado': [
      const LexiconEntry('enojo', 0.7),
      const LexiconEntry('estres', 0.2),
    ],
    'irritada': [
      const LexiconEntry('enojo', 0.7),
      const LexiconEntry('estres', 0.2),
    ],
    'molesto': [
      const LexiconEntry('enojo', 0.7),
    ],
    'molesta': [
      const LexiconEntry('enojo', 0.7),
    ],
    'indignado': [
      const LexiconEntry('enojo', 0.8),
    ],
    'indignada': [
      const LexiconEntry('enojo', 0.8),
    ],
    'injusto': [
      const LexiconEntry('enojo', 0.7),
      const LexiconEntry('frustracion', 0.3),
    ],
    'injusticia': [
      const LexiconEntry('enojo', 0.7),
      const LexiconEntry('frustracion', 0.3),
    ],
    'hartado': [
      const LexiconEntry('enojo', 0.7),
    ],
    'hartada': [
      const LexiconEntry('enojo', 0.7),
    ],
    'harto': [
      const LexiconEntry('enojo', 0.6),
    ],
    'arta': [
      const LexiconEntry('enojo', 0.6),
    ],
    'gritar': [
      const LexiconEntry('enojo', 0.7),
    ],
    'gritando': [
      const LexiconEntry('enojo', 0.8),
    ],
    'grito': [
      const LexiconEntry('enojo', 0.7),
    ],

    'culpa': [
      const LexiconEntry('culpa', 1.0),
    ],
    'culpable': [
      const LexiconEntry('culpa', 1.0),
    ],
    'arrepentido': [
      const LexiconEntry('culpa', 0.9),
      const LexiconEntry('tristeza', 0.2),
    ],
    'arrepentida': [
      const LexiconEntry('culpa', 0.9),
      const LexiconEntry('tristeza', 0.2),
    ],
    'arrepentimiento': [
      const LexiconEntry('culpa', 0.9),
    ],
    'me equivoqué': [
      const LexiconEntry('culpa', 0.8),
      const LexiconEntry('frustracion', 0.3),
    ],
    'perdon': [
      const LexiconEntry('culpa', 0.6),
      const LexiconEntry('esperanza', 0.2),
    ],
    'perdón': [
      const LexiconEntry('culpa', 0.6),
      const LexiconEntry('esperanza', 0.2),
    ],
    'culpar': [
      const LexiconEntry('culpa', 0.7),
    ],
    'responsable': [
      const LexiconEntry('culpa', 0.5),
      const LexiconEntry('estres', 0.2),
    ],
    'lastimé': [
      const LexiconEntry('culpa', 0.8),
    ],
    'dañé': [
      const LexiconEntry('culpa', 0.8),
    ],
    'decepcioné': [
      const LexiconEntry('culpa', 0.8),
      const LexiconEntry('tristeza', 0.3),
    ],
    'decepcionado': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('desesperanza', 0.3),
      const LexiconEntry('decepcion', 0.8),
    ],
    'decepcionada': [
      const LexiconEntry('tristeza', 0.8),
      const LexiconEntry('desesperanza', 0.3),
      const LexiconEntry('decepcion', 0.8),
    ],

    'vergüenza': [
      const LexiconEntry('vergüenza', 1.0),
    ],
    'vergonza': [
      const LexiconEntry('vergüenza', 1.0),
    ],
    'avergonzado': [
      const LexiconEntry('vergüenza', 0.9),
    ],
    'avergonzada': [
      const LexiconEntry('vergüenza', 0.9),
    ],
    'humillado': [
      const LexiconEntry('vergüenza', 0.9),
      const LexiconEntry('enojo', 0.2),
    ],
    'humillada': [
      const LexiconEntry('vergüenza', 0.9),
      const LexiconEntry('enojo', 0.2),
    ],
    'humillacion': [
      const LexiconEntry('vergüenza', 0.9),
    ],
    'exponer': [
      const LexiconEntry('vergüenza', 0.5),
      const LexiconEntry('miedo', 0.3),
    ],
    'ridiculo': [
      const LexiconEntry('vergüenza', 0.8),
    ],
    'tímido': [
      const LexiconEntry('vergüenza', 0.4),
      const LexiconEntry('miedo', 0.3),
    ],
    'timidez': [
      const LexiconEntry('vergüenza', 0.5),
      const LexiconEntry('miedo', 0.3),
    ],
    'juzgado': [
      const LexiconEntry('vergüenza', 0.6),
      const LexiconEntry('miedo', 0.3),
    ],
    'juzgada': [
      const LexiconEntry('vergüenza', 0.6),
      const LexiconEntry('miedo', 0.3),
    ],

    'confundido': [
      const LexiconEntry('confusion', 1.0),
    ],
    'confundida': [
      const LexiconEntry('confusion', 1.0),
    ],
    'confusión': [
      const LexiconEntry('confusion', 1.0),
    ],
    'confusion': [
      const LexiconEntry('confusion', 1.0),
    ],
    'duda': [
      const LexiconEntry('confusion', 0.6),
      const LexiconEntry('incertidumbre', 0.5),
    ],
    'dudas': [
      const LexiconEntry('confusion', 0.6),
      const LexiconEntry('incertidumbre', 0.5),
    ],
    'no entiendo': [
      const LexiconEntry('confusion', 0.8),
    ],
    'no comprendo': [
      const LexiconEntry('confusion', 0.8),
    ],
    'desorientado': [
      const LexiconEntry('confusion', 0.8),
    ],
    'desorientada': [
      const LexiconEntry('confusion', 0.8),
    ],
    'contradictorio': [
      const LexiconEntry('confusion', 0.6),
    ],
    'ambiguo': [
      const LexiconEntry('confusion', 0.5),
      const LexiconEntry('incertidumbre', 0.4),
    ],
    'complicado': [
      const LexiconEntry('confusion', 0.5),
      const LexiconEntry('frustracion', 0.3),
    ],
    'raro': [
      const LexiconEntry('confusion', 0.5),
      const LexiconEntry('incertidumbre', 0.3),
    ],
    'rara': [
      const LexiconEntry('confusion', 0.5),
      const LexiconEntry('incertidumbre', 0.3),
    ],

    'agotado': [
      const LexiconEntry('agotamiento', 1.0),
      const LexiconEntry('estres', 0.3),
    ],
    'agotada': [
      const LexiconEntry('agotamiento', 1.0),
      const LexiconEntry('estres', 0.3),
    ],
    'cansado': [
      const LexiconEntry('agotamiento', 0.8),
      const LexiconEntry('cansancio', 0.7),
    ],
    'cansada': [
      const LexiconEntry('agotamiento', 0.8),
      const LexiconEntry('cansancio', 0.7),
    ],
    'sin energía': [
      const LexiconEntry('agotamiento', 0.9),
    ],
    'sin energia': [
      const LexiconEntry('agotamiento', 0.9),
    ],
    'extenuado': [
      const LexiconEntry('agotamiento', 0.95),
    ],
    'extenuada': [
      const LexiconEntry('agotamiento', 0.95),
    ],
    'dormido': [
      const LexiconEntry('agotamiento', 0.5),
    ],
    'dormida': [
      const LexiconEntry('agotamiento', 0.5),
    ],
    'agotador': [
      const LexiconEntry('agotamiento', 0.8),
      const LexiconEntry('estres', 0.4),
    ],
    'agotadora': [
      const LexiconEntry('agotamiento', 0.8),
      const LexiconEntry('estres', 0.4),
    ],
    'desgastado': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'desgastada': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'sin fuerzas': [
      const LexiconEntry('agotamiento', 0.9),
    ],
    'no puedo más': [
      const LexiconEntry('agotamiento', 0.8),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'drenado': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'drenada': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'mamado': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'mamada': [
      const LexiconEntry('agotamiento', 0.8),
    ],
    'cansancio': [
      const LexiconEntry('agotamiento', 0.4),
      const LexiconEntry('cansancio', 0.9),
    ],
    'fatiga': [
      const LexiconEntry('agotamiento', 0.85),
      const LexiconEntry('cansancio', 0.5),
    ],
    'exhausto': [
      const LexiconEntry('agotamiento', 0.95),
    ],
    'exhausta': [
      const LexiconEntry('agotamiento', 0.95),
    ],

    'burnout': [
      const LexiconEntry('burnout', 1.0),
      const LexiconEntry('agotamiento', 0.6),
      const LexiconEntry('desesperanza', 0.2),
    ],
    'desgaste': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'quemado': [
      const LexiconEntry('burnout', 0.9),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'quemada': [
      const LexiconEntry('burnout', 0.9),
      const LexiconEntry('agotamiento', 0.5),
    ],
    'saturado': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('estres', 0.4),
    ],
    'saturada': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('estres', 0.4),
    ],
    'pereza': [
      const LexiconEntry('burnout', 0.5),
      const LexiconEntry('desesperanza', 0.2),
    ],
    'desmotivado': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'desmotivada': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('desesperanza', 0.3),
    ],
    'agobiado': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('estres', 0.5),
    ],
    'agobiada': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('estres', 0.5),
    ],
    'explotar': [
      const LexiconEntry('burnout', 0.6),
      const LexiconEntry('estres', 0.5),
    ],
    'explotando': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('estres', 0.5),
    ],
    'no aguanto más': [
      const LexiconEntry('burnout', 0.8),
      const LexiconEntry('desesperanza', 0.4),
    ],
    'hartazgo': [
      const LexiconEntry('burnout', 0.7),
      const LexiconEntry('enojo', 0.3),
    ],
    'crujir': [
      const LexiconEntry('burnout', 0.5),
      const LexiconEntry('agotamiento', 0.4),
    ],

    'nostalgia': [
      const LexiconEntry('nostalgia', 1.0),
      const LexiconEntry('tristeza', 0.3),
    ],
    'recordar': [
      const LexiconEntry('nostalgia', 0.6),
      const LexiconEntry('tristeza', 0.2),
    ],
    'recuerdo': [
      const LexiconEntry('nostalgia', 0.6),
      const LexiconEntry('tristeza', 0.2),
    ],
    'recuerdos': [
      const LexiconEntry('nostalgia', 0.6),
    ],
    'extrañar': [
      const LexiconEntry('nostalgia', 0.8),
      const LexiconEntry('tristeza', 0.4),
    ],
    'extraño': [
      const LexiconEntry('nostalgia', 0.7),
      const LexiconEntry('tristeza', 0.3),
    ],
    'extraña': [
      const LexiconEntry('nostalgia', 0.7),
      const LexiconEntry('tristeza', 0.3),
    ],
    'época': [
      const LexiconEntry('nostalgia', 0.4),
    ],
    'antes': [
      const LexiconEntry('nostalgia', 0.3),
    ],
    'infancia': [
      const LexiconEntry('nostalgia', 0.6),
      const LexiconEntry('felicidad', 0.2),
    ],
    'pasado': [
      const LexiconEntry('nostalgia', 0.4),
    ],
    'tiempo': [
      const LexiconEntry('nostalgia', 0.2),
    ],
    'viejos tiempos': [
      const LexiconEntry('nostalgia', 0.8),
    ],
    'aquel entonces': [
      const LexiconEntry('nostalgia', 0.7),
    ],
    'sobran': [
      const LexiconEntry('nostalgia', 0.3),
      const LexiconEntry('tristeza', 0.2),
    ],
    'añoranza': [
      const LexiconEntry('nostalgia', 0.9),
      const LexiconEntry('tristeza', 0.3),
      const LexiconEntry('melancolia', 0.5),
    ],

    'incertidumbre': [
      const LexiconEntry('incertidumbre', 1.0),
    ],
    'no sé': [
      const LexiconEntry('incertidumbre', 0.7),
      const LexiconEntry('confusion', 0.3),
    ],
    'no estoy seguro': [
      const LexiconEntry('incertidumbre', 0.8),
    ],
    'no estoy segura': [
      const LexiconEntry('incertidumbre', 0.8),
    ],
    'desconocido': [
      const LexiconEntry('incertidumbre', 0.6),
    ],
    'desconocida': [
      const LexiconEntry('incertidumbre', 0.6),
    ],
    'impredecible': [
      const LexiconEntry('incertidumbre', 0.7),
    ],
    'cambiar': [
      const LexiconEntry('incertidumbre', 0.3),
      const LexiconEntry('esperanza', 0.2),
    ],
    'cambio': [
      const LexiconEntry('incertidumbre', 0.3),
      const LexiconEntry('esperanza', 0.2),
    ],
    'dudar': [
      const LexiconEntry('incertidumbre', 0.7),
    ],
    'título': [
      const LexiconEntry('incertidumbre', 0.4),
    ],
    'camino': [
      const LexiconEntry('incertidumbre', 0.3),
      const LexiconEntry('esperanza', 0.2),
    ],
    'decidir': [
      const LexiconEntry('incertidumbre', 0.5),
    ],
    'opciones': [
      const LexiconEntry('incertidumbre', 0.4),
    ],
    'que hacer': [
      const LexiconEntry('incertidumbre', 0.6),
    ],
  };

  static const List<String> negationWords = [
    'no',
    'nunca',
    'nadie',
    'nada',
    'ni',
    'jamás',
    'jamas',
    'tampoco',
    'sin',
    'nulo',
    'nula',
  ];

  static const Map<String, double> intensifiers = {
    'muy': 1.3,
    'súper': 1.4,
    'super': 1.4,
    'hiper': 1.4,
    'extremadamente': 1.5,
    'bastante': 1.2,
    'realmente': 1.3,
    'totalmente': 1.4,
    'completamente': 1.4,
    'absolutamente': 1.5,
    'demasiado': 1.4,
    'enormemente': 1.5,
    'sumamente': 1.4,
    'mucho': 1.3,
    'muchísimo': 1.5,
    'muchisimo': 1.5,
    'tanto': 1.3,
    'increíblemente': 1.4,
    'increiblemente': 1.4,
    'fuertemente': 1.3,
    'intensamente': 1.4,
    'profundamente': 1.4,
    'un montón': 1.4,
    'un monton': 1.4,
    'terriblemente': 1.5,
  };

  static const Map<String, double> diminishers = {
    'un poco': 0.6,
    'algo': 0.7,
    'apenas': 0.5,
    'ligeramente': 0.5,
    'medianamente': 0.6,
    'más o menos': 0.5,
    'mas o menos': 0.5,
    'razonablemente': 0.7,
    'casi': 0.7,
    'poco': 0.5,
    'un poquito': 0.4,
    'poquito': 0.5,
    'relativamente': 0.7,
    'levemente': 0.5,
    'no tanto': 0.6,
  };

  static Map<String, List<LexiconEntry>> get keywords => _keywords;

  static List<String> getKeywordList() => _keywords.keys.toList();
}

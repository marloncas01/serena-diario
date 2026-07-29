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
      LexiconEntry('alegria', 1.0),
      LexiconEntry('felicidad', 0.5),
      LexiconEntry('motivacion', 0.2),
    ],
    'feliz': [
      LexiconEntry('felicidad', 1.0),
      LexiconEntry('alegria', 0.6),
      LexiconEntry('calma', 0.15),
    ],
    'contento': [
      LexiconEntry('felicidad', 0.9),
      LexiconEntry('alegria', 0.7),
    ],
    'alegre': [
      LexiconEntry('alegria', 1.0),
      LexiconEntry('felicidad', 0.6),
    ],
    'genial': [
      LexiconEntry('alegria', 0.9),
      LexiconEntry('felicidad', 0.8),
      LexiconEntry('motivacion', 0.3),
    ],
    'increible': [
      LexiconEntry('alegria', 0.8),
      LexiconEntry('felicidad', 0.7),
      LexiconEntry('inspiracion', 0.3),
    ],
    'maravilloso': [
      LexiconEntry('felicidad', 0.9),
      LexiconEntry('gratitud', 0.4),
      LexiconEntry('inspiracion', 0.3),
    ],
    'fantastico': [
      LexiconEntry('alegria', 0.85),
      LexiconEntry('felicidad', 0.75),
    ],
    'excelente': [
      LexiconEntry('alegria', 0.8),
      LexiconEntry('felicidad', 0.7),
      LexiconEntry('orgullo', 0.3),
    ],
    'bien': [
      LexiconEntry('felicidad', 0.4),
      LexiconEntry('calma', 0.3),
    ],
    'divertido': [
      LexiconEntry('alegria', 0.8),
      LexiconEntry('felicidad', 0.6),
    ],
    'reir': [
      LexiconEntry('alegria', 0.9),
      LexiconEntry('felicidad', 0.5),
    ],
    'sonreir': [
      LexiconEntry('alegria', 0.85),
      LexiconEntry('felicidad', 0.5),
    ],
    'celebrar': [
      LexiconEntry('alegria', 0.8),
      LexiconEntry('felicidad', 0.7),
      LexiconEntry('orgullo', 0.3),
    ],
    'bailar': [
      LexiconEntry('alegria', 0.7),
      LexiconEntry('felicidad', 0.6),
    ],
    'fiesta': [
      LexiconEntry('alegria', 0.6),
      LexiconEntry('felicidad', 0.5),
    ],

    'amor': [
      LexiconEntry('amor', 1.0),
      LexiconEntry('felicidad', 0.3),
      LexiconEntry('gratitud', 0.2),
    ],
    'amar': [
      LexiconEntry('amor', 1.0),
      LexiconEntry('felicidad', 0.3),
    ],
    'querer': [
      LexiconEntry('amor', 0.7),
      LexiconEntry('felicidad', 0.2),
    ],
    'cariño': [
      LexiconEntry('amor', 0.9),
      LexiconEntry('calma', 0.3),
    ],
    'abrazo': [
      LexiconEntry('amor', 0.8),
      LexiconEntry('calma', 0.4),
      LexiconEntry('gratitud', 0.2),
    ],
    'beso': [
      LexiconEntry('amor', 0.8),
      LexiconEntry('felicidad', 0.3),
    ],
    'pareja': [
      LexiconEntry('amor', 0.6),
      LexiconEntry('felicidad', 0.3),
    ],
    'corazon': [
      LexiconEntry('amor', 0.7),
      LexiconEntry('felicidad', 0.3),
    ],
    'enamorado': [
      LexiconEntry('amor', 1.0),
      LexiconEntry('alegria', 0.4),
    ],
    'amiga': [
      LexiconEntry('amor', 0.4),
      LexiconEntry('gratitud', 0.3),
      LexiconEntry('felicidad', 0.3),
    ],
    'amigo': [
      LexiconEntry('amor', 0.4),
      LexiconEntry('gratitud', 0.3),
      LexiconEntry('felicidad', 0.3),
    ],
    'hijo': [
      LexiconEntry('amor', 0.6),
      LexiconEntry('felicidad', 0.3),
    ],
    'hija': [
      LexiconEntry('amor', 0.6),
      LexiconEntry('felicidad', 0.3),
    ],
    'familia': [
      LexiconEntry('amor', 0.5),
      LexiconEntry('gratitud', 0.3),
      LexiconEntry('calma', 0.2),
    ],

    'agradecido': [
      LexiconEntry('gratitud', 1.0),
      LexiconEntry('calma', 0.3),
      LexiconEntry('felicidad', 0.3),
    ],
    'agradecida': [
      LexiconEntry('gratitud', 1.0),
      LexiconEntry('calma', 0.3),
      LexiconEntry('felicidad', 0.3),
    ],
    'gratitud': [
      LexiconEntry('gratitud', 1.0),
      LexiconEntry('calma', 0.2),
    ],
    'bendecido': [
      LexiconEntry('gratitud', 0.9),
      LexiconEntry('felicidad', 0.4),
    ],
    'bendecida': [
      LexiconEntry('gratitud', 0.9),
      LexiconEntry('felicidad', 0.4),
    ],
    'apreciar': [
      LexiconEntry('gratitud', 0.8),
      LexiconEntry('amor', 0.3),
    ],
    'valoro': [
      LexiconEntry('gratitud', 0.7),
      LexiconEntry('amor', 0.2),
    ],
    'regalo': [
      LexiconEntry('gratitud', 0.5),
      LexiconEntry('felicidad', 0.4),
    ],
    'oportunidad': [
      LexiconEntry('gratitud', 0.4),
      LexiconEntry('esperanza', 0.4),
    ],

    'esperanza': [
      LexiconEntry('esperanza', 1.0),
      LexiconEntry('motivacion', 0.3),
    ],
    'espero': [
      LexiconEntry('esperanza', 0.8),
      LexiconEntry('incertidumbre', 0.2),
    ],
    'confio': [
      LexiconEntry('esperanza', 0.9),
      LexiconEntry('calma', 0.2),
    ],
    'confianza': [
      LexiconEntry('esperanza', 0.7),
      LexiconEntry('calma', 0.3),
    ],
    'futuro': [
      LexiconEntry('esperanza', 0.5),
      LexiconEntry('incertidumbre', 0.3),
    ],
    'sueño': [
      LexiconEntry('esperanza', 0.5),
      LexiconEntry('inspiracion', 0.3),
    ],
    'anho': [
      LexiconEntry('esperanza', 0.4),
      LexiconEntry('incertidumbre', 0.2),
    ],
    'anhelo': [
      LexiconEntry('esperanza', 0.7),
      LexiconEntry('amor', 0.2),
    ],
    'ilusion': [
      LexiconEntry('esperanza', 0.8),
      LexiconEntry('alegria', 0.3),
    ],
    'meta': [
      LexiconEntry('esperanza', 0.4),
      LexiconEntry('motivacion', 0.5),
    ],
    'objetivo': [
      LexiconEntry('esperanza', 0.3),
      LexiconEntry('motivacion', 0.5),
    ],

    'calma': [
      LexiconEntry('calma', 1.0),
      LexiconEntry('gratitud', 0.15),
    ],
    'tranquilo': [
      LexiconEntry('calma', 1.0),
    ],
    'tranquila': [
      LexiconEntry('calma', 1.0),
    ],
    'paz': [
      LexiconEntry('calma', 0.9),
      LexiconEntry('gratitud', 0.2),
    ],
    'sereno': [
      LexiconEntry('calma', 0.95),
    ],
    'relajado': [
      LexiconEntry('calma', 0.9),
    ],
    'relajada': [
      LexiconEntry('calma', 0.9),
    ],
    'descanso': [
      LexiconEntry('calma', 0.7),
      LexiconEntry('agotamiento', 0.2),
    ],
    'meditar': [
      LexiconEntry('calma', 0.8),
    ],
    'respirar': [
      LexiconEntry('calma', 0.6),
      LexiconEntry('ansiedad', 0.2),
    ],
    'armonia': [
      LexiconEntry('calma', 0.8),
      LexiconEntry('felicidad', 0.2),
    ],
    'equilibrio': [
      LexiconEntry('calma', 0.7),
      LexiconEntry('felicidad', 0.2),
    ],
    'silencio': [
      LexiconEntry('calma', 0.5),
      LexiconEntry('soledad', 0.2),
    ],
    'meditacion': [
      LexiconEntry('calma', 0.8),
    ],
    'mindfulness': [
      LexiconEntry('calma', 0.8),
    ],
    'natureza': [
      LexiconEntry('calma', 0.5),
    ],
    'naturaleza': [
      LexiconEntry('calma', 0.5),
    ],
    'mar': [
      LexiconEntry('calma', 0.5),
      LexiconEntry('nostalgia', 0.2),
    ],
    'atardecer': [
      LexiconEntry('calma', 0.5),
      LexiconEntry('nostalgia', 0.3),
    ],

    'orgulloso': [
      LexiconEntry('orgullo', 1.0),
      LexiconEntry('felicidad', 0.3),
    ],
    'orgullosa': [
      LexiconEntry('orgullo', 1.0),
      LexiconEntry('felicidad', 0.3),
    ],
    'logro': [
      LexiconEntry('orgullo', 0.8),
      LexiconEntry('motivacion', 0.3),
    ],
    'logre': [
      LexiconEntry('orgullo', 0.9),
      LexiconEntry('felicidad', 0.4),
    ],
    'consegui': [
      LexiconEntry('orgullo', 0.8),
      LexiconEntry('felicidad', 0.3),
    ],
    'superado': [
      LexiconEntry('orgullo', 0.8),
      LexiconEntry('motivacion', 0.4),
    ],
    'capaz': [
      LexiconEntry('orgullo', 0.6),
      LexiconEntry('motivacion', 0.4),
    ],
    'triunfo': [
      LexiconEntry('orgullo', 0.9),
      LexiconEntry('alegria', 0.4),
    ],
    'exito': [
      LexiconEntry('orgullo', 0.8),
      LexiconEntry('felicidad', 0.4),
    ],
    'venci': [
      LexiconEntry('orgullo', 0.9),
      LexiconEntry('motivacion', 0.3),
    ],
    'lokre': [
      LexiconEntry('orgullo', 0.9),
      LexiconEntry('felicidad', 0.4),
    ],

    'motivado': [
      LexiconEntry('motivacion', 1.0),
      LexiconEntry('esperanza', 0.3),
    ],
    'motivada': [
      LexiconEntry('motivacion', 1.0),
      LexiconEntry('esperanza', 0.3),
    ],
    'empezar': [
      LexiconEntry('motivacion', 0.6),
      LexiconEntry('esperanza', 0.3),
    ],
    'comenzar': [
      LexiconEntry('motivacion', 0.6),
      LexiconEntry('esperanza', 0.3),
    ],
    'luchar': [
      LexiconEntry('motivacion', 0.8),
      LexiconEntry('frustracion', 0.2),
    ],
    'esforzo': [
      LexiconEntry('motivacion', 0.7),
      LexiconEntry('agotamiento', 0.2),
    ],
    'avanzar': [
      LexiconEntry('motivacion', 0.7),
      LexiconEntry('esperanza', 0.3),
    ],
    'crecer': [
      LexiconEntry('motivacion', 0.6),
      LexiconEntry('esperanza', 0.4),
    ],
    'progreso': [
      LexiconEntry('motivacion', 0.7),
      LexiconEntry('orgullo', 0.4),
    ],
    'constante': [
      LexiconEntry('motivacion', 0.5),
    ],
    'disciplina': [
      LexiconEntry('motivacion', 0.6),
    ],
    'proposito': [
      LexiconEntry('motivacion', 0.6),
      LexiconEntry('esperanza', 0.3),
    ],
    'propósito': [
      LexiconEntry('motivacion', 0.6),
      LexiconEntry('esperanza', 0.3),
    ],
    'rendirse': [
      LexiconEntry('motivacion', 0.3),
      LexiconEntry('desesperanza', 0.4),
    ],
    'rendir': [
      LexiconEntry('motivacion', 0.3),
      LexiconEntry('desesperanza', 0.4),
    ],
    'seguir': [
      LexiconEntry('motivacion', 0.5),
      LexiconEntry('esperanza', 0.3),
    ],
    'intentar': [
      LexiconEntry('motivacion', 0.5),
      LexiconEntry('incertidumbre', 0.2),
    ],
    'poder': [
      LexiconEntry('motivacion', 0.5),
      LexiconEntry('orgullo', 0.2),
    ],

    'inspirado': [
      LexiconEntry('inspiracion', 1.0),
      LexiconEntry('motivacion', 0.5),
    ],
    'inspirada': [
      LexiconEntry('inspiracion', 1.0),
      LexiconEntry('motivacion', 0.5),
    ],
    'creatividad': [
      LexiconEntry('inspiracion', 0.8),
      LexiconEntry('motivacion', 0.3),
    ],
    'creativo': [
      LexiconEntry('inspiracion', 0.7),
      LexiconEntry('motivacion', 0.3),
    ],
    'ideas': [
      LexiconEntry('inspiracion', 0.5),
      LexiconEntry('motivacion', 0.3),
    ],
    'descubrir': [
      LexiconEntry('inspiracion', 0.6),
      LexiconEntry('esperanza', 0.3),
    ],
    'aprender': [
      LexiconEntry('inspiracion', 0.5),
      LexiconEntry('motivacion', 0.4),
    ],
    'curiosidad': [
      LexiconEntry('inspiracion', 0.6),
    ],
    'arte': [
      LexiconEntry('inspiracion', 0.5),
      LexiconEntry('calma', 0.2),
    ],
    'musica': [
      LexiconEntry('inspiracion', 0.4),
      LexiconEntry('calma', 0.3),
    ],
    'escribir': [
      LexiconEntry('inspiracion', 0.4),
      LexiconEntry('calma', 0.2),
    ],
    'poesia': [
      LexiconEntry('inspiracion', 0.5),
      LexiconEntry('nostalgia', 0.3),
    ],

    // ── Negativas ──
    'triste': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('soledad', 0.2),
    ],
    'tristeza': [
      LexiconEntry('tristeza', 1.0),
    ],
    'murió': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.3),
    ],
    'murio': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.3),
    ],
    'muerte': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.2),
    ],
    'falleció': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.3),
    ],
    'fallecio': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.3),
    ],
    'duelo': [
      LexiconEntry('tristeza', 1.0),
      LexiconEntry('desesperanza', 0.3),
    ],
    'funeral': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('nostalgia', 0.3),
    ],
    'entierro': [
      LexiconEntry('tristeza', 0.9),
    ],
    'despedida': [
      LexiconEntry('tristeza', 0.8),
      LexiconEntry('nostalgia', 0.4),
    ],
    'hospital': [
      LexiconEntry('tristeza', 0.7),
      LexiconEntry('ansiedad', 0.4),
    ],
    'cáncer': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('miedo', 0.4),
    ],
    'cancer': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('miedo', 0.4),
    ],
    'accidente': [
      LexiconEntry('tristeza', 0.8),
      LexiconEntry('miedo', 0.3),
    ],
    'ruptura': [
      LexiconEntry('tristeza', 0.8),
      LexiconEntry('soledad', 0.3),
    ],
    'divorcio': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('soledad', 0.3),
    ],
    'despedido': [
      LexiconEntry('tristeza', 0.8),
      LexiconEntry('frustracion', 0.4),
    ],
    'despedida laboral': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('ansiedad', 0.3),
    ],
    'llorar': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('desesperanza', 0.2),
    ],
    'llanto': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('desesperanza', 0.2),
    ],
    'pena': [
      LexiconEntry('tristeza', 0.8),
      LexiconEntry('nostalgia', 0.3),
    ],
    'dolor': [
      LexiconEntry('tristeza', 0.7),
      LexiconEntry('frustracion', 0.3),
    ],
    'llorando': [
      LexiconEntry('tristeza', 0.95),
    ],
    'melancolia': [
      LexiconEntry('tristeza', 0.7),
      LexiconEntry('nostalgia', 0.6),
    ],
    'deprimido': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('desesperanza', 0.3),
    ],
    'deprimida': [
      LexiconEntry('tristeza', 0.9),
      LexiconEntry('desesperanza', 0.3),
    ],
    'lloré': [
      LexiconEntry('tristeza', 0.9),
    ],
    'perder': [
      LexiconEntry('tristeza', 0.6),
      LexiconEntry('nostalgia', 0.3),
    ],
    'perdido': [
      LexiconEntry('tristeza', 0.6),
      LexiconEntry('confusion', 0.4),
    ],
    'perdida': [
      LexiconEntry('tristeza', 0.6),
      LexiconEntry('confusion', 0.4),
    ],
    'abatido': [
      LexiconEntry('tristeza', 0.8),
    ],
    'abatida': [
      LexiconEntry('tristeza', 0.8),
    ],
    'sentir mal': [
      LexiconEntry('tristeza', 0.7),
      LexiconEntry('frustracion', 0.3),
    ],
    'me siento mal': [
      LexiconEntry('tristeza', 0.7),
      LexiconEntry('ansiedad', 0.3),
    ],

    'solo': [
      LexiconEntry('soledad', 0.9),
      LexiconEntry('tristeza', 0.3),
    ],
    'sola': [
      LexiconEntry('soledad', 0.9),
      LexiconEntry('tristeza', 0.3),
    ],
    'soledad': [
      LexiconEntry('soledad', 1.0),
    ],
    'aislado': [
      LexiconEntry('soledad', 0.8),
    ],
    'aislada': [
      LexiconEntry('soledad', 0.8),
    ],
    'abandonado': [
      LexiconEntry('soledad', 0.9),
      LexiconEntry('tristeza', 0.4),
    ],
    'abandonada': [
      LexiconEntry('soledad', 0.9),
      LexiconEntry('tristeza', 0.4),
    ],
    'olvidado': [
      LexiconEntry('soledad', 0.7),
      LexiconEntry('tristeza', 0.4),
    ],
    'olvidada': [
      LexiconEntry('soledad', 0.7),
      LexiconEntry('tristeza', 0.4),
    ],
    'desconectado': [
      LexiconEntry('soledad', 0.7),
      LexiconEntry('confusion', 0.2),
    ],
    'desconectada': [
      LexiconEntry('soledad', 0.7),
      LexiconEntry('confusion', 0.2),
    ],
    'nadie': [
      LexiconEntry('soledad', 0.5),
    ],
    'sin amigos': [
      LexiconEntry('soledad', 0.8),
    ],
    'no me entiende': [
      LexiconEntry('soledad', 0.7),
    ],
    'no me comprende': [
      LexiconEntry('soledad', 0.7),
    ],

    'vacio': [
      LexiconEntry('vacio', 1.0),
      LexiconEntry('tristeza', 0.3),
    ],
    'vacío': [
      LexiconEntry('vacio', 1.0),
      LexiconEntry('tristeza', 0.3),
    ],
    'sin sentido': [
      LexiconEntry('vacio', 0.9),
      LexiconEntry('desesperanza', 0.4),
    ],
    'nada': [
      LexiconEntry('vacio', 0.5),
      LexiconEntry('tristeza', 0.2),
    ],
    'hueco': [
      LexiconEntry('vacio', 0.8),
    ],
    'apagado': [
      LexiconEntry('vacio', 0.7),
      LexiconEntry('agotamiento', 0.3),
    ],
    'apagada': [
      LexiconEntry('vacio', 0.7),
      LexiconEntry('agotamiento', 0.3),
    ],
    'insípido': [
      LexiconEntry('vacio', 0.6),
    ],
    'monótono': [
      LexiconEntry('vacio', 0.5),
      LexiconEntry('aburrimiento', 0.3),
    ],
    'monotonía': [
      LexiconEntry('vacio', 0.5),
    ],
    'aburrimiento': [
      LexiconEntry('vacio', 0.4),
    ],

    'desesperanza': [
      LexiconEntry('desesperanza', 1.0),
      LexiconEntry('tristeza', 0.4),
    ],
    'sin esperanza': [
      LexiconEntry('desesperanza', 0.95),
    ],
    'no tiene sentido': [
      LexiconEntry('desesperanza', 0.8),
      LexiconEntry('vacio', 0.3),
    ],
    'ya no puedo': [
      LexiconEntry('desesperanza', 0.8),
      LexiconEntry('agotamiento', 0.5),
    ],
    'no aguanto': [
      LexiconEntry('desesperanza', 0.7),
      LexiconEntry('frustracion', 0.4),
    ],
    'rendido': [
      LexiconEntry('desesperanza', 0.7),
      LexiconEntry('agotamiento', 0.5),
    ],
    'rendida': [
      LexiconEntry('desesperanza', 0.7),
      LexiconEntry('agotamiento', 0.5),
    ],
    'sin salida': [
      LexiconEntry('desesperanza', 0.9),
    ],
    'imposible': [
      LexiconEntry('desesperanza', 0.6),
      LexiconEntry('frustracion', 0.3),
    ],
    'depresion': [
      LexiconEntry('desesperanza', 0.8),
      LexiconEntry('tristeza', 0.7),
    ],

    'ansioso': [
      LexiconEntry('ansiedad', 1.0),
      LexiconEntry('estres', 0.4),
    ],
    'ansiosa': [
      LexiconEntry('ansiedad', 1.0),
      LexiconEntry('estres', 0.4),
    ],
    'ansiedad': [
      LexiconEntry('ansiedad', 1.0),
    ],
    'preocupado': [
      LexiconEntry('ansiedad', 0.8),
      LexiconEntry('miedo', 0.3),
    ],
    'preocupada': [
      LexiconEntry('ansiedad', 0.8),
      LexiconEntry('miedo', 0.3),
    ],
    'nervioso': [
      LexiconEntry('ansiedad', 0.8),
      LexiconEntry('miedo', 0.2),
    ],
    'nerviosa': [
      LexiconEntry('ansiedad', 0.8),
      LexiconEntry('miedo', 0.2),
    ],
    'panico': [
      LexiconEntry('ansiedad', 0.9),
      LexiconEntry('miedo', 0.7),
    ],
    'angustia': [
      LexiconEntry('ansiedad', 0.85),
      LexiconEntry('tristeza', 0.3),
    ],
    'angustiado': [
      LexiconEntry('ansiedad', 0.85),
      LexiconEntry('tristeza', 0.3),
    ],
    'angustiada': [
      LexiconEntry('ansiedad', 0.85),
      LexiconEntry('tristeza', 0.3),
    ],
    'pensamientos': [
      LexiconEntry('ansiedad', 0.3),
      LexiconEntry('confusion', 0.2),
    ],
    'no puedo dormir': [
      LexiconEntry('ansiedad', 0.8),
      LexiconEntry('estres', 0.4),
    ],
    'insomnio': [
      LexiconEntry('ansiedad', 0.7),
      LexiconEntry('estres', 0.5),
    ],
    'palpitaciones': [
      LexiconEntry('ansiedad', 0.8),
    ],
    'taquicardia': [
      LexiconEntry('ansiedad', 0.8),
    ],
    'mareo': [
      LexiconEntry('ansiedad', 0.5),
      LexiconEntry('agotamiento', 0.3),
    ],
    'ataque de panico': [
      LexiconEntry('ansiedad', 0.95),
      LexiconEntry('miedo', 0.5),
    ],
    'inquieto': [
      LexiconEntry('ansiedad', 0.7),
    ],
    'inquieta': [
      LexiconEntry('ansiedad', 0.7),
    ],
    'tenso': [
      LexiconEntry('ansiedad', 0.6),
      LexiconEntry('estres', 0.5),
    ],
    'tensa': [
      LexiconEntry('ansiedad', 0.6),
      LexiconEntry('estres', 0.5),
    ],
    'ahogo': [
      LexiconEntry('ansiedad', 0.7),
    ],
    'ahogada': [
      LexiconEntry('ansiedad', 0.7),
    ],

    'estresado': [
      LexiconEntry('estres', 1.0),
      LexiconEntry('ansiedad', 0.4),
    ],
    'estresada': [
      LexiconEntry('estres', 1.0),
      LexiconEntry('ansiedad', 0.4),
    ],
    'estres': [
      LexiconEntry('estres', 1.0),
    ],
    'estrés': [
      LexiconEntry('estres', 1.0),
    ],
    'presion': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],
    'presión': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],
    'sobrecargado': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('agotamiento', 0.5),
    ],
    'sobrecargada': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('agotamiento', 0.5),
    ],
    'trabajo': [
      LexiconEntry('estres', 0.3),
    ],
    'deadline': [
      LexiconEntry('estres', 0.7),
    ],
    'examen': [
      LexiconEntry('estres', 0.5),
      LexiconEntry('ansiedad', 0.4),
    ],
    'exámenes': [
      LexiconEntry('estres', 0.5),
      LexiconEntry('ansiedad', 0.4),
    ],
    'urgencia': [
      LexiconEntry('estres', 0.6),
      LexiconEntry('ansiedad', 0.3),
    ],
    'colapso': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('ansiedad', 0.5),
    ],
    'desbordado': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],
    'desbordada': [
      LexiconEntry('estres', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],

    'miedo': [
      LexiconEntry('miedo', 1.0),
    ],
    'asustado': [
      LexiconEntry('miedo', 0.9),
    ],
    'asustada': [
      LexiconEntry('miedo', 0.9),
    ],
    'temor': [
      LexiconEntry('miedo', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],
    'temo': [
      LexiconEntry('miedo', 0.8),
      LexiconEntry('ansiedad', 0.3),
    ],
    'terror': [
      LexiconEntry('miedo', 0.95),
    ],
    'horror': [
      LexiconEntry('miedo', 0.9),
    ],
    'amenaza': [
      LexiconEntry('miedo', 0.7),
    ],
    'peligro': [
      LexiconEntry('miedo', 0.7),
    ],
    'riesgo': [
      LexiconEntry('miedo', 0.5),
      LexiconEntry('ansiedad', 0.3),
    ],
    'inseguro': [
      LexiconEntry('miedo', 0.6),
      LexiconEntry('ansiedad', 0.3),
    ],
    'insegura': [
      LexiconEntry('miedo', 0.6),
      LexiconEntry('ansiedad', 0.3),
    ],
    'vulnerabilidad': [
      LexiconEntry('miedo', 0.5),
      LexiconEntry('ansiedad', 0.3),
    ],
    'acosado': [
      LexiconEntry('miedo', 0.8),
    ],
    'acosada': [
      LexiconEntry('miedo', 0.8),
    ],
    'amenazado': [
      LexiconEntry('miedo', 0.8),
    ],
    'amenazada': [
      LexiconEntry('miedo', 0.8),
    ],

    'frustrado': [
      LexiconEntry('frustracion', 1.0),
      LexiconEntry('enojo', 0.3),
    ],
    'frustrada': [
      LexiconEntry('frustracion', 1.0),
      LexiconEntry('enojo', 0.3),
    ],
    'frustración': [
      LexiconEntry('frustracion', 1.0),
    ],
    'frustracion': [
      LexiconEntry('frustracion', 1.0),
    ],
    'impotente': [
      LexiconEntry('frustracion', 0.8),
      LexiconEntry('desesperanza', 0.3),
    ],
    'impotencia': [
      LexiconEntry('frustracion', 0.8),
      LexiconEntry('desesperanza', 0.3),
    ],
    'bloqueado': [
      LexiconEntry('frustracion', 0.7),
      LexiconEntry('confusion', 0.3),
    ],
    'bloqueada': [
      LexiconEntry('frustracion', 0.7),
      LexiconEntry('confusion', 0.3),
    ],
    'no logro': [
      LexiconEntry('frustracion', 0.7),
    ],
    'no puedo': [
      LexiconEntry('frustracion', 0.5),
      LexiconEntry('desesperanza', 0.3),
    ],
    'fracaso': [
      LexiconEntry('frustracion', 0.8),
      LexiconEntry('tristeza', 0.3),
    ],
    'fracasé': [
      LexiconEntry('frustracion', 0.8),
      LexiconEntry('tristeza', 0.3),
    ],
    'error': [
      LexiconEntry('frustracion', 0.5),
    ],
    'equivocar': [
      LexiconEntry('frustracion', 0.5),
    ],
    'equivocado': [
      LexiconEntry('frustracion', 0.5),
    ],
    'estancado': [
      LexiconEntry('frustracion', 0.7),
    ],
    'estancada': [
      LexiconEntry('frustracion', 0.7),
    ],
    'atascado': [
      LexiconEntry('frustracion', 0.7),
    ],

    'enojado': [
      LexiconEntry('enojo', 1.0),
    ],
    'enojada': [
      LexiconEntry('enojo', 1.0),
    ],
    'furioso': [
      LexiconEntry('enojo', 0.95),
    ],
    'furiosa': [
      LexiconEntry('enojo', 0.95),
    ],
    'rabia': [
      LexiconEntry('enojo', 0.9),
    ],
    'odio': [
      LexiconEntry('enojo', 0.9),
    ],
    'irritado': [
      LexiconEntry('enojo', 0.7),
      LexiconEntry('estres', 0.2),
    ],
    'irritada': [
      LexiconEntry('enojo', 0.7),
      LexiconEntry('estres', 0.2),
    ],
    'molesto': [
      LexiconEntry('enojo', 0.7),
    ],
    'molesta': [
      LexiconEntry('enojo', 0.7),
    ],
    'indignado': [
      LexiconEntry('enojo', 0.8),
    ],
    'indignada': [
      LexiconEntry('enojo', 0.8),
    ],
    'injusto': [
      LexiconEntry('enojo', 0.7),
      LexiconEntry('frustracion', 0.3),
    ],
    'injusticia': [
      LexiconEntry('enojo', 0.7),
      LexiconEntry('frustracion', 0.3),
    ],
    'hartado': [
      LexiconEntry('enojo', 0.7),
    ],
    'hartada': [
      LexiconEntry('enojo', 0.7),
    ],
    'harto': [
      LexiconEntry('enojo', 0.6),
    ],
    'arta': [
      LexiconEntry('enojo', 0.6),
    ],
    'gritar': [
      LexiconEntry('enojo', 0.7),
    ],
    'gritando': [
      LexiconEntry('enojo', 0.8),
    ],
    'grito': [
      LexiconEntry('enojo', 0.7),
    ],

    'culpa': [
      LexiconEntry('culpa', 1.0),
    ],
    'culpable': [
      LexiconEntry('culpa', 1.0),
    ],
    'arrepentido': [
      LexiconEntry('culpa', 0.9),
      LexiconEntry('tristeza', 0.2),
    ],
    'arrepentida': [
      LexiconEntry('culpa', 0.9),
      LexiconEntry('tristeza', 0.2),
    ],
    'arrepentimiento': [
      LexiconEntry('culpa', 0.9),
    ],
    'me equivoqué': [
      LexiconEntry('culpa', 0.8),
      LexiconEntry('frustracion', 0.3),
    ],
    'perdon': [
      LexiconEntry('culpa', 0.6),
      LexiconEntry('esperanza', 0.2),
    ],
    'perdón': [
      LexiconEntry('culpa', 0.6),
      LexiconEntry('esperanza', 0.2),
    ],
    'culpar': [
      LexiconEntry('culpa', 0.7),
    ],
    'responsable': [
      LexiconEntry('culpa', 0.5),
      LexiconEntry('estres', 0.2),
    ],
    'lastimé': [
      LexiconEntry('culpa', 0.8),
    ],
    'dañé': [
      LexiconEntry('culpa', 0.8),
    ],
    'decepcioné': [
      LexiconEntry('culpa', 0.8),
      LexiconEntry('tristeza', 0.3),
    ],

    'vergüenza': [
      LexiconEntry('vergüenza', 1.0),
    ],
    'vergonza': [
      LexiconEntry('vergüenza', 1.0),
    ],
    'avergonzado': [
      LexiconEntry('vergüenza', 0.9),
    ],
    'avergonzada': [
      LexiconEntry('vergüenza', 0.9),
    ],
    'humillado': [
      LexiconEntry('vergüenza', 0.9),
      LexiconEntry('enojo', 0.2),
    ],
    'humillada': [
      LexiconEntry('vergüenza', 0.9),
      LexiconEntry('enojo', 0.2),
    ],
    'humillacion': [
      LexiconEntry('vergüenza', 0.9),
    ],
    'exponer': [
      LexiconEntry('vergüenza', 0.5),
      LexiconEntry('miedo', 0.3),
    ],
    'ridiculo': [
      LexiconEntry('vergüenza', 0.8),
    ],
    'tímido': [
      LexiconEntry('vergüenza', 0.4),
      LexiconEntry('miedo', 0.3),
    ],
    'timidez': [
      LexiconEntry('vergüenza', 0.5),
      LexiconEntry('miedo', 0.3),
    ],
    'juzgado': [
      LexiconEntry('vergüenza', 0.6),
      LexiconEntry('miedo', 0.3),
    ],
    'juzgada': [
      LexiconEntry('vergüenza', 0.6),
      LexiconEntry('miedo', 0.3),
    ],

    'confundido': [
      LexiconEntry('confusion', 1.0),
    ],
    'confundida': [
      LexiconEntry('confusion', 1.0),
    ],
    'confusión': [
      LexiconEntry('confusion', 1.0),
    ],
    'confusion': [
      LexiconEntry('confusion', 1.0),
    ],
    'duda': [
      LexiconEntry('confusion', 0.6),
      LexiconEntry('incertidumbre', 0.5),
    ],
    'dudas': [
      LexiconEntry('confusion', 0.6),
      LexiconEntry('incertidumbre', 0.5),
    ],
    'no entiendo': [
      LexiconEntry('confusion', 0.8),
    ],
    'no comprendo': [
      LexiconEntry('confusion', 0.8),
    ],
    'desorientado': [
      LexiconEntry('confusion', 0.8),
    ],
    'desorientada': [
      LexiconEntry('confusion', 0.8),
    ],
    'contradictorio': [
      LexiconEntry('confusion', 0.6),
    ],
    'ambiguo': [
      LexiconEntry('confusion', 0.5),
      LexiconEntry('incertidumbre', 0.4),
    ],
    'complicado': [
      LexiconEntry('confusion', 0.5),
      LexiconEntry('frustracion', 0.3),
    ],

    'agotado': [
      LexiconEntry('agotamiento', 1.0),
      LexiconEntry('estres', 0.3),
    ],
    'agotada': [
      LexiconEntry('agotamiento', 1.0),
      LexiconEntry('estres', 0.3),
    ],
    'cansado': [
      LexiconEntry('agotamiento', 0.8),
    ],
    'cansada': [
      LexiconEntry('agotamiento', 0.8),
    ],
    'sin energía': [
      LexiconEntry('agotamiento', 0.9),
    ],
    'sin energia': [
      LexiconEntry('agotamiento', 0.9),
    ],
    'extenuado': [
      LexiconEntry('agotamiento', 0.95),
    ],
    'extenuada': [
      LexiconEntry('agotamiento', 0.95),
    ],
    'dormido': [
      LexiconEntry('agotamiento', 0.5),
    ],
    'dormida': [
      LexiconEntry('agotamiento', 0.5),
    ],
    'agotador': [
      LexiconEntry('agotamiento', 0.8),
      LexiconEntry('estres', 0.4),
    ],
    'agotadora': [
      LexiconEntry('agotamiento', 0.8),
      LexiconEntry('estres', 0.4),
    ],
    'desgastado': [
      LexiconEntry('agotamiento', 0.8),
    ],
    'desgastada': [
      LexiconEntry('agotamiento', 0.8),
    ],
    'sin fuerzas': [
      LexiconEntry('agotamiento', 0.9),
    ],
    'no puedo más': [
      LexiconEntry('agotamiento', 0.8),
      LexiconEntry('desesperanza', 0.3),
    ],
    'drenado': [
      LexiconEntry('agotamiento', 0.8),
    ],
    'drenada': [
      LexiconEntry('agotamiento', 0.8),
    ],

    'burnout': [
      LexiconEntry('burnout', 1.0),
      LexiconEntry('agotamiento', 0.6),
      LexiconEntry('desesperanza', 0.2),
    ],
    'desgaste': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('agotamiento', 0.5),
    ],
    'quemado': [
      LexiconEntry('burnout', 0.9),
      LexiconEntry('agotamiento', 0.5),
    ],
    'quemada': [
      LexiconEntry('burnout', 0.9),
      LexiconEntry('agotamiento', 0.5),
    ],
    'saturado': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('estres', 0.4),
    ],
    'saturada': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('estres', 0.4),
    ],
    'desmotivado': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('desesperanza', 0.3),
    ],
    'desmotivada': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('desesperanza', 0.3),
    ],
    'agobiado': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('estres', 0.5),
    ],
    'agobiada': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('estres', 0.5),
    ],
    'explotar': [
      LexiconEntry('burnout', 0.6),
      LexiconEntry('estres', 0.5),
    ],
    'explotando': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('estres', 0.5),
    ],
    'no aguanto más': [
      LexiconEntry('burnout', 0.8),
      LexiconEntry('desesperanza', 0.4),
    ],
    'hartazgo': [
      LexiconEntry('burnout', 0.7),
      LexiconEntry('enojo', 0.3),
    ],
    'crujir': [
      LexiconEntry('burnout', 0.5),
      LexiconEntry('agotamiento', 0.4),
    ],

    'nostalgia': [
      LexiconEntry('nostalgia', 1.0),
      LexiconEntry('tristeza', 0.3),
    ],
    'recordar': [
      LexiconEntry('nostalgia', 0.6),
      LexiconEntry('tristeza', 0.2),
    ],
    'recuerdo': [
      LexiconEntry('nostalgia', 0.6),
      LexiconEntry('tristeza', 0.2),
    ],
    'recuerdos': [
      LexiconEntry('nostalgia', 0.6),
    ],
    'extrañar': [
      LexiconEntry('nostalgia', 0.8),
      LexiconEntry('tristeza', 0.4),
    ],
    'extraño': [
      LexiconEntry('nostalgia', 0.7),
      LexiconEntry('tristeza', 0.3),
    ],
    'extraña': [
      LexiconEntry('nostalgia', 0.7),
      LexiconEntry('tristeza', 0.3),
    ],
    'época': [
      LexiconEntry('nostalgia', 0.4),
    ],
    'antes': [
      LexiconEntry('nostalgia', 0.3),
    ],
    'infancia': [
      LexiconEntry('nostalgia', 0.6),
      LexiconEntry('felicidad', 0.2),
    ],
    'pasado': [
      LexiconEntry('nostalgia', 0.4),
    ],
    'tiempo': [
      LexiconEntry('nostalgia', 0.2),
    ],
    'viejos tiempos': [
      LexiconEntry('nostalgia', 0.8),
    ],
    'aquel entonces': [
      LexiconEntry('nostalgia', 0.7),
    ],
    'sobran': [
      LexiconEntry('nostalgia', 0.3),
      LexiconEntry('tristeza', 0.2),
    ],
    'añoranza': [
      LexiconEntry('nostalgia', 0.9),
      LexiconEntry('tristeza', 0.3),
    ],

    'incertidumbre': [
      LexiconEntry('incertidumbre', 1.0),
    ],
    'no sé': [
      LexiconEntry('incertidumbre', 0.7),
      LexiconEntry('confusion', 0.3),
    ],
    'no estoy seguro': [
      LexiconEntry('incertidumbre', 0.8),
    ],
    'no estoy segura': [
      LexiconEntry('incertidumbre', 0.8),
    ],
    'desconocido': [
      LexiconEntry('incertidumbre', 0.6),
    ],
    'desconocida': [
      LexiconEntry('incertidumbre', 0.6),
    ],
    'impredecible': [
      LexiconEntry('incertidumbre', 0.7),
    ],
    'cambiar': [
      LexiconEntry('incertidumbre', 0.3),
      LexiconEntry('esperanza', 0.2),
    ],
    'cambio': [
      LexiconEntry('incertidumbre', 0.3),
      LexiconEntry('esperanza', 0.2),
    ],
    'dudar': [
      LexiconEntry('incertidumbre', 0.7),
    ],
    'título': [
      LexiconEntry('incertidumbre', 0.4),
    ],
    'camino': [
      LexiconEntry('incertidumbre', 0.3),
      LexiconEntry('esperanza', 0.2),
    ],
    'decidir': [
      LexiconEntry('incertidumbre', 0.5),
    ],
    'opciones': [
      LexiconEntry('incertidumbre', 0.4),
    ],
    'que hacer': [
      LexiconEntry('incertidumbre', 0.6),
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
  };

  static Map<String, List<LexiconEntry>> get keywords => _keywords;

  static List<String> getKeywordList() => _keywords.keys.toList();
}

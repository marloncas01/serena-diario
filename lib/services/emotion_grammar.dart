import '../models/emotion.dart';
import 'user_profile.dart';

/// Gramática emocional centralizada.
///
/// Toda la flexión de género para las etiquetas de estado vive aquí, para
/// evitar duplicar lógica. El género NO cambia la emoción registrada: solo
/// cambia cómo se escribe el estado del usuario (p. ej. "Cansado",
/// "Cansada" o "Con cansancio").
class EmotionGrammar {
  const EmotionGrammar._();

  static const Map<String, ({String masculino, String femenino, String neutro})>
      _formas = {
    'alegria': (masculino: 'alegre', femenino: 'alegre', neutro: 'alegría'),
    'felicidad': (masculino: 'feliz', femenino: 'feliz', neutro: 'felicidad'),
    'amor': (masculino: 'enamorado', femenino: 'enamorada', neutro: 'amor'),
    'gratitud':
        (masculino: 'agradecido', femenino: 'agradecida', neutro: 'gratitud'),
    'esperanza': (
      masculino: 'esperanzado',
      femenino: 'esperanzada',
      neutro: 'esperanza',
    ),
    'calma': (masculino: 'tranquilo', femenino: 'tranquila', neutro: 'calma'),
    'orgullo': (
      masculino: 'orgulloso',
      femenino: 'orgullosa',
      neutro: 'orgullo',
    ),
    'motivacion': (
      masculino: 'motivado',
      femenino: 'motivada',
      neutro: 'motivación',
    ),
    'inspiracion': (
      masculino: 'inspirado',
      femenino: 'inspirada',
      neutro: 'inspiración',
    ),
    'tristeza': (masculino: 'triste', femenino: 'triste', neutro: 'tristeza'),
    'soledad': (masculino: 'solo', femenino: 'sola', neutro: 'soledad'),
    'vacio': (masculino: 'vacío', femenino: 'vacía', neutro: 'vacío'),
    'desesperanza': (
      masculino: 'desesperanzado',
      femenino: 'desesperanzada',
      neutro: 'desesperanza',
    ),
    'ansiedad': (
      masculino: 'preocupado',
      femenino: 'preocupada',
      neutro: 'preocupación',
    ),
    'estres': (masculino: 'estresado', femenino: 'estresada', neutro: 'estrés'),
    'miedo': (masculino: 'asustado', femenino: 'asustada', neutro: 'miedo'),
    'frustracion': (
      masculino: 'frustrado',
      femenino: 'frustrada',
      neutro: 'frustración',
    ),
    'enojo': (masculino: 'enojado', femenino: 'enojada', neutro: 'enojo'),
    'culpa': (masculino: 'culpable', femenino: 'culpable', neutro: 'culpa'),
    'vergüenza': (
      masculino: 'avergonzado',
      femenino: 'avergonzada',
      neutro: 'vergüenza',
    ),
    'confusion': (
      masculino: 'confundido',
      femenino: 'confundida',
      neutro: 'confusión',
    ),
    'agotamiento': (
      masculino: 'agotado',
      femenino: 'agotada',
      neutro: 'agotamiento',
    ),
    'burnout': (masculino: 'quemado', femenino: 'quemada', neutro: 'burnout'),
    'nostalgia': (
      masculino: 'nostálgico',
      femenino: 'nostálgica',
      neutro: 'nostalgia',
    ),
    'incertidumbre': (
      masculino: 'incierto',
      femenino: 'incierta',
      neutro: 'incertidumbre',
    ),
    'entusiasmo': (
      masculino: 'entusiasmado',
      femenino: 'entusiasmada',
      neutro: 'entusiasmo',
    ),
    'ternura':
        (masculino: 'conmovido', femenino: 'conmovida', neutro: 'ternura'),
    'ilusion': (
      masculino: 'ilusionado',
      femenino: 'ilusionada',
      neutro: 'ilusión',
    ),
    'alivio': (masculino: 'aliviado', femenino: 'aliviada', neutro: 'alivio'),
    'optimismo': (
      masculino: 'optimista',
      femenino: 'optimista',
      neutro: 'optimismo',
    ),
    'confianza': (
      masculino: 'confiado',
      femenino: 'confiada',
      neutro: 'confianza',
    ),
    'diversion': (
      masculino: 'divertido',
      femenino: 'divertida',
      neutro: 'diversión',
    ),
    'paz': (masculino: 'en paz', femenino: 'en paz', neutro: 'paz'),
    'vulnerabilidad': (
      masculino: 'vulnerable',
      femenino: 'vulnerable',
      neutro: 'vulnerabilidad',
    ),
    'irritabilidad': (
      masculino: 'irritable',
      femenino: 'irritable',
      neutro: 'irritabilidad',
    ),
    'inseguridad': (
      masculino: 'inseguro',
      femenino: 'insegura',
      neutro: 'inseguridad',
    ),
    'decepcion': (
      masculino: 'decepcionado',
      femenino: 'decepcionada',
      neutro: 'decepción',
    ),
    'aburrimiento': (
      masculino: 'aburrido',
      femenino: 'aburrida',
      neutro: 'aburrimiento',
    ),
    'cansancio': (
      masculino: 'cansado',
      femenino: 'cansada',
      neutro: 'cansancio',
    ),
    'melancolia': (
      masculino: 'melancólico',
      femenino: 'melancólica',
      neutro: 'melancolía',
    ),
    'curiosidad': (
      masculino: 'curioso',
      femenino: 'curiosa',
      neutro: 'curiosidad',
    ),
    'sorpresa': (
      masculino: 'sorprendido',
      femenino: 'sorprendida',
      neutro: 'sorpresa',
    ),
    'anticipacion': (
      masculino: 'expectante',
      femenino: 'expectante',
      neutro: 'expectativa',
    ),
  };

  /// Etiqueta del estado del usuario para una emoción según su sexo.
  /// Ejemplos: Hombre "Cansado", Mujer "Cansada", neutro "Con cansancio".
  static String labelFor(EmotionDefinition emotion, UserSex sex) {
    if (emotion.id == 'neutral') return 'Neutral';

    final forma = _formas[emotion.id];
    final neutral = forma != null
        ? 'Con ${forma.neutro}'
        : 'Con ${emotion.name.toLowerCase()}';

    return switch (sex) {
      UserSex.hombre => _capitalize(forma?.masculino ?? emotion.name),
      UserSex.mujer => _capitalize(forma?.femenino ?? emotion.name),
      UserSex.prefieroNoDecirlo => neutral,
    };
  }

  /// Devuelve la forma masculina o femenina de una palabra según el sexo.
  /// Para sexo neutro se usa la forma masculina (práctica estándar en español).
  static String flex(UserSex sex, String masculino, String femenino) =>
      sex == UserSex.mujer ? femenino : masculino;

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

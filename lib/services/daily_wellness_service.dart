import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class WellnessTip {
  const WellnessTip({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.emoji,
  });

  final String id;
  final String title;
  final String message;
  final String category;
  final String emoji;
}

class DailyWellnessService {
  DailyWellnessService._();

  static final DailyWellnessService _instance = DailyWellnessService._();
  factory DailyWellnessService() => _instance;

  static const String _shownTipsKey = 'daily_wellness_shown_v1';
  static const int _avoidRepeatDays = 30;

  Future<WellnessTip> getTodayTip() => getTipForDate(DateTime.now());

  Future<WellnessTip> getTipForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final dayOfYear = normalized.difference(DateTime(normalized.year, 1, 1)).inDays;
    final seed = normalized.year * 1000 + dayOfYear;
    final rng = Random(seed);

    final shown = await _loadShownTips();
    final cutoff = normalized.subtract(const Duration(days: _avoidRepeatDays));
    shown.removeWhere((entry) => entry.date.isBefore(cutoff));

    final candidates = List<int>.generate(_allTips.length, (i) => i);
    candidates.shuffle(rng);

    for (final idx in candidates) {
      if (!shown.any((entry) => entry.tipIndex == idx)) {
        shown.add(_ShownEntry(tipIndex: idx, date: normalized));
        await _saveShownTips(shown);
        return _allTips[idx];
      }
    }

    shown.add(_ShownEntry(tipIndex: candidates.first, date: normalized));
    await _saveShownTips(shown);
    return _allTips[candidates.first];
  }

  String getCategoryName(String category) => _categoryNames[category] ?? category;

  // ─── SharedPreferences helpers ──────────────────────────────────────────

  Future<List<_ShownEntry>> _loadShownTips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_shownTipsKey) ?? [];
    return raw.map((s) {
      final parts = s.split('|');
      return _ShownEntry(
        tipIndex: int.parse(parts[0]),
        date: DateTime.parse(parts[1]),
      );
    }).toList();
  }

  Future<void> _saveShownTips(List<_ShownEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = entries.map((e) => '${e.tipIndex}|${e.date.toIso8601String()}').toList();
    await prefs.setStringList(_shownTipsKey, raw);
  }

  // ─── Category display names ─────────────────────────────────────────────

  static const Map<String, String> _categoryNames = {
    'lectura': 'Lectura',
    'ejercicio': 'Ejercicio',
    'respiracion': 'Respiración',
    'hidratacion': 'Hidratación',
    'alimentacion': 'Alimentación',
    'sueno': 'Sueño',
    'productividad': 'Productividad',
    'mindfulness': 'Mindfulness',
    'relaciones': 'Relaciones',
    'naturaleza': 'Naturaleza',
    'creatividad': 'Creatividad',
    'descanso_digital': 'Descanso Digital',
  };

  // ─── All tips ───────────────────────────────────────────────────────────

  static final List<WellnessTip> _allTips = [
    // ═══════════════════════════════════════════════════════════════════════
    // LECTURA (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'lec_00', title: 'Lectura matutina', message: 'Dedica 10 minutos antes del desayuno a leer algo que te apasione. Tu mente lo agradecerá todo el día.', category: 'lectura', emoji: '📖'),
    const WellnessTip(id: 'lec_01', title: 'Libro físico', message: 'Deja el teléfono y agarra un libro en papel. La experiencia táctil multiplica la relajación.', category: 'lectura', emoji: '📚'),
    const WellnessTip(id: 'lec_02', title: 'Lectura en voz alta', message: 'Lee un párrafo en voz alta. Escuchar tu propia voz mejora la comprensión y reduce el estrés.', category: 'lectura', emoji: '🗣️'),
    const WellnessTip(id: 'lec_03', title: 'Poemas cortos', message: 'Busca un poema corto de tu autor favorito. Un verso puede cambiar el tono de tu día completo.', category: 'lectura', emoji: '🌹'),
    const WellnessTip(id: 'lec_04', title: 'Artículo nuevo', message: 'Lee un artículo sobre un tema que nunca has explorado. Aprender algo nuevo alimenta la curiosidad.', category: 'lectura', emoji: '📰'),
    const WellnessTip(id: 'lec_05', title: 'Rincón de lectura', message: 'Crea un espacio acogedor solo para leer: una manta, buena luz y silencio. El ambiente importa.', category: 'lectura', emoji: '🛋️'),
    const WellnessTip(id: 'lec_06', title: 'Recomendación de un amigo', message: 'Pídele a un amigo que te recomiende un libro. También fortalece el vínculo.', category: 'lectura', emoji: '🤝'),
    const WellnessTip(id: 'lec_07', title: 'Lectura antes de dormir', message: 'Sustituye el celular por un libro los últimos 15 minutos antes de acostarte. Dormirás mejor.', category: 'lectura', emoji: '🌙'),
    const WellnessTip(id: 'lec_08', title: 'Subraya pasajes', message: 'Cuando encuentres una frase que te toque, subráyala. Después podrás volver a ella cuando lo necesites.', category: 'lectura', emoji: '✨'),
    const WellnessTip(id: 'lec_09', title: 'Libro de desarrollo personal', message: 'Escoge un libro que te inspire a crecer. Lee solo dos páginas, sin prisa.', category: 'lectura', emoji: '🌱'),
    const WellnessTip(id: 'lec_10', title: 'Cuentos cortos', message: 'Si no tienes mucho tiempo, lee un cuento corto. La narrativa concentrada es poderosa.', category: 'lectura', emoji: '📝'),
    const WellnessTip(id: 'lec_11', title: 'Biblioteca local', message: 'Visita tu biblioteca y saca un libro gratis. El acto de elegir ya es una experiencia gratificante.', category: 'lectura', emoji: '🏛️'),
    const WellnessTip(id: 'lec_12', title: 'Relee un favorito', message: 'Vuelve a ese libro que te marcó. Descubrirás cosas que no viste la primera vez.', category: 'lectura', emoji: '🔄'),
    const WellnessTip(id: 'lec_13', title: 'Lectura al aire libre', message: 'Lleva tu libro al parque o a un banco con sombra. La naturaleza potencia la concentración.', category: 'lectura', emoji: '🌳'),
    const WellnessTip(id: 'lec_14', title: 'Nota mental', message: 'Mientras leas, hazte una pregunta: ¿qué aprendí hoy? Guarda la respuesta para reflexionar después.', category: 'lectura', emoji: '💡'),
    const WellnessTip(id: 'lec_15', title: 'Escucha un audiolibro', message: 'Si leer no es opción hoy, pon un audiolibro mientras cocinas o caminas. La historia sigue llegando.', category: 'lectura', emoji: '🎧'),
    const WellnessTip(id: 'lec_16', title: 'Comparte una cita', message: 'Si una frase del libro te conmueve, compártela con alguien. La literatura conecta personas.', category: 'lectura', emoji: '💬'),
    const WellnessTip(id: 'lec_17', title: 'Lectura sin meta', message: 'Lee sin presión de terminar. Disfruta el proceso, no el resultado. La lectura es un placer, no una tarea.', category: 'lectura', emoji: '🕊️'),
    const WellnessTip(id: 'lec_18', title: 'Diccionario del día', message: 'Aprende una palabra nueva cada día y úsala en una frase. Expandir tu vocabulario expande tu mundo.', category: 'lectura', emoji: '🔤'),
    const WellnessTip(id: 'lec_19', title: 'Autor local', message: 'Investiga autores de tu región. Conocer voces cercanas te conecta con tu entorno.', category: 'lectura', emoji: '🗺️'),
    const WellnessTip(id: 'lec_20', title: 'Lectura compartida', message: 'Lee el mismo libro que otra persona y converse sobre ello. Compartir lectura enriquece ambas perspectivas.', category: 'lectura', emoji: '👥'),
    const WellnessTip(id: 'lec_21', title: 'Extracto en tu diario', message: 'Copia a mano un pasaje que te guste en tu diario. La escritura refuerza la lectura.', category: 'lectura', emoji: '✏️'),
    const WellnessTip(id: 'lec_22', title: 'Libro aleatorio', message: 'Abre un libro en cualquier página y lee lo que encuentres. A veces lo inesperado es lo mejor.', category: 'lectura', emoji: '🎲'),
    const WellnessTip(id: 'lec_23', title: 'Género diferente', message: 'Hoy lee algo que normalmente no elegirías: ciencia ficción, ensayo, historia. Sal de tu zona de confort.', category: 'lectura', emoji: '🔀'),
    const WellnessTip(id: 'lec_24', title: 'Foto de tu lectura', message: 'Toma una foto del libro que estás leyendo y guárdalo como recuerdo de tu crecimiento.', category: 'lectura', emoji: '📸'),

    // ═══════════════════════════════════════════════════════════════════════
    // EJERCICIO (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'ejc_00', title: 'Caminata de 15 min', message: 'Sal a caminar por tu barrio durante 15 minutos. No necesitas meta, solo moverte.', category: 'ejercicio', emoji: '🚶'),
    const WellnessTip(id: 'ejc_01', title: 'Estiramiento matutino', message: 'Al despertar, estira tus brazos hacia el cielo y mantén 20 segundos. Activa tu cuerpo gradualmente.', category: 'ejercicio', emoji: '🙆'),
    const WellnessTip(id: 'ejc_02', title: 'Sube escaleras', message: 'Usa las escaleras en lugar del elevador. Es un ejercicio simple pero efectivo para piernas y cardio.', category: 'ejercicio', emoji: '🪜'),
    const WellnessTip(id: 'ejc_03', title: 'Baile libre', message: 'Pon tu canción favorita y baila sin pensarlo. No importa cómo te muevas, solo déjate llevar.', category: 'ejercicio', emoji: '💃'),
    const WellnessTip(id: 'ejc_04', title: 'Sentadillas', message: 'Haz 10 sentadillas ahora mismo. Solo 10, sin excusas. Tu cuerpo te lo agradecerá.', category: 'ejercicio', emoji: '🦵'),
    const WellnessTip(id: 'ejc_05', title: 'Yoga en casa', message: 'Busca una rutina de yoga de 10 minutos en YouTube. La combinación de movimiento y respiración es transformadora.', category: 'ejercicio', emoji: '🧘'),
    const WellnessTip(id: 'ejc_06', title: 'Caminata sin teléfono', message: 'Sal a caminar 20 minutos sin llevar el celular. Conecta con tu entorno y tu pensamiento.', category: 'ejercicio', emoji: '📵'),
    const WellnessTip(id: 'ejc_07', title: 'Plancha de 30 seg', message: 'Haz una plancha por 30 segundos. Fortalece el core y mejora la postura, poco a poco.', category: 'ejercicio', emoji: '💪'),
    const WellnessTip(id: 'ejc_08', title: 'Movilidad articular', message: 'Rota suavemente cuello, hombros, muñecas y tobillos. Desbloquear las articulaciones libera tensión acumulada.', category: 'ejercicio', emoji: '🔄'),
    const WellnessTip(id: 'ejc_09', title: 'Ciclismo corto', message: 'Si tienes bicicleta, da una vuelta de 20 minutos. Pedalar libera endorfinas rápidamente.', category: 'ejercicio', emoji: '🚴'),
    const WellnessTip(id: 'ejc_10', title: 'Saltar la cuerda', message: 'Salta la cuerda 2 minutos. Es cardio intenso en poco tiempo y te conecta con tu infancia.', category: 'ejercicio', emoji: '🪢'),
    const WellnessTip(id: 'ejc_11', title: 'Yoga de respiración', message: 'Siéntate con la espalda recta, cierra los ojos y respira profundo 3 minutos. Activa tu sistema nervioso parasimpático.', category: 'ejercicio', emoji: '🌬️'),
    const WellnessTip(id: 'ejc_12', title: 'Estira la espalda', message: 'Inclínate hacia adelante desde la cintura, dejando los brazos colgar. Mantén 30 segundos. Tu espalda te lo agradecerá.', category: 'ejercicio', emoji: '🧎'),
    const WellnessTip(id: 'ejc_13', title: 'Caminata de gratitud', message: 'Mientras caminas, piensa en 3 cosas por las que estás agradecido. Combina movimiento con bienestar mental.', category: 'ejercicio', emoji: '🙏'),
    const WellnessTip(id: 'ejc_14', title: 'Brincos en el sitio', message: 'Haz 20 brincos en el sitio. Activa la circulación y despierta el cuerpo en menos de un minuto.', category: 'ejercicio', emoji: '🦘'),
    const WellnessTip(id: 'ejc_15', title: 'Meditación caminando', message: 'Camina muy despacio, sintiendo cada paso. Nota la textura del suelo, el viento, los sonidos. Plena atención.', category: 'ejercicio', emoji: '🍃'),
    const WellnessTip(id: 'ejc_16', title: 'Flexiones en pared', message: 'Apoya las manos en una pared y haz 15 flexiones. Ejercicio suave pero efectivo para brazos y pecho.', category: 'ejercicio', emoji: '🧱'),
    const WellnessTip(id: 'ejc_17', title: 'Caminata con música', message: 'Pon una playlist animada y camina al ritmo de la música. El ejercicio con música se siente más corto.', category: 'ejercicio', emoji: '🎵'),
    const WellnessTip(id: 'ejc_18', title: 'Abdominales suaves', message: 'Acuéstate boca arriba, dobla las rodillas y contrae el abdomen 10 veces. Poco a poco construyes fuerza.', category: 'ejercicio', emoji: '🏋️'),
    const WellnessTip(id: 'ejc_19', title: 'Ejercicio con una silla', message: 'Usa una silla como apoyo para estirar piernas, hacer sentadillas guiadas o elevaciones de talón.', category: 'ejercicio', emoji: '🪑'),
    const WellnessTip(id: 'ejc_20', title: 'Trotar en el sitio', message: 'Trota en el mismo lugar durante 2 minutos elevando las rodillas. Simple, efectivo y sin necesitar espacio.', category: 'ejercicio', emoji: '🏃'),
    const WellnessTip(id: 'ejc_21', title: 'Rutina de 5 ejercicios', message: 'Haz una mini rutina: 10 sentadillas, 10 flexiones, 10 abdominales, 10 saltos, 30 seg plancha. En 5 minutos transformas tu día.', category: 'ejercicio', emoji: '⚡'),
    const WellnessTip(id: 'ejc_22', title: 'Estira los cuellos', message: 'Inclina la cabeza suavemente hacia cada lado, manteniendo 15 segundos por lado. Alivia la tensión del escritorio.', category: 'ejercicio', emoji: '🫨'),
    const WellnessTip(id: 'ejc_23', title: 'Camina descalzo', message: 'Si es seguro, camina descalzo en pasto o tierra. El contacto con la tierra calma el sistema nervioso.', category: 'ejercicio', emoji: '🦶'),
    const WellnessTip(id: 'ejc_24', title: 'Ejercicio de equilibrio', message: 'Párate en un pie durante 30 segundos y luego cambia. Fortalece piernas y mejora la concentración.', category: 'ejercicio', emoji: '🧍'),

    // ═══════════════════════════════════════════════════════════════════════
    // RESPIRACIÓN (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'res_00', title: 'Respiración 4-7-8', message: 'Inhala 4 segundos, retén 7, exhala 8. Repite 4 veces. Es uno de los métodos más efectivos para calmar la ansiedad.', category: 'respiracion', emoji: '🌬️'),
    const WellnessTip(id: 'res_01', title: 'Respiración diafragmática', message: 'Coloca una mano en el pecho y otra en el abdomen. Al inhalar, solo la mano del abdomen se mueve. Respira así 5 minutos.', category: 'respiracion', emoji: '🫁'),
    const WellnessTip(id: 'res_02', title: 'Exhala el estrés', message: 'Inhala por nariz 4 segundos y exhala por boca como si soplara una vela. Hazlo 10 veces para liberar tensión.', category: 'respiracion', emoji: '🕯️'),
    const WellnessTip(id: 'res_03', title: 'Respiración cuadrada', message: 'Inhala 4 segundos, retén 4, exhala 4, retén 4. Repite 5 veces. Esta técnica equilibra el sistema nervioso.', category: 'respiracion', emoji: '⬛'),
    const WellnessTip(id: 'res_04', title: 'Respira al sol', message: 'Sal al sol, cierra los ojos y respira profundo 3 veces. Siente el calor en tu piel mientras inhalas luz.', category: 'respiracion', emoji: '☀️'),
    const WellnessTip(id: 'res_05', title: 'Respiración de ola', message: 'Imagina que con cada inhalación una ola sube por tu cuerpo y con cada exhalación baja relajando cada músculo.', category: 'respiracion', emoji: '🌊'),
    const WellnessTip(id: 'res_06', title: 'Contar respiraciones', message: 'Cierra los ojos y cuenta tus respiraciones del 1 al 10. Si pierdes la cuenta, empieza de nuevo sin frustración.', category: 'respiracion', emoji: '🔢'),
    const WellnessTip(id: 'res_07', title: 'Respiración alternada', message: 'Tapa una nariz con el dedo, inhala por la otra, cambia y exhala. Alterna 5 veces para equilibrar los hemisferios.', category: 'respiracion', emoji: '☯️'),
    const WellnessTip(id: 'res_08', title: 'Sopla globos', message: 'Infla un globo con la boca. El esfuerzo de soplar fortalece el diafragma y libera la tensión facial.', category: 'respiracion', emoji: '🎈'),
    const WellnessTip(id: 'res_09', title: 'Respiración del lobo', message: 'Inhala profundo por nariz y exhala con un sonido suave de "joooo" como el viento. La vibración calma la mente.', category: 'respiracion', emoji: '🐺'),
    const WellnessTip(id: 'res_10', title: 'Respirar con gratitud', message: 'Con cada inhalación piensa en algo bueno que te pasó. Con cada exhalación, agradécelo silenciosamente.', category: 'respiracion', emoji: '💚'),
    const WellnessTip(id: 'res_11', title: 'Pausa de 3 respiraciones', message: 'En cualquier momento del día, detente y respira 3 veces conscientemente. Una pausa de 30 segundos puede cambiar tu estado.', category: 'respiracion', emoji: '⏸️'),
    const WellnessTip(id: 'res_12', title: 'Respiración de abdomen', message: 'Coloca una mano en el abdomen y siente cómo se hincha al inhalar. Esta respiración activa la calma profunda.', category: 'respiracion', emoji: '🤲'),
    const WellnessTip(id: 'res_13', title: 'Exhalar más largo', message: 'Haz que cada exhalación dure el doble que la inhalación. Esto activa tu sistema de relajación natural.', category: 'respiracion', emoji: '⚖️'),
    const WellnessTip(id: 'res_14', title: 'Respiración con mantra', message: 'Al inhalar piensa "estoy", al exhalar piensa "en paz". La combinación de palabra y respiración es poderosa.', category: 'respiracion', emoji: '🕉️'),
    const WellnessTip(id: 'res_15', title: 'Respirar observando', message: 'Sin cambiar tu respiración, solo obsérvala. Nota la temperatura del aire, la velocidad, los silencios. Solo observa.', category: 'respiracion', emoji: '👁️'),
    const WellnessTip(id: 'res_16', title: 'Respiración 5-5', message: 'Inhala contando hasta 5, exhala contando hasta 5. La simetría de esta respiración crea equilibrio mental.', category: 'respiracion', emoji: '5️⃣'),
    const WellnessTip(id: 'res_17', title: 'Inhala aroma', message: 'Toma una esencia que te guste, colócala en las manos, frota y acerca a la nariz. Respira profundo 3 veces.', category: 'respiracion', emoji: '🌸'),
    const WellnessTip(id: 'res_18', title: 'Respiración de león', message: 'Inhala profundo por nariz, exhala fuerte por boca con la lengua fuera y un sonido "jaaa". Libera tensión acumulada.', category: 'respiracion', emoji: '🦁'),
    const WellnessTip(id: 'res_19', title: 'Respirar mirando el cielo', message: 'Siéntate, mira al cielo y respira lento 5 veces. La inmensidad del cielo ayuda a ganar perspectiva.', category: 'respiracion', emoji: '🌤️'),
    const WellnessTip(id: 'res_20', title: 'Respiración en V', message: 'Inhala 4 seg, retén 2 seg, exhala 6 seg. El V representa la expansión de tu calma con cada ciclo.', category: 'respiracion', emoji: '🔽'),
    const WellnessTip(id: 'res_21', title: 'Respiración del bosque', message: 'Imagina que respiras el aire fresco de un bosque. Con cada inhalación entra calma, con cada exhalación sale tensión.', category: 'respiracion', emoji: '🌲'),
    const WellnessTip(id: 'res_22', title: 'Suspiro consciente', message: 'Date permiso de suspirar profundo. El cuerpo suspira para liberar tensión, déjalo hacerlo conscientemente.', category: 'respiracion', emoji: '😮‍💨'),
    const WellnessTip(id: 'res_23', title: 'Respirar con manos', message: 'Abre las manos al inhalar, ciérralas al exhalar. El gesto físico refuerza la intención de soltar.', category: 'respiracion', emoji: '🤲'),
    const WellnessTip(id: 'res_24', title: 'Respiración antes de dormir', message: 'Acostado boca arriba, pon una mano en el pecho y respira lento 10 veces. El cuerpo se prepara para el descanso.', category: 'respiracion', emoji: '😴'),

    // ═══════════════════════════════════════════════════════════════════════
    // HIDRATACIÓN (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'hid_00', title: 'Vaso de agua ahora', message: 'Toma un vaso grande de agua en este momento. La deshidratación afecta el ánimo, la energía y la concentración.', category: 'hidratacion', emoji: '💧'),
    const WellnessTip(id: 'hid_01', title: 'Agua con limón', message: 'Corta un limón y agrégalo a tu agua. El sabor hace que bebas más y la vitamina C te despierta.', category: 'hidratacion', emoji: '🍋'),
    const WellnessTip(id: 'hid_02', title: 'Botella visible', message: 'Pon tu botella de agua en la mesa de trabajo. Si la ves, recordarás beber. La visibilidad genera el hábito.', category: 'hidratacion', emoji: '🫗'),
    const WellnessTip(id: 'hid_03', title: 'Agua templada', message: 'Prueba beber agua tibia con un poco de miel. Es más suave para el estómago y despierta el cuerpo.', category: 'hidratacion', emoji: '☕'),
    const WellnessTip(id: 'hid_04', title: 'Alta hidratación', message: 'Incluye sandía, pepino o naranja en tu comida. Estos alimentos contienen más del 85% de agua.', category: 'hidratacion', emoji: '🍉'),
    const WellnessTip(id: 'hid_05', title: 'Recordatorio cada hora', message: 'Pone una alarma cada hora para beber un trago de agua. Pequeños sorbos constantes son más efectivos.', category: 'hidratacion', emoji: '⏰'),
    const WellnessTip(id: 'hid_06', title: 'Té de hierbas', message: 'Prepara un té sin cafeína: manzanilla, hierbabuena o jengibre. Calienta, respira el vapor y bebe despacio.', category: 'hidratacion', emoji: '🍵'),
    const WellnessTip(id: 'hid_07', title: 'Agua fría al despertar', message: 'Lo primero al levantarte, bebe un vaso de agua fría. Activa el metabolismo y despierta tus células.', category: 'hidratacion', emoji: '🧊'),
    const WellnessTip(id: 'hid_08', title: 'Infusión de pepino', message: 'Corta rodajas de pepino y déjalas en agua fría 30 minutos. Un refrescante natural sin azúcar.', category: 'hidratacion', emoji: '🥒'),
    const WellnessTip(id: 'hid_09', title: 'Hidratación y piel', message: 'La piel seca puede ser señal de deshidratación. Beber agua mejorora la textura y luminosidad de tu piel.', category: 'hidratacion', emoji: '✨'),
    const WellnessTip(id: 'hid_10', title: 'Agua con menta', message: 'Añade hojas de menta fresca a tu agua. El sabor es refrescante y ayuda a la digestión.', category: 'hidratacion', emoji: '🌿'),
    const WellnessTip(id: 'hid_11', title: 'Calorías ocultas', message: 'Reemplaza un refresco por agua con fruta. Reducir azúcar y aumentar agua es un doble beneficio.', category: 'hidratacion', emoji: '🚫'),
    const WellnessTip(id: 'hid_12', title: 'Agua en el baño', message: 'Lleva un vaso de agua al baño mientras te preparas. Aprovecha ese tiempo para hidratarte.', category: 'hidratacion', emoji: '🚿'),
    const WellnessTip(id: 'hid_13', title: 'Sopa de verduras', message: 'Una sopa caliente es una excelente forma de hidratarse y nutrirse al mismo tiempo. Ideal por la noche.', category: 'hidratacion', emoji: '🥣'),
    const WellnessTip(id: 'hid_14', title: 'Color de la orina', message: 'Si tu orina es oscura, necesitas más agua. El color claro indica buena hidratación. Observa tu cuerpo.', category: 'hidratacion', emoji: '🟡'),
    const WellnessTip(id: 'hid_15', title: 'Agua y ejercicio', message: 'Bebe un vaso 30 minutos antes de hacer ejercicio y otro después. Tu cuerpo necesita reposición.', category: 'hidratacion', emoji: '🏃'),
    const WellnessTip(id: 'hid_16', title: 'Fruta congelada', message: 'Congela trozos de fruta y úsalos en lugar de hielo. Te hidratas y tomas vitaminas al mismo tiempo.', category: 'hidratacion', emoji: '🍇'),
    const WellnessTip(id: 'hid_17', title: 'Agua con jengibre', message: 'Ralla un poco de jengibre en tu agua caliente. Es antiinflamatorio, digestivo y da un toque especiado.', category: 'hidratacion', emoji: '🫚'),
    const WellnessTip(id: 'hid_18', title: 'Meta visible', message: 'Escribe en un papel "Beber 8 vasos hoy" y pégalo donde lo veas. La intención escrita se hace más real.', category: 'hidratacion', emoji: '📝'),
    const WellnessTip(id: 'hid_19', title: 'Agua y dolor de cabeza', message: 'Muchos dolores de cabeza se deben a la deshidratación. Antes de buscar una pastilla, prueba con agua.', category: 'hidratacion', emoji: '🤕'),
    const WellnessTip(id: 'hid_20', title: 'Copa de cerámica', message: 'Usa una taza bonita que te guste. El placer estético hace que beber agua se convierta en un ritual.', category: 'hidratacion', emoji: '🏺'),
    const WellnessTip(id: 'hid_21', title: 'Agua antes de comer', message: 'Bebe un vaso de agua 20 minutos antes de cada comida. Ayuda a la digestión y controla el apetito.', category: 'hidratacion', emoji: '🍽️'),
    const WellnessTip(id: 'hid_22', title: 'Hidratación nocturna', message: 'Si te despiertas sediento, ten una botella pequeña junto a la cama. Evita beber demasiado para no interrumpir el sueño.', category: 'hidratacion', emoji: '🛏️'),
    const WellnessTip(id: 'hid_23', title: 'Cómete el agua', message: 'Incluye frutas con alto contenido de agua en tu desayuno: naranja, uva, fresa. Comer también es hidratarte.', category: 'hidratacion', emoji: '🍓'),
    const WellnessTip(id: 'hid_24', title: 'Brinda por ti', message: 'Levanta tu vaso de agua y brinda por tu bienestar. Celebrar pequeños hábitos los convierte en rutinas.', category: 'hidratacion', emoji: '🥂'),

    // ═══════════════════════════════════════════════════════════════════════
    // ALIMENTACIÓN (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'ali_00', title: 'Colores en el plato', message: 'Intenta que tu plato tenga al menos 3 colores diferentes. Cada color representa nutrientes distintos.', category: 'alimentacion', emoji: '🌈'),
    const WellnessTip(id: 'ali_01', title: 'Desayuno con proteína', message: 'Incluye huevo, yogurt o frutos secos en tu desayuno. La proteína te mantiene lleno y concentrado por más tiempo.', category: 'alimentacion', emoji: '🍳'),
    const WellnessTip(id: 'ali_02', title: 'Come despacio', message: 'Mastica cada bocado al menos 20 veces. Comer lento mejora la digestión y te permite reconocer la saciedad.', category: 'alimentacion', emoji: '🐢'),
    const WellnessTip(id: 'ali_03', title: 'Fruta de la temporada', message: 'Compra una fruta de temporada y disfrútala. Fresca, más económica y más nutritiva que cualquier suplemento.', category: 'alimentacion', emoji: '🍑'),
    const WellnessTip(id: 'ali_04', title: 'Cocina algo simple', message: 'Prepara algo sencillo en casa: una ensalada, una sopa o un sándwich con ingredientes frescos.', category: 'alimentacion', emoji: '🥗'),
    const WellnessTip(id: 'ali_05', title: 'Semillas en tu comida', message: 'Añade chía, linaza o girasol a tu comida. Son pequeñas pero están llenas de omega-3 y fibra.', category: 'alimentacion', emoji: '🌻'),
    const WellnessTip(id: 'ali_06', title: 'Reduce el azúcar', message: 'Hoy intenta no agregar azúcar a nada. Usa canela o vainilla como alternativa para endulzar naturalmente.', category: 'alimentacion', emoji: '🚫'),
    const WellnessTip(id: 'ali_07', title: 'Snack saludable', message: 'Ten frutas secas, zanahoria con hummus o yogur como alternativas al snack procesado.', category: 'alimentacion', emoji: '🥕'),
    const WellnessTip(id: 'ali_08', title: 'Verduras crudas', message: 'Come una porción de verduras crudas hoy: apio, pepino, zanahoria. Conservan todas sus vitaminas.', category: 'alimentacion', emoji: '🥦'),
    const WellnessTip(id: 'ali_09', title: 'Cena ligera', message: 'Cena al menos 2 horas antes de dormir y que sea ligera: ensalada, sopa o vegetales al vapor.', category: 'alimentacion', emoji: '🌙'),
    const WellnessTip(id: 'ali_10', title: 'Plato completo', message: 'Incluye proteína, carbohidrato complejo y grasa saludable en cada comida principal. Tu cuerpo necesita los tres.', category: 'alimentacion', emoji: '🍽️'),
    const WellnessTip(id: 'ali_11', title: 'Escucha tu hambre', message: 'Antes de comer, pregúntate: ¿tengo realmente hambre o es aburrimiento, estrés o costumbre?', category: 'alimentacion', emoji: '🤔'),
    const WellnessTip(id: 'ali_12', title: 'Agua entre comidas', message: 'Bebe agua entre comidas, no durante. Ayuda a la digestión sin diluir los jugos gástricos.', category: 'alimentacion', emoji: '💧'),
    const WellnessTip(id: 'ali_13', title: 'Aguacate today', message: 'Incluye aguacate en una comida. Sus grasas saludables nutren el cerebro y mantienen la piel luminosa.', category: 'alimentacion', emoji: '🥑'),
    const WellnessTip(id: 'ali_14', title: 'Pausa para saborear', message: 'En tu próxima comida, cierra los ojos en el primer bocado. Saborear conscientemente multiplica el placer.', category: 'alimentacion', emoji: '😋'),
    const WellnessTip(id: 'ali_15', title: 'Comida fermentada', message: 'Incluye kimchi, yogur o chucrut. Los alimentos fermentados nutren tu microbiota intestinal y mejoran el ánimo.', category: 'alimentacion', emoji: '🫙'),
    const WellnessTip(id: 'ali_16', title: 'Planifica tu comida', message: 'Piensa en qué vas a comer mañana. Planificar reduce la ansiedad y mejora la calidad de lo que comes.', category: 'alimentacion', emoji: '📋'),
    const WellnessTip(id: 'ali_17', title: 'Proteína vegetal', message: 'Prueba un día con proteína vegetal: lentejas, garbanzos, tofu. Son nutritivos, económicos y deliciosos.', category: 'alimentacion', emoji: '🫘'),
    const WellnessTip(id: 'ali_18', title: 'Cereal integral', message: 'Cambia el cereal refinado por integral. La fibra mantiene estable el azúcar en sangre y la energía constante.', category: 'alimentacion', emoji: '🌾'),
    const WellnessTip(id: 'ali_19', title: 'Colores oscuros', message: 'Come algo de color oscuro hoy: arándanos, espinaca, berenjena. Los antioxidantes protegen tu cuerpo.', category: 'alimentacion', emoji: '🫐'),
    const WellnessTip(id: 'ali_20', title: 'Comparte una comida', message: 'Si es posible, come acompañado. Compartir comida fortalece vínculos y hace la experiencia más placentera.', category: 'alimentacion', emoji: '👨‍👩‍👧'),
    const WellnessTip(id: 'ali_21', title: 'Nueces y almendras', message: 'Un puñado de nueces o almendras es un snack perfecto: proteína, grasas buenas y minerales esenciales.', category: 'alimentacion', emoji: '🥜'),
    const WellnessTip(id: 'ali_22', title: 'Plato no lleno', message: 'Sirve un poco menos de lo que crees necesario. Puedes repetir si sigues con hambre, pero empieza con moderación.', category: 'alimentacion', emoji: '🫙'),
    const WellnessTip(id: 'ali_23', title: 'Té o café sin azúcar', message: 'Hoy prueba tu té o café sin agregar azúcar. Tu paladar se adapta y descubres los sabores reales.', category: 'alimentacion', emoji: '☕'),
    const WellnessTip(id: 'ali_24', title: 'Gracias por la comida', message: 'Antes de comer, toma un momento para agradecer. No tiene que ser religioso, solo consciente y sincero.', category: 'alimentacion', emoji: '🙏'),

    // ═══════════════════════════════════════════════════════════════════════
    // SUEÑO (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'sue_00', title: 'Hora fija de dormir', message: 'Acuéstate a la misma hora esta noche, aunque no tengas sueño. Tu cuerpo aprenderá el ritmo.', category: 'sueno', emoji: '🛏️'),
    const WellnessTip(id: 'sue_01', title: 'Sin pantallas 30 min', message: 'Deja el celular 30 minutos antes de dormir. La luz azul engaña a tu cerebro y retrasa el sueño.', category: 'sueno', emoji: '📵'),
    const WellnessTip(id: 'sue_02', title: 'Oscuridad total', message: 'Apaga todas las luces, incluye las del standby. La oscuridad completa estimula la producción de melatonina.', category: 'sueno', emoji: '🌑'),
    const WellnessTip(id: 'sue_03', title: 'Rutina nocturna', message: 'Crea una rutina de 15 minutos antes de dormir: lavarte la cara, estirarte, leer. Tu cuerpo reconocerá las señales.', category: 'sueno', emoji: '✨'),
    const WellnessTip(id: 'sue_04', title: 'Temperatura fresca', message: 'Mantén la habitación entre 18 y 20 grados. Un ambiente fresco favorece un sueño profundo.', category: 'sueno', emoji: '🌡️'),
    const WellnessTip(id: 'sue_05', title: 'Cuaderno junto a la cama', message: 'Antes de dormir, escribe tus preocupaciones en un cuerno. Sacarlas de la mente al papel te libera.', category: 'sueno', emoji: '📓'),
    const WellnessTip(id: 'sue_06', title: 'Café después del mediodía', message: 'Evita la cafeína después de las 2 PM. La cafeína tarda hasta 8 horas en eliminarse del cuerpo.', category: 'sueno', emoji: '☕'),
    const WellnessTip(id: 'sue_07', title: 'Siesta corta', message: 'Si necesitas dormir la siesta, que sea de 20 minutos máximo. Más tiempo dificulta el sueño nocturno.', category: 'sueno', emoji: '💤'),
    const WellnessTip(id: 'sue_08', title: 'Estira antes de dormir', message: 'Haz 5 estiramientos suaves antes de acostarte: cuello, hombros, espalda baja, piernas, tobillos.', category: 'sueno', emoji: '🧘'),
    const WellnessTip(id: 'sue_09', title: 'Cama solo para dormir', message: 'No trabajes, comas o veas series en la cama. Asociar la cama solo con dormir mejora la calidad del descanso.', category: 'sueno', emoji: '🛏️'),
    const WellnessTip(id: 'sue_10', title: 'Respira para dormir', message: 'Acostado, respira 4-7-8: inhala 4 seg, retén 7 seg, exhala 8 seg. Repite 4 veces y siente cómo el cuerpo se rinde.', category: 'sueno', emoji: '🌬️'),
    const WellnessTip(id: 'sue_11', title: 'Baño caliente', message: 'Toma un baño o ducha caliente 90 minutos antes de dormir. El cambio de temperatura provoca sueño natural.', category: 'sueno', emoji: '🛁'),
    const WellnessTip(id: 'sue_12', title: 'Almohada correcta', message: 'Asegúrate de que tu almohada mantenga la cabeza alineada con la espalda. Una almohada incorrecta causa dolor.', category: 'sueno', emoji: '🛌'),
    const WellnessTip(id: 'sue_13', title: 'Sonido relajante', message: 'Pon lluvia, olas del mar o ruido blanco de fondo. Los sonidos constantes calman la mente inquieta.', category: 'sueno', emoji: '🌊'),
    const WellnessTip(id: 'sue_14', title: 'Evita siestas largas', message: 'Si dormiste mal, resiste la tentación de dormir mucho de día. Mejora tu higiene del sueño en lugar de compensar.', category: 'sueno', emoji: '⏰'),
    const WellnessTip(id: 'sue_15', title: 'Lavado de cara', message: 'Lávate la cara con agua fresca antes de dormir. El gesto le dice a tu cuerpo que el día terminó.', category: 'sueno', emoji: '🧼'),
    const WellnessTip(id: 'sue_16', title: 'Agua tibia con miel', message: 'Bebe una taza de agua tibia con una cucharada de miel. La miel aumenta la serotonina que se convierte en melatonina.', category: 'sueno', emoji: '🍯'),
    const WellnessTip(id: 'sue_17', title: 'Oscurece tu cuarto', message: 'Cubre cualquier luz LED o de standby con cinta. La mínima luz puede interrumpir tu ciclo de sueño profundo.', category: 'sueno', emoji: '🌑'),
    const WellnessTip(id: 'sue_18', title: 'Journaling nocturno', message: 'Escribe 3 cosas positivas de tu día antes de dormir. Terminar con gratitud transforma la calidad del sueño.', category: 'sueno', emoji: '✍️'),
    const WellnessTip(id: 'sue_19', title: 'Evita cenas pesadas', message: 'Las cenas pesadas obligan a tu cuerpo a digerir mientras debería descansar. Come ligero por la noche.', category: 'sueno', emoji: '🍕'),
    const WellnessTip(id: 'sue_20', title: 'Ropa cómoda', message: 'Usa ropa suelta y de algodón para dormir. Ropa ajustada interrumpe la circulación y el confort.', category: 'sueno', emoji: '👕'),
    const WellnessTip(id: 'sue_21', title: 'Música suave', message: 'Pon música instrumental suave a bajo volumen mientras te preparas para dormir. La relajación empieza antes de la cama.', category: 'sueno', emoji: '🎵'),
    const WellnessTip(id: 'sue_22', title: 'Despierta natural', message: 'Si puedes, despierta sin alarma al menos un día a la semana. Tu cuerpo sabe cuándo ha descansado suficiente.', category: 'sueno', emoji: '🌅'),
    const WellnessTip(id: 'sue_23', title: 'Manta pesada', message: 'Si tienes dificultad para dormir, prueba con una manta pesada. La presión constante activa el sistema de calma.', category: 'sueno', emoji: '🧵'),
    const WellnessTip(id: 'sue_24', title: 'Duerme en la oscuridad', message: 'Si no puedes oscurecer todo, usa antifaz. Bloquear la luz mejora la calidad del sueño REM significativamente.', category: 'sueno', emoji: '😴'),

    // ═══════════════════════════════════════════════════════════════════════
    // PRODUCTIVIDAD (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'pro_00', title: 'Regla de 2 minutos', message: 'Si algo toma menos de 2 minutos, hazlo ahora. No lo pospongas, no lo anotes, solo hazlo.', category: 'productividad', emoji: '⏱️'),
    const WellnessTip(id: 'pro_01', title: 'Prioriza lo difícil', message: 'Haz la tarea más difícil primero, cuando tienes más energía. Todo lo demás después será más fácil.', category: 'productividad', emoji: '🎯'),
    const WellnessTip(id: 'pro_02', title: 'Pomodoro de 25 min', message: 'Trabaja enfocado durante 25 minutos sin distracciones, luego toma un descanso de 5 minutos.', category: 'productividad', emoji: '🍅'),
    const WellnessTip(id: 'pro_03', title: 'Lista de 3 cosas', message: 'Escribe solo 3 tareas importantes para hoy. Si completas esas 3, el día fue productivo. No más.', category: 'productividad', emoji: '📋'),
    const WellnessTip(id: 'pro_04', title: 'Limpia tu escritorio', message: 'Organiza tu espacio de trabajo en 5 minutos. Un escritorio limpio genera una mente más clara.', category: 'productividad', emoji: '🗂️'),
    const WellnessTip(id: 'pro_05', title: 'Di no a una tarea', message: 'Rechaza o delega una tarea que no es realmente tuya. Proteger tu tiempo es un acto de autocuidado.', category: 'productividad', emoji: '🚫'),
    const WellnessTip(id: 'pro_06', title: 'Sin notificaciones', message: 'Apaga las notificaciones del celular por 1 hora. Notarás cuánto más enfocado estás sin interrupciones.', category: 'productividad', emoji: '🔕'),
    const WellnessTip(id: 'pro_07', title: 'Planifica mañana', message: 'Antes de terminar el día, escribe las 3 prioridades de mañana. Tu mente descansa mejor con un plan.', category: 'productividad', emoji: '📝'),
    const WellnessTip(id: 'pro_08', title: 'Batch processing', message: 'Agrupa tareas similares: responde todos los correos juntos, haz todas las llamadas juntas. Cambiar de contexto cuesta.', category: 'productividad', emoji: '📦'),
    const WellnessTip(id: 'pro_09', title: 'Descansa de verdad', message: 'Durante tu descanso, levántate, mueve el cuerpo y mira algo lejos. No uses el celular como descanso.', category: 'productividad', emoji: '🚶'),
    const WellnessTip(id: 'pro_10', title: 'Empieza por lo fácil', message: 'Si no tienes energía, empieza por una tarea fácil para crear impulso. El momentum es real.', category: 'productividad', emoji: '🚀'),
    const WellnessTip(id: 'pro_11', title: 'Una tarea a la vez', message: 'Haz una cosa a la vez. El multitasking reduce la calidad y aumenta el estrés. Enfócate en lo inmediato.', category: 'productividad', emoji: '🎯'),
    const WellnessTip(id: 'pro_12', title: 'Timer de 10 minutos', message: 'Si una tarea te da pereza, comprométete solo con 10 minutos. Generalmente seguirás después.', category: 'productividad', emoji: '🔟'),
    const WellnessTip(id: 'pro_13', title: 'Recompénsate', message: 'Después de completar algo difícil, date un premio: un café, una caminata, 10 minutos de tu serie favorita.', category: 'productividad', emoji: '🎉'),
    const WellnessTip(id: 'pro_14', title: 'Energía y tiempo', message: 'Identifica tus horas de mayor energía y úsalas para lo importante. No todo el tiempo vale lo mismo.', category: 'productividad', emoji: '⚡'),
    const WellnessTip(id: 'pro_15', title: 'Aprende a delegar', message: 'No tienes que hacerlo todo. Delegar no es debilidad, es inteligencia. Confía en otros.', category: 'productividad', emoji: '🤝'),
    const WellnessTip(id: 'pro_16', title: 'Pausa de 5 minutos', message: 'Cada hora, toma 5 minutos para estirar, respirar o mirar por la ventana. La productividad requiere descanso.', category: 'productividad', emoji: '☕'),
    const WellnessTip(id: 'pro_17', title: 'Técnica del 2-min', message: 'Si recibes un correo que puedes responder en 2 minutos, respóndelo de inmediato. No lo dejes para después.', category: 'productividad', emoji: '📧'),
    const WellnessTip(id: 'pro_18', title: 'Celebra lo pequeño', message: 'Marca con un palito o check cada tarea completada. La sensación de progreso alimenta la motivación.', category: 'productividad', emoji: '✅'),
    const WellnessTip(id: 'pro_19', title: 'Diario de productividad', message: 'Al final del día, anota qué funcionó y qué no. La reflexión constante mejora tu sistema.', category: 'productividad', emoji: '📔'),
    const WellnessTip(id: 'pro_20', title: 'Ambiente de trabajo', message: 'Pon música instrumental o sonidos de lluvia de fondo. El ambiente adecuado activa el modo concentración.', category: 'productividad', emoji: '🎵'),
    const WellnessTip(id: 'pro_21', title: 'Revisa tu progreso', message: 'Mira lo que lograste esta semana, no lo que falta. Reconocer el avance mantiene la motivación.', category: 'productividad', emoji: '📈'),
    const WellnessTip(id: 'pro_22', title: 'Matutino sin celular', message: 'Las primeras 30 minutos del día, no revises el celular. Empieza el día con tu agenda, no con la de otros.', category: 'productividad', emoji: '🌅'),
    const WellnessTip(id: 'pro_23', title: 'Automatiza lo repetitivo', message: 'Si haces algo igual más de 3 veces, busca una forma de automatizarlo. Tu tiempo es valioso.', category: 'productividad', emoji: '🤖'),
    const WellnessTip(id: 'pro_24', title: 'Sé realista', message: 'No llenes tu agenda de 10 tareas. Es mejor comprometerte con 3 y cumplirlas que prometer 10 y fallar.', category: 'productividad', emoji: '🎯'),

    // ═══════════════════════════════════════════════════════════════════════
    // MINDFULNESS (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'min_00', title: '5 sentidos ahora', message: 'Nombra 5 cosas que ves, 4 que tocas, 3 que oyes, 2 que hueles y 1 que saboreas. Ancla tu mente al presente.', category: 'mindfulness', emoji: '🖐️'),
    const WellnessTip(id: 'min_01', title: 'Atención plena', message: 'Durante 2 minutos, pon toda tu atención en una sola cosa: el respirar, el sonido, el tacto. Cuando la mente divague, regresa.', category: 'mindfulness', emoji: '🧘'),
    const WellnessTip(id: 'min_02', title: 'Caminata consciente', message: 'Camina despacio durante 5 minutos notando cada paso: el peso, el movimiento, el contacto con el suelo.', category: 'mindfulness', emoji: '👣'),
    const WellnessTip(id: 'min_03', title: 'Observa sin juzgar', message: 'Observa lo que sientes sin decir si es bueno o malo. Solo nombra: "estoy sintiendo tristeza". Sin juicio, solo presencia.', category: 'mindfulness', emoji: '👁️'),
    const WellnessTip(id: 'min_04', title: 'Comida consciente', message: 'En tu próxima comida, mira la comida antes de comerla. Nota colores, texturas, olores. Come sin distracciones.', category: 'mindfulness', emoji: '🍽️'),
    const WellnessTip(id: 'min_05', title: 'Siente el agua', message: 'Al lavarte las manos, siente la temperatura del agua, la textura del jabón. Convierte lo cotidiano en ritual.', category: 'mindfulness', emoji: '🧼'),
    const WellnessTip(id: 'min_06', title: 'Escucha activamente', message: 'En tu próxima conversación, escucha sin preparar tu respuesta. Solo escucha. Notarás una diferencia enorme.', category: 'mindfulness', emoji: '👂'),
    const WellnessTip(id: 'min_07', title: 'Nombra tu emoción', message: 'Pregúntate: ¿qué estoy sintiendo ahora? Nombra la emoción sin intentar cambiarla. Nombrarla es el primer paso para gestionarla.', category: 'mindfulness', emoji: '💭'),
    const WellnessTip(id: 'min_08', title: 'Grounding 5-4-3-2-1', message: 'Si te sientes ansioso, usa esta técnica: 5 cosas que ves, 4 que tocas, 3 que oyes, 2 que hueles, 1 que saboreas.', category: 'mindfulness', emoji: '🌍'),
    const WellnessTip(id: 'min_09', title: 'Respira y nombra', message: 'Inhala pensando "estoy", exhala pensando "aquí". Respirar con presencia te conecta con el momento.', category: 'mindfulness', emoji: '🕉️'),
    const WellnessTip(id: 'min_10', title: 'Paseo sin destino', message: 'Sal a caminar sin un destino fijo. Sinurge, sin meta, sin tiempo. Solo camina y observa lo que aparece.', category: 'mindfulness', emoji: '🍃'),
    const WellnessTip(id: 'min_11', title: 'Mira el cielo', message: 'Dedica 2 minutos a mirar el cielo sin pensar en nada. Nota las nubes, el color, el movimiento lento.', category: 'mindfulness', emoji: '☁️'),
    const WellnessTip(id: 'min_12', title: 'Check-in corporal', message: 'Recorre tu cuerpo de pies a cabeza: ¿dónde hay tensión? ¿Dónde hay calma? Solo nota, no intentes cambiar nada.', category: 'mindfulness', emoji: '🦵'),
    const WellnessTip(id: 'min_13', title: 'Taza de té consciente', message: 'Prepara y bebe una taza de té sin prisas. Siente el calor, el vapor, el sabor. Un momento completo.', category: 'mindfulness', emoji: '🍵'),
    const WellnessTip(id: 'min_14', title: 'Suelta el control', message: 'Acepta algo que no puedes cambiar hoy. Decir "esto es lo que hay" libera una enormidad de energía.', category: 'mindfulness', emoji: '🕊️'),
    const WellnessTip(id: 'min_15', title: 'Escucha la lluvia', message: 'Si llueve, abre la ventana y escucha 2 minutos. La lluvia tiene una frecuencia que calma el sistema nervioso.', category: 'mindfulness', emoji: '🌧️'),
    const WellnessTip(id: 'min_16', title: 'Agradecer en silencio', message: 'Siéntate 1 minuto en silencio y piensa en algo por lo que estás agradecido. No lo escribas, solo siéntelo.', category: 'mindfulness', emoji: '🙏'),
    const WellnessTip(id: 'min_17', title: 'Manos en la tierra', message: 'Si tienes una planta, toca la tierra. Si no, siembra algo. Conectar con la tierra es uno de los anclajes más antiguos.', category: 'mindfulness', emoji: '🌱'),
    const WellnessTip(id: 'min_18', title: 'Micro-meditación', message: 'En cualquier momento del día, cierra los ojos 3 respiraciones. Eso es meditación. No necesitas más.', category: 'mindfulness', emoji: '💫'),
    const WellnessTip(id: 'min_19', title: 'Observa las manos', message: 'Mira tus manos durante 1 minuto. Observa líneas, texturas, movimientos. Tus manos cuentan tu historia.', category: 'mindfulness', emoji: '🤲'),
    const WellnessTip(id: 'min_20', title: 'Escucha sin palabras', message: 'Siéntate en silencio 2 minutos y escucha todos los sonidos alrededor. Los lejanos, los cercanos, los constantes.', category: 'mindfulness', emoji: '🎶'),
    const WellnessTip(id: 'min_21', title: 'Rutina consciente', message: 'Elige una rutina diaria (cepillar dientes, lavar platos) y hazla con atención plena. Transforma lo mundane.', category: 'mindfulness', emoji: '🔄'),
    const WellnessTip(id: 'min_22', title: 'Respira con la naturaleza', message: 'Si estás cerca de un árbol, siéntate bajo él y respira 5 veces. Los árboles generan calma solo con estar cerca.', category: 'mindfulness', emoji: '🌳'),
    const WellnessTip(id: 'min_23', title: 'Siente tu ropa', message: 'Pon atención a la textura de tu ropa contra tu piel. Nota el tejido, la temperatura, la presión. Es mindfulness puro.', category: 'mindfulness', emoji: '👕'),
    const WellnessTip(id: 'min_24', title: 'Sé uno con el momento', message: 'No necesitas cambiar nada de este momento. Este momento ya es suficiente. Tú ya eres suficiente.', category: 'mindfulness', emoji: '💛'),

    // ═══════════════════════════════════════════════════════════════════════
    // RELACIONES (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'rel_00', title: 'Mensaje de cariño', message: 'Envía un mensaje a alguien que quieras, solo para decirle que piensas en él. Sin razón, sin necesidad.', category: 'relaciones', emoji: '💌'),
    const WellnessTip(id: 'rel_01', title: 'Escucha sin aconsejar', message: 'Cuando alguien te comparta algo, solo escucha. No des consejos a menos que te los pidan. Solo presencia.', category: 'relaciones', emoji: '👂'),
    const WellnessTip(id: 'rel_02', title: 'Agradecimiento directo', message: 'Dile a alguien en persona algo que aprecias de él/ella. La gratitud expresada fortalece cualquier vínculo.', category: 'relaciones', emoji: '💚'),
    const WellnessTip(id: 'rel_03', title: 'Abrazo de 20 seg', message: 'Abraza a alguien que quieras durante al menos 20 segundos. Los abrazos largos liberan oxitocina, la hormona del apego.', category: 'relaciones', emoji: '🤗'),
    const WellnessTip(id: 'rel_04', title: 'Pregunta genuina', message: 'Pregunta a alguien: "¿cómo estás realmente?" y espera la respuesta. Mostrar interés genuino conecta profundamente.', category: 'relaciones', emoji: '❓'),
    const WellnessTip(id: 'rel_05', title: 'Recuerda un detalle', message: 'Recuerda algo importante que alguien te contó y pregunta por ello. Ser escuchado y recordado es un regalo.', category: 'relaciones', emoji: '💡'),
    const WellnessTip(id: 'rel_06', title: 'Perdón pendiente', message: 'Si tienes algo pendiente con alguien, considera soltarlo. El perdón no es para ellos, es para tu paz.', category: 'relaciones', emoji: '🕊️'),
    const WellnessTip(id: 'rel_07', title: 'Tiempo de calidad', message: 'Dedica 15 minutos de atención total a alguien importante. Sin celular, sin distracciones. Solo ustedes.', category: 'relaciones', emoji: '⏰'),
    const WellnessTip(id: 'rel_08', title: 'Cumpleaños recordado', message: 'Escribe los cumpleaños de las personas importantes en tu calendario. Recordarlos es un acto de amor.', category: 'relaciones', emoji: '🎂'),
    const WellnessTip(id: 'rel_09', title: 'Celebra lo ajeno', message: 'Celebra el logro de alguien más con genuino entusiasmo. La abundancia emocional no tiene límites.', category: 'relaciones', emoji: '🎉'),
    const WellnessTip(id: 'rel_10', title: 'Límites sanos', message: 'Aprende a decir "no" con amabilidad. Tener límites no te hace egoísta, te hace sano.', category: 'relaciones', emoji: '🚧'),
    const WellnessTip(id: 'rel_11', title: 'Disculpa sincera', message: 'Si fallaste, pide disculpas sin excusas. Un "me equivoqué, lo siento" genuino repara más de lo que crees.', category: 'relaciones', emoji: '🙏'),
    const WellnessTip(id: 'rel_12', title: 'Escritura para otro', message: 'Escribe una carta o nota para alguien que aprecias. No tienes que enviarla, solo escribirla ya es poderoso.', category: 'relaciones', emoji: '✉️'),
    const WellnessTip(id: 'rel_13', title: 'Risa compartida', message: 'Mira algo gracioso con alguien o cuenta un chiste. Reír juntos crea lazos que nada más puede crear.', category: 'relaciones', emoji: '😂'),
    const WellnessTip(id: 'rel_14', title: 'Escucha tu interior', message: 'Pregúntate: ¿hay alguien a quien le tengas cariño pero no le has dicho? La vida es corta para callar el amor.', category: 'relaciones', emoji: '💛'),
    const WellnessTip(id: 'rel_15', title: 'Evita el teléfono', message: 'Cuando estés con alguien, pon el celular boca abajo. La atención completa es el mayor regalo que puedes dar.', category: 'relaciones', emoji: '📵'),
    const WellnessTip(id: 'rel_16', title: 'Pregunta por su vida', message: 'Pregunta a alguien qué ha sido lo mejor de su semana. Mostrar interés genuino fortalece la conexión.', category: 'relaciones', emoji: '💬'),
    const WellnessTip(id: 'rel_17', title: 'Tolerancia activa', message: 'Hoy intenta no criticar a nadie. Si algo te molesta, respira y busca comprender antes de juzgar.', category: 'relaciones', emoji: '🕊️'),
    const WellnessTip(id: 'rel_18', title: 'Conexión física', message: 'Un toque en el hombro, una caricia en la mano, un abrazo inesperado. El contacto físico sano alimenta el alma.', category: 'relaciones', emoji: '🫂'),
    const WellnessTip(id: 'rel_19', title: 'Pide ayuda', message: 'Permitirte pedir ayuda no es debilidad, es fortaleza. La vulnerabilidad genera conexión genuina.', category: 'relaciones', emoji: '🤝'),
    const WellnessTip(id: 'rel_20', title: 'Escucha sin interrumpir', message: 'En tu próxima conversación, deja que la otra persona termine antes de hablar. El silencio también comunica respeto.', category: 'relaciones', emoji: '🤫'),
    const WellnessTip(id: 'rel_21', title: 'Sorpresa pequeña', message: 'Haz algo inesperado por alguien: prepara su café, deja una nota, compra su snack favorito. Las sorpresas pequeñas importan.', category: 'relaciones', emoji: '🎁'),
    const WellnessTip(id: 'rel_22', title: 'Perdona tu error', message: 'Si fallaste con alguien, primero perdónate a ti mismo. El autocastigo no ayuda a reparar nada.', category: 'relaciones', emoji: '💖'),
    const WellnessTip(id: 'rel_23', title: 'Conecta con alguien viejo', message: 'Escribe a alguien con quien has perdido el contacto. Un simple "hace tiempo que no hablamos" puede reavivar un vínculo.', category: 'relaciones', emoji: '📱'),
    const WellnessTip(id: 'rel_24', title: 'Gratitud compartida', message: 'Cena o toma algo con alguien y dediquen 5 minutos a compartir cosas por las que están agradecidos.', category: 'relaciones', emoji: '🥂'),

    // ═══════════════════════════════════════════════════════════════════════
    // NATURALEZA (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'nat_00', title: 'Sal al sol', message: 'Pasa 10 minutos al aire libre bajo el sol de la mañana. La vitamina D y la luz natural regulan tu ritmo circadiano.', category: 'naturaleza', emoji: '☀️'),
    const WellnessTip(id: 'nat_01', title: 'Observa las nubes', message: 'Acuéstate en el pasto o míralas por la ventana. Las nubes en movimiento recuerdan que todo es temporal.', category: 'naturaleza', emoji: '☁️'),
    const WellnessTip(id: 'nat_02', title: 'Abraza un árbol', message: 'Sí, literalmente. Un abrazo a un árbol conecta con la energía de la naturaleza y reduce el cortisol.', category: 'naturaleza', emoji: '🌳'),
    const WellnessTip(id: 'nat_03', title: 'Jardinería mínima', message: 'Siembra una semilla en una maceta. Cuidar algo que crece te enseña paciencia y te conecta con la vida.', category: 'naturaleza', emoji: '🌱'),
    const WellnessTip(id: 'nat_04', title: 'Piso descalzo', message: 'Camina descalzo sobre pasto, tierra o arena. El contacto directo con la tierra reduce la inflamación y calma.', category: 'naturaleza', emoji: '🦶'),
    const WellnessTip(id: 'nat_05', title: 'Escucha pájaros', message: 'Sal al exterior o abre la ventana y escucha el canto de los pájaros durante 5 minutos. Su sonido es terapéutico.', category: 'naturaleza', emoji: '🐦'),
    const WellnessTip(id: 'nat_06', title: 'Atardecer consciente', message: 'Busca un lugar donde ver el atardecer. Observa los colores cambiar sin prisa. La naturaleza es arte.', category: 'naturaleza', emoji: '🌅'),
    const WellnessTip(id: 'nat_07', title: 'Colecta algo natural', message: 'Recoge una hoja, piedra o flor. Ponla en tu escritorio. Un recordatorio de la naturaleza en tu día.', category: 'naturaleza', emoji: '🍂'),
    const WellnessTip(id: 'nat_08', title: 'Agua en movimiento', message: 'Si hay un río, fuente o cascada cerca, ve y escucha el agua. El sonido de agua en movimiento calma profundamente.', category: 'naturaleza', emoji: '🏞️'),
    const WellnessTip(id: 'nat_09', title: 'Cielo estrellado', message: 'Si es de noche, mira las estrellas. La inmensidad del cosmos pone los problemas en perspectiva.', category: 'naturaleza', emoji: '⭐'),
    const WellnessTip(id: 'nat_10', title: 'Lluvia consciente', message: 'Si llueve, sal con paraguas y escucha. Siente las gotas, el olor de la tierra mojada. La lluvia renueva.', category: 'naturaleza', emoji: '🌧️'),
    const WellnessTip(id: 'nat_11', title: 'Paseo por un parque', message: 'Camina por un parque durante 20 minutos sin metas. La naturaleza urbana también cura.', category: 'naturaleza', emoji: '🏞️'),
    const WellnessTip(id: 'nat_12', title: 'Toca la corteza', message: 'Acaricia un árbol y nota su textura. Cada árbol tiene historia, resistencia y vida. Conecta con eso.', category: 'naturaleza', emoji: '🌲'),
    const WellnessTip(id: 'nat_13', title: 'Foto de naturaleza', message: 'Toma una foto de algo natural que te llame la atención: una flor, una sombra, un insecto. Observar es meditar.', category: 'naturaleza', emoji: '📷'),
    const WellnessTip(id: 'nat_14', title: 'Viento en la cara', message: 'Si hay viento, sal y cierra los ojos. Siente el viento en tu cara. Es gratis y es infinitamente sanador.', category: 'naturaleza', emoji: '🌬️'),
    const WellnessTip(id: 'nat_15', title: 'Planta en tu espacio', message: 'Pon una planta en tu escritorio o cuarto. Ver verde reduce el estrés y mejora la calidad del aire.', category: 'naturaleza', emoji: '🪴'),
    const WellnessTip(id: 'nat_16', title: 'Cielo de la mañana', message: 'Al salir, mira al cielo por 30 segundos. El cielo de la mañana es diferente cada día, como un regalo único.', category: 'naturaleza', emoji: '🌤️'),
    const WellnessTip(id: 'nat_17', title: 'Caminata sin rumbo', message: 'Sal a caminar y deja que tus pies decidan. Gira a la izquierda o derecha según tu instinto. Sin mapa.', category: 'naturaleza', emoji: '🧭'),
    const WellnessTip(id: 'nat_18', title: 'Semilla en tu bolsillo', message: 'Pon una semilla en tu bolsillo y tocala cuando estés ansioso. El contacto con algo vivo y natural es grounding.', category: 'naturaleza', emoji: '🌰'),
    const WellnessTip(id: 'nat_19', title: 'Flores frescas', message: 'Compra una flor o un pequeño ramo y ponlo en un vaso. La belleza natural en tu hogar eleva el ánimo.', category: 'naturaleza', emoji: '💐'),
    const WellnessTip(id: 'nat_20', title: 'Despierta con el sol', message: 'Si es posible, abre las cortinas apenas amanezca. La luz natural al despertar regula tu energía del día.', category: 'naturaleza', emoji: '🌅'),
    const WellnessTip(id: 'nat_21', title: 'Tierra en las manos', message: 'Siembra algo o simplemente toca tierra. El contacto con el suelo libera serotonina de forma natural.', category: 'naturaleza', emoji: '🪴'),
    const WellnessTip(id: 'nat_22', title: 'Olor de la tierra', message: 'El olor de la tierra mojada (petricor) activa áreas de calma en el cerebro. Busca ese aroma hoy.', category: 'naturaleza', emoji: '🌿'),
    const WellnessTip(id: 'nat_23', title: 'Camina por la lluvia', message: 'Si la lluvia es suave, sal sin paraguas un momento. Sentir la lluvia en la piel es liberador y refrescante.', category: 'naturaleza', emoji: '☔'),
    const WellnessTip(id: 'nat_24', title: 'Observa un insecto', message: 'Dedica 2 minutos a observar una hormiga, un abejorro o una mariposa. La naturaleza en miniatura es fascinante.', category: 'naturaleza', emoji: '🦋'),

    // ═══════════════════════════════════════════════════════════════════════
    // CREATIVIDAD (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'cre_00', title: 'Dibuja sin reglas', message: 'Toma un papel y dibuja sin pensar en resultado. Garabatos, líneas, formas. El proceso es el punto.', category: 'creatividad', emoji: '✏️'),
    const WellnessTip(id: 'cre_01', title: 'Escribe un microcuento', message: 'Escribe una historia en exactamente 6 palabras. La restricción alimenta la creatividad.', category: 'creatividad', emoji: '📝'),
    const WellnessTip(id: 'cre_02', title: 'Fotografía aleatoria', message: 'Sacale una foto a algo que normalmente ignorarías. La creatividad está en ver lo extraordinario en lo ordinario.', category: 'creatividad', emoji: '📸'),
    const WellnessTip(id: 'cre_03', title: 'Cambia tu ruta', message: 'Ve al trabajo o a la tienda por un camino diferente. Lo nuevo estimula nuevas conexiones neuronales.', category: 'creatividad', emoji: '🔀'),
    const WellnessTip(id: 'cre_04', title: 'Collage rápido', message: 'Recorta imágenes de una revista o imprime fotos y haz un collage. No tiene que ser bonito, solo genuino.', category: 'creatividad', emoji: '✂️'),
    const WellnessTip(id: 'cre_05', title: 'Escribe una carta', message: 'Escribe una carta a tu yo del futuro. ¿Qué le dirías? ¿Qué consejos le darías?', category: 'creatividad', emoji: '✉️'),
    const WellnessTip(id: 'cre_06', title: 'Improvisa una canción', message: 'Canta algo inventado, sobre lo que sea. No tiene que sonar bien. La expresión vocal libera emociones.', category: 'creatividad', emoji: '🎤'),
    const WellnessTip(id: 'cre_07', title: 'Dibuja con la otra mano', message: 'Si eres diestro, dibuja con la izquierda, y viceversa. La imperfección libera la presión del perfeccionismo.', category: 'creatividad', emoji: '✋'),
    const WellnessTip(id: 'cre_08', title: 'Poesía espontánea', message: 'Escribe 4 versos sobre lo que sientes ahora. No tiene que rimar. La poesía es emociones en palabras.', category: 'creatividad', emoji: '🌹'),
    const WellnessTip(id: 'cre_09', title: 'Cocina creativa', message: 'Prepara algo en la cocina usando solo lo que tengas. Sin receta, con intuición. Cocina es arte comestible.', category: 'creatividad', emoji: '👨‍🍳'),
    const WellnessTip(id: 'cre_10', title: 'Arte con sangre seca', message: 'Toma una servilleta y deja caer gotas de tinta, café o jugo. Observa las formas que se crean. El azar es arte.', category: 'creatividad', emoji: '🎨'),
    const WellnessTip(id: 'cre_11', title: 'Lista de 10 usos', message: 'Elige un objeto cotidiano (una caja, un clip) y escribe 10 usos alternativos. Tu cerebro creativo se activa.', category: 'creatividad', emoji: '💡'),
    const WellnessTip(id: 'cre_12', title: 'Inventa un nombre', message: 'Inventa nombres para tiendas, personas ficticias o ciudades imaginarias. La imaginación sin límites es terapéutica.', category: 'creatividad', emoji: '🏷️'),
    const WellnessTip(id: 'cre_13', title: 'Escribe un diario creativo', message: 'Escribe una entrada de diario desde la perspectiva de otra persona o de un objeto. La empatía creativa expande.', category: 'creatividad', emoji: '📔'),
    const WellnessTip(id: 'cre_14', title: 'Música nueva', message: 'Busca un género musical que nunca hayas escuchado. Lo nuevo enciende la curiosidad y alimenta la creatividad.', category: 'creatividad', emoji: '🎵'),
    const WellnessTip(id: 'cre_15', title: 'Construye algo', message: 'Usa material reciclado para construir algo: una caja organizadora, un soporte, un juguete. Crear con las manos sana.', category: 'creatividad', emoji: '🔨'),
    const WellnessTip(id: 'cre_16', title: 'Mapa mental', message: 'Toma un tema que te apasione y dibuja un mapa mental con todas las ideas que se te ocurran. Sin límites.', category: 'creatividad', emoji: '🧠'),
    const WellnessTip(id: 'cre_17', title: 'Color sin libro', message: 'Toma una hoja en blanco y colorea libremente. Sin guía, sin líneas. Solo color y expresión.', category: 'creatividad', emoji: '🖍️'),
    const WellnessTip(id: 'cre_18', title: 'Escribe una lista', message: 'Haz una lista de 10 cosas que te inspiran. Puede ser lugares, personas, colores, canciones. Todo cuenta.', category: 'creatividad', emoji: '📋'),
    const WellnessTip(id: 'cre_19', title: 'Transforma algo viejo', message: 'Toma algo que ya no uses y transformsalo en algo nuevo. La creatividad también es reciclar y reinventar.', category: 'creatividad', emoji: '♻️'),
    const WellnessTip(id: 'cre_20', title: 'Sketch walk', message: 'Sal a caminar y dibuja 3 cosas que veas. No tiene que ser perfecto. Es sobre observar, no sobre dibujar bien.', category: 'creatividad', emoji: '🖼️'),
    const WellnessTip(id: 'cre_21', title: 'Historia colectiva', message: 'Escribe una oración y pide a alguien que escriba la siguiente. Crear juntos genera conexiones únicas.', category: 'creatividad', emoji: '👥'),
    const WellnessTip(id: 'cre_22', title: 'Sigue tu curiosidad', message: 'Busca en internet algo que te dé curiosidad y aprende 3 cosas nuevas. La curiosidad es el motor de la creatividad.', category: 'creatividad', emoji: '🔍'),
    const WellnessTip(id: 'cre_23', title: 'Reorganiza tu espacio', message: 'Cambia el lugar de los muebles o decora con algo diferente. Un espacio nuevo inspira nuevas ideas.', category: 'creatividad', emoji: '🏠'),
    const WellnessTip(id: 'cre_24', title: 'Diario de ideas', message: 'Lleva un cuaderno de bolsillo para anotar ideas al vuelo. Las mejores ideas llegan en los momentos más inesperados.', category: 'creatividad', emoji: '📓'),

    // ═══════════════════════════════════════════════════════════════════════
    // DESCANSO DIGITAL (25 tips)
    // ═══════════════════════════════════════════════════════════════════════
    const WellnessTip(id: 'dig_00', title: '1 hora sin celular', message: 'Deja tu celular en otra habitación por 1 hora. Notarás cuánto espacio mental recuperas sin las notificaciones.', category: 'descanso_digital', emoji: '📵'),
    const WellnessTip(id: 'dig_01', title: 'Modo avión 30 min', message: 'Activa el modo avión por 30 minutos. Sin internet, sin mensajes, sin interrupciones. Solo tú y tu momento.', category: 'descanso_digital', emoji: '✈️'),
    const WellnessTip(id: 'dig_02', title: 'Sin redes sociales', message: 'Hoy no revises redes sociales. Si sientes la urgencia, anota lo que sientes. Es parte del proceso.', category: 'descanso_digital', emoji: '🚫'),
    const WellnessTip(id: 'dig_03', title: 'Notificaciones off', message: 'Desactiva todas las notificaciones excepto las llamadas. Tú decides cuándo revisar, no tu teléfono.', category: 'descanso_digital', emoji: '🔕'),
    const WellnessTip(id: 'dig_04', title: 'Lectura sin pantalla', message: 'Dedica 30 minutos a leer un libro físico o escuchar un audiolibro. Tus ojos y tu mente lo agradecerán.', category: 'descanso_digital', emoji: '📖'),
    const WellnessTip(id: 'dig_05', title: 'Cena sin celular', message: 'Pon el celular en otra habitación durante la cena. Si comes solo, disfruta el silencio. Si comes con alguien, disfruta su compañía.', category: 'descanso_digital', emoji: '🍽️'),
    const WellnessTip(id: 'dig_06', title: 'Mañana digital-free', message: 'Las primeras 2 horas del día, no toques el celular. Empieza con tu energía, no con la de otros.', category: 'descanso_digital', emoji: '🌅'),
    const WellnessTip(id: 'dig_07', title: 'Caminata sin celular', message: 'Sal a caminar sin el celular. Si te preocupa la seguridad, lleva efectivo y dile a alguien a dónde vas.', category: 'descanso_digital', emoji: '🚶'),
    const WellnessTip(id: 'dig_08', title: 'Límite de pantalla', message: 'Revisa cuántas horas pasas en la pantalla. Establece un límite y respétalo. La consciencia es el primer paso.', category: 'descanso_digital', emoji: '📊'),
    const WellnessTip(id: 'dig_09', title: 'Alarma fuera del alcance', message: 'Pone tu alarma lejos de la cama. Así obligas a levantarte y no revisas el celular en la cama.', category: 'descanso_digital', emoji: '⏰'),
    const WellnessTip(id: 'dig_10', title: 'Carta en papel', message: 'Escribe algo que normalmente enviarías por mensaje en un papel. El gesto físico le da más peso y sincerity.', category: 'descanso_digital', emoji: '✉️'),
    const WellnessTip(id: 'dig_11', title: 'Juego sin pantalla', message: 'Juega algo que no requiera pantalla: cartas, rompecabezas, ajedrez, o inventa un juego.', category: 'descanso_digital', emoji: '🎮'),
    const WellnessTip(id: 'dig_12', title: 'Reorganiza apps', message: 'Ordena las apps de tu celular. Pon las más distractoras en una carpeta lejos de la pantalla principal.', category: 'descanso_digital', emoji: '📱'),
    const WellnessTip(id: 'dig_13', title: 'Timer de uso', message: 'Programa un temporizador de 20 minutos para redes sociales. Cuando suene, suéltalo. Sin culpas, solo conciencia.', category: 'descanso_digital', emoji: '⏱️'),
    const WellnessTip(id: 'dig_14', title: 'Dibuja en papel', message: 'Dibuja algo con lápiz y papel, sin aplicaciones. La simplicidad del medio libera la creatividad.', category: 'descanso_digital', emoji: '✏️'),
    const WellnessTip(id: 'dig_15', title: 'Habla por teléfono', message: 'Llama a alguien por teléfono en lugar de escribir por mensaje. La voz humana tiene más calidez que un texto.', category: 'descanso_digital', emoji: '📞'),
    const WellnessTip(id: 'dig_16', title: 'Noche sin series', message: 'Una noche sin Netflix, YouTube ni series. Lee, conversa, medita o simplemente siéntate en silencio.', category: 'descanso_digital', emoji: '🚫'),
    const WellnessTip(id: 'dig_17', title: 'Mapa en papel', message: 'Dibuja un mapa a mano de algún lugar que conozcas. El ejercicio de recordar activa la memoria espacial.', category: 'descanso_digital', emoji: '🗺️'),
    const WellnessTip(id: 'dig_18', title: 'Sin auriculares', message: 'Pasa 2 horas sin auriculares. Escucha el sonido del mundo real. La música es hermosa, pero el silencio también.', category: 'descanso_digital', emoji: '🎧'),
    const WellnessTip(id: 'dig_19', title: 'Foto analógica', message: 'Si tienes una cámara, usa ella en lugar del celular. El proceso de revelar fotos es un acto de paciencia.', category: 'descanso_digital', emoji: '📷'),
    const WellnessTip(id: 'dig_20', title: 'Escribe a mano', message: 'Escribe algo importante a mano en lugar de digitarlo. La escritura manual mejora la memoria y la reflexión.', category: 'descanso_digital', emoji: '✍️'),
    const WellnessTip(id: 'dig_21', title: 'Tienda sin celular', message: 'Ve a comprar algo sin llevar el celular. Si necesitas pagar, lleva efectivo. La experiencia es diferente.', category: 'descanso_digital', emoji: '🏪'),
    const WellnessTip(id: 'dig_22', title: 'Desintoxicación semanal', message: 'Elige un día a la semana para ser consciente de tu uso digital. No tiene que ser total, solo intencional.', category: 'descanso_digital', emoji: '📅'),
    const WellnessTip(id: 'dig_23', title: 'Observa sin grabar', message: 'Si ves algo bonito, no saques el celular para grabarlo. Míralo con tus ojos y guárdalo en tu memoria.', category: 'descanso_digital', emoji: '👁️'),
    const WellnessTip(id: 'dig_24', title: 'Calma digital', message: 'Antes de dormir, deja el celular en otra habitación. Tu descanso merece esa separación. La paz es inalámbrica.', category: 'descanso_digital', emoji: '😴'),
  ];
}

class _ShownEntry {
  const _ShownEntry({required this.tipIndex, required this.date});

  final int tipIndex;
  final DateTime date;
}

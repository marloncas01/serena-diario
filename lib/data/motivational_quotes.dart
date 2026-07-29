class MotivationalQuotes {
  const MotivationalQuotes._();

  static const Map<String, List<String>> byMood = {
    'Feliz': _feliz,
    'En calma': _neutral,
    'Normal': _neutral,
    'Triste': _triste,
    'Cansada': _autocuidado,
  };

  static const Map<String, List<String>> byCategory = {
    'feliz': _feliz,
    'triste': _triste,
    'ansioso': _ansioso,
    'estresado': _estresado,
    'motivado': _motivado,
    'agradecido': _agradecido,
    'neutral': _neutral,
    'crecimiento': _crecimiento,
    'autocuidado': _autocuidado,
    'esperanza': _esperanza,
  };

  static const List<String> all = [
    ..._feliz,
    ..._triste,
    ..._ansioso,
    ..._estresado,
    ..._motivado,
    ..._agradecido,
    ..._neutral,
    ..._crecimiento,
    ..._autocuidado,
    ..._esperanza,
  ];

  static String forMood(String mood) {
    final quotes = byMood[mood] ?? _neutral;
    final index = DateTime.now().day % quotes.length;
    return quotes[index];
  }

  static String forCategory(String category) {
    final quotes = byCategory[category] ?? _neutral;
    final index = DateTime.now().millisecondsSinceEpoch % quotes.length;
    return quotes[index];
  }

  static String dailyQuote() {
    final day = DateTime.now().day;
    final month = DateTime.now().month;
    final index = (day * month) % all.length;
    return all[index];
  }

  // ── Feliz (25) ──
  static const _feliz = [
    '"Hoy también cuenta, incluso en lo pequeño."',
    '"Cada palabra que escribes es un paso hacia ti."',
    '"Permítete celebrar lo que has logrado, por mínimo que parezca."',
    '"La alegría no es un destino, es una forma de caminar."',
    '"Hoy es un buen día para ser amable contigo mismo."',
    '"Tu sonrisa tiene más poder del que imaginas."',
    '"Disfruta este momento. No necesitas más para ser feliz."',
    '"Lo bueno de hoy es que existe. Y tú también."',
    '"A veces la felicidad está en simplemente estar presente."',
    '"Cada día que sonríes es un día que ganas."',
    '"Permítete sentir la calidez de este instante."',
    '"No necesitas una razón para estar bien. Solo permítelo."',
    '"Tu energía positiva impacta más de lo que ves."',
    '"Hoy elegiste estar aquí, y eso ya es suficiente."',
    '"La vida es más ligera cuando te ríes de ti mismo."',
    '"Siéntete orgulloso de hasta dónde has llegado."',
    '"La felicidad se encuentra en los respiros entre las tormentas."',
    '"Cada buen momento es una semilla para el futuro."',
    '"Hoy elige la gratitud sobre la queja."',
    '"Tu bienestar es tu mayor logro."',
    '"Respira profundo. Estás exactamente donde debes estar."',
    '"La vida es corta para no celebrar lo simple."',
    '"Hoy puedes elegir la paz interior."',
    '"Tu presencia en este mundo ya es un regalo."',
    '"Los días buenos no duran para siempre, pero tú sí persistes."',
  ];

  // ── Triste (25) ──
  static const _triste = [
    '"No se trata de ser perfecto, sino de ser honesto."',
    '"Está bien no estar bien. Eso también es parte de vivir."',
    '"Tu tristeza tiene derecho a existir, pero no a definirte."',
    '"Las lágrimas también limpian el alma."',
    '"No tienes que tenerlo todo resuelto hoy."',
    '"Pedir ayuda es un acto de valentía, no de debilidad."',
    '"Lo que sientes hoy no es permanente."',
    '"A veces solo necesitas un abrazo, y eso está bien."',
    '"Tu dolor es válido aunque otros no lo entiendan."',
    '"Las tormentas más fuertes también pasan."',
    '"No estás solo/a, aunque a veces lo parezca."',
    '"Escribir lo que sientes es el primer paso para sanar."',
    '"Está bien descansar cuando el mundo se siente pesado."',
    '"Cada día es una nueva oportunidad para sentirte mejor."',
    '"Tu vulnerabilidad es una forma de fuerza."',
    '"Las palabras que no dices también pesan. Escríbelas aquí."',
    '"La tristeza no es fracaso, es una señal de que te importa."',
    '"No tienes que sonreír para los demás si no lo sientes."',
    '"Confía en que mejores días están por venir."',
    '"Tu historia no termina en este capítulo difícil."',
    '"Sé paciente contigo mismo. Sanar toma tiempo."',
    '"El hecho de que sigas aquí ya es un acto de resistencia."',
    '"Hoy solo necesitas un pequeño paso."',
    '"Siéntete sin juzgarte. Eso ya es autocuidado."',
    '"Tu corazón sabe sanar, déjalo trabajar."',
  ];

  // ── Ansioso (25) ──
  static const _ansioso = [
    '"Respira. Solo necesitas este momento, no todos los que vienen."',
    '"Lo que tu mente imagina como catástrofe rara vez sucede."',
    '"Tu ansiedad no es tu identidad, es una emoción pasajera."',
    '"Pies en el suelo. Respira. Estás a salvo."',
    '"No necesitas controlar todo para estar bien."',
    '"Una cosa a la vez. No todo tiene que resolverse ahora."',
    '"Tu cuerpo te pide calma. Escúchalo."',
    '"Lo peor que puede pasar rara vez es lo que sucede."',
    '"Las preocupaciones son hipótesis, no hechos."',
    '"Puedes sentir ansiedad y seguir adelante."',
    '"El futuro no existe. Solo existe este respiro."',
    '"Anota lo que sientes. Sacarlo de tu mente ayuda."',
    '"No estás en peligro. Tu cuerpo solo está confundido."',
    '"Siéntate con tu ansiedad, no contra ella."',
    '"Lo que resistes, persiste. Deja pasar el pensamiento."',
    '"Cuenta hasta diez. No para resolver, sino para pausar."',
    '"Tu mente es un pensador compulsivo, no un profeta."',
    '"Hoy solo necesitas hacer una cosa. Solo una."',
    '"El caos mental no significa que tu vida sea caótica."',
    '"Date permiso para no tener todas las respuestas."',
    '"Escribe tu preocupación. Al verla, se hace más pequeña."',
    '"El control es una ilusión. La paz viene de soltar."',
    '"No todo lo que piensas es verdad."',
    '"Un paso a la vez es suficiente."',
    '"Tu ansiedad pasará. Siempre lo hace."',
  ];

  // ── Estresado (25) ──
  static const _estresado = [
    '"No puedes vaciar una taza que ya está llena."',
    '"Permítete un momento de silencio en medio del caos."',
    '"Tu cuerpo necesita descanso tanto como tu mente."',
    '"No todo es urgente. Solo se siente así."',
    '"Está bien decir no a algo que no te corresponde."',
    '"El descanso no es un lujo, es una necesidad."',
    '"Respira hondo. Luego otra vez. Y otra."',
    '"No tienes que ser productivo para ser valioso."',
    '"Un momento de pausa puede cambiar todo tu día."',
    '"Estás haciendo más de lo que crees."',
    '"La perfección es el enemigo de la tranquilidad."',
    '"Desacelera. La vida no es una carrera."',
    '"Tu salud mental es más importante que cualquier tarea."',
    '"Escribe lo que te preocupa. Luego suéltalo."',
    '"No tienes que resolverlo todo hoy."',
    '"Está bien pedir un respiro."',
    '"Lo hecho, hecho está. Concéntrate en lo que sigue."',
    '"Cuidar de ti no es egoísmo, es supervivencia."',
    '"El estrés es tu cuerpo pidiendo que te detengas."',
    '"Simplifica. No todo requiere tu atención ahora."',
    '"Date el mismo trato que le darías a un amigo."',
    '"A veces lo mejor que puedes hacer es descansar."',
    '"No todo es tan grave como parece en el momento."',
    '"Tu bienestar es la base de todo lo demás."',
    '"Respira y recuerda: ya has superado días difíciles."',
  ];

  // ── Motivado (25) ──
  static const _motivado = [
    '"Cada entrada es un ladrillo en tu bienestar."',
    '"El simple acto de escribir ya es un avance."',
    '"Hoy escribes, mañana entiendes."',
    '"No hay prisa. Tu historia se escribe a su ritmo."',
    '"Lo que sientes hoy tiene un propósito, aunque no lo veas."',
    '"Pequeños pasos siguen siendo pasos."',
    '"Tu constancia es tu mayor superpoder."',
    '"No necesitas motivación para empezar. Solo empezar."',
    '"Cada día que escribes, te conoces un poco más."',
    '"La disciplina es más confiable que la motivación."',
    '"Empieza donde estás. Usa lo que tienes."',
    '"Tu futuro yo te agradecerá este momento."',
    '"No esperes el momento perfecto. Empieza ahora."',
    '"El progreso no siempre es visible, pero siempre existe."',
    '"Un día a la vez, un paso a la vez."',
    '"La constancia convierte lo imposible en inevitable."',
    '"No compites con nadie. Tu camino es único."',
    '"Cada mañana es una segunda oportunidad."',
    '"Lo difícil de hoy será tu fuerza de mañana."',
    '"Confía en el proceso incluso cuando no lo entiendas."',
    '"Hiciste lo que pudiste. Eso es suficiente."',
    '"Tu esfuerzo importa, aunque no veas resultados inmediatos."',
    '"Sigue adelante. El camino se revela al caminar."',
    '"No dejes para mañana lo que tu corazón necesita hoy."',
    '"Eres más fuerte de lo que crees y más capaz de lo que imaginas."',
  ];

  // ── Agradecido (25) ──
  static const _agradecido = [
    '"Reconocer lo pequeño es celebrar lo grande."',
    '"Tus sentimientos son válidos, todos ellos."',
    '"Permítete sentir, después suelta."',
    '"Tu diario es un espejo de tu crecimiento."',
    '"Agradecer no borra el dolor, pero lo acompañe."',
    '"Hay algo bueno en cada día, aunque sea pequeño."',
    '"La gratitud es recordar lo que otros olvidan."',
    '"Respirar ya es un motivo para agradecer."',
    '"Las cosas más simples suelen ser las más valiosas."',
    '"Hoy tienes más de lo que necesitas para empezar."',
    '"La gratitud transforma lo que tienes en suficiente."',
    '"Agradece por estar vivo/a, por sentir, por intentar."',
    '"Cada persona que te quiere es un tesoro invisible."',
    '"No necesitas más para estar agradecido/a."',
    '"El sol, el aire, tu respiración: todo es regalo."',
    '"Agradecer es el camino más corto hacia la paz."',
    '"Lo que das vuelve, siempre."',
    '"Tu vida tiene más luz de la que notas."',
    '"Agradecer hoy es sembrar felicidad para mañana."',
    '"Las personas en tu vida son tu mayor riqueza."',
    '"Incluso en los malos días, hay algo por lo que agradecer."',
    '"La gratitud es un hábito que se cultiva cada día."',
    '"Respira profundo y agradece por este momento."',
    '"Lo que tienes ahora era lo que alguna vez deseaste."',
    '"Ser agradecido es ser rico de verdad."',
  ];

  // ── Neutral (25) ──
  static const _neutral = [
    '"Tu diario es un espejo de tu crecimiento."',
    '"A veces, escribir es la mejor forma de respirar."',
    '"No necesitas tenerlo todo claro. Solo empezar."',
    '"Permítete ser, sin juicios."',
    '"Cada palabra es un paso hacia tu interior."',
    '"Escribir es escucharte a ti mismo."',
    '"No hay respuestas incorrectas cuando escribes para ti."',
    '"Este espacio es solo tuyo. Úsalo como necesites."',
    '"El día de hoy tiene algo que enseñarte."',
    '"Un diario no juzga, solo escucha."',
    '"Lo que escribas aquí queda entre tú y tú."',
    '"A veces lo más valiente es ser honesto contigo."',
    '"Tu historia merece ser contada, aunque sea para ti."',
    '"Escribir es ordenar el caos interior."',
    '"No necesitas inspiración para empezar, solo intención."',
    '"Cada entrada es una fotografía de quien eres hoy."',
    '"El diario no necesita perfección, solo verdad."',
    '"Tu voz interna merece ser escuchada."',
    '"Registra lo que sientes. El resto vendrá después."',
    '"No todo se resuelve escribiendo, pero todo se entiende mejor."',
    '"Hoy es un buen día para empezar."',
    '"Escribir es una forma de cuidarte."',
    '"Este momento de escritura es un regalo para ti."',
    '"No hay formato correcto para expresarte."',
    '"Tu diario crece contigo."',
  ];

  // ── Crecimiento (25) ──
  static const _crecimiento = [
    '"Escribir es escucharte a ti mismo."',
    '"Cada entrada es un paso más hacia tu mejor versión."',
    '"El crecimiento no es lineal, pero siempre avanza."',
    '"Aprender de ti es el mayor conocimiento."',
    '"Tu evolución es silenciosa pero poderosa."',
    '"Los errores son lecciones disfrazadas."',
    '"Hoy no eres quien eras ayer. Eso es crecer."',
    '"Cada reflexión te acerca más a tu esencia."',
    '"Crecer es soltar lo que ya no te sirve."',
    '"Tu mayor competidor de ayer eres tú mismo."',
    '"Las cicatrices son prueba de que fuiste más fuerte que lo que te lastimó."',
    '"No mires atrás con arrepentimiento, mira con gratitud."',
    '"Cada día tienes la oportunidad de ser mejor."',
    '"El crecimiento personal empieza con la honestidad."',
    '"Lo que hoje no te destruye, te transforma."',
    '"Permítete ser principiante en algo nuevo."',
    '"Tu capacidad de aprendizaje no tiene límites."',
    '"Equivocarte es la mejor forma de aprender."',
    '"La madurez es aceptar lo que no puedes controlar."',
    '"Tu historia de vida es tu mayor maestro."',
    '"Crecer duele, pero quedarse estancado duele más."',
    '"Los desafíos son oportunidades con disfraz."',
    '"Cada obstáculo revela una fortaleza que no sabías que tenías."',
    '"No necesitas ser perfecto para avanzar."',
    '"Tu camino es único, no lo compares con el de otros."',
  ];

  // ── Autocuidado (25) ──
  static const _autocuidado = [
    '"Cuidarte no es un lujo, es una necesidad."',
    '"Tu cuerpo y mente merecen atención constante."',
    '"Decir no también es una forma de amor propio."',
    '"El descanso es productivo, no una pérdida de tiempo."',
    '"Hidrátate, respira, muévete. Son los pilares básicos."',
    '"Tu salud mental merece la misma atención que tu salud física."',
    '"No puedes dar lo que no tienes. Cuidate primero."',
    '"Un día sin hacer nada también es un día válido."',
    '"Escucha a tu cuerpo. Él sabe lo que necesita."',
    '"Permitirte descansar es un acto de fuerza."',
    '"La mejor inversión es en ti mismo/a."',
    '"No te exijas lo que no le exigirías a alguien que amas."',
    '"Tu bienestar no es negociable."',
    '"Cuidarte empieza con pensarte en ti mismo/a."',
    '"El autocuidado no es vanidad, es supervivencia."',
    '"Permítete sentir sin necesidad de arreglar nada."',
    '"Cada pequeño acto de cuidado cuenta."',
    '"Mereces el mismo amor que das a los demás."',
    '"Tu cuerpo es tu hogar, cuídalo como tal."',
    '"Dormir bien, comer bien, pensar bien: todo conecta."',
    '"No todo es productividad. A veces solo respira."',
    '"Estar bien no es egoísmo."',
    '"Siéntate en silencio un momento. Tu mente lo agradecerá."',
    '"Cuidar tu mente es tan importante como cuidar tu cuerpo."',
    '"Permítete tener días de solo existir."',
  ];

  // ── Esperanza (25) ──
  static const _esperanza = [
    '"Lo que sientes hoy tiene un propósito, aunque no lo veas."',
    '"Después de la noche más larga, siempre viene el amanecer."',
    '"Tu historia tiene capítulos hermosos que aún no has leído."',
    '"Las mejores cosas de tu vida están por venir."',
    '"Mientras respites, hay esperanza."',
    '"Cada día nuevo es una página en blanco."',
    '"Lo mejor de ti aún no se ha mostrado."',
    '"La vida siempre encuentra una manera."',
    '"Hoy puede ser el día en que todo cambie."',
    '"Confía en que el universo tiene un plan para ti."',
    '"Las tormentas no duran para siempre, pero las personas fuertes sí."',
    '"Tu futuro puede ser más brillante que tu pasado."',
    '"Cierre los ojos y visualiza la vida que deseas."',
    '"Los sueños que no se rinden siempre encuentran un camino."',
    '"Mereces una vida que te haga sonreír."',
    '"No dejes que el miedo te robe la esperanza."',
    '"La esperanza es la última que se pierde."',
    '"Cada semilla plantada hoy es un árbol mañana."',
    '"Incluso cuando no lo veas, algo bueno se está gestando."',
    '"Tu perseverancia tiene un propósito mayor."',
    '"No estás atrapado/a, estás en transición."',
    '"El dolor de hoy es la fortaleza de mañana."',
    '"Nunca es tarde para empezar algo nuevo."',
    '"Mereces segundas oportunidades, y terceras, y cuartas."',
    '"La esperanza no es ignorar la realidad, es creer en algo mejor."',
  ];
}

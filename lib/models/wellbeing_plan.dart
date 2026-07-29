enum DificultadObjetivo { facil, media, dificil }

enum DuracionObjetivo { unDia, unaSemana, dosSemanas, unMes }

enum EstadoObjetivo { pendiente, enProgreso, completado, abandonado }

enum CategoriaLogro {
  consistencia,
  progreso,
  emocional,
  social,
  autoconocimiento,
}

enum PrioridadRecomendacion { baja, media, alta }

class WellbeingObjective {
  WellbeingObjective({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.motivo,
    required this.dificultad,
    required this.duracion,
    required this.estado,
    required this.fechaInicio,
    this.fechaFin,
    this.progreso = 0.0,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final String motivo;
  final DificultadObjetivo dificultad;
  final DuracionObjetivo duracion;
  EstadoObjetivo estado;
  final DateTime fechaInicio;
  DateTime? fechaFin;
  double progreso;

  double get progresoClamp => progreso.clamp(0.0, 1.0);

  Duration get duracionEstimada => switch (duracion) {
    DuracionObjetivo.unDia => const Duration(days: 1),
    DuracionObjetivo.unaSemana => const Duration(days: 7),
    DuracionObjetivo.dosSemanas => const Duration(days: 14),
    DuracionObjetivo.unMes => const Duration(days: 30),
  };

  bool get estaVencido {
    if (fechaFin != null) return DateTime.now().isAfter(fechaFin!);
    final fin = fechaInicio.add(duracionEstimada);
    return DateTime.now().isAfter(fin);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'motivo': motivo,
    'dificultad': dificultad.name,
    'duracion': duracion.name,
    'estado': estado.name,
    'fechaInicio': fechaInicio.toIso8601String(),
    'fechaFin': fechaFin?.toIso8601String(),
    'progreso': progreso,
  };

  factory WellbeingObjective.fromMap(Map<String, dynamic> map) =>
      WellbeingObjective(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        descripcion: map['descripcion'] as String,
        motivo: map['motivo'] as String,
        dificultad: DificultadObjetivo.values.firstWhere(
          (e) => e.name == map['dificultad'],
        ),
        duracion: DuracionObjetivo.values.firstWhere(
          (e) => e.name == map['duracion'],
        ),
        estado: EstadoObjetivo.values.firstWhere(
          (e) => e.name == map['estado'],
        ),
        fechaInicio: DateTime.parse(map['fechaInicio'] as String),
        fechaFin: map['fechaFin'] != null
            ? DateTime.parse(map['fechaFin'] as String)
            : null,
        progreso: (map['progreso'] as num?)?.toDouble() ?? 0.0,
      );
}

class WellbeingAchievement {
  const WellbeingAchievement({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.categoria,
    this.fechaDesbloqueado,
    this.desbloqueado = false,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final String icono;
  final CategoriaLogro categoria;
  final DateTime? fechaDesbloqueado;
  final bool desbloqueado;

  WellbeingAchievement desbloquear() => WellbeingAchievement(
    id: id,
    titulo: titulo,
    descripcion: descripcion,
    icono: icono,
    categoria: categoria,
    fechaDesbloqueado: DateTime.now(),
    desbloqueado: true,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'icono': icono,
    'categoria': categoria.name,
    'fechaDesbloqueado': fechaDesbloqueado?.toIso8601String(),
    'desbloqueado': desbloqueado,
  };

  factory WellbeingAchievement.fromMap(Map<String, dynamic> map) =>
      WellbeingAchievement(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        descripcion: map['descripcion'] as String,
        icono: map['icono'] as String,
        categoria: CategoriaLogro.values.firstWhere(
          (e) => e.name == map['categoria'],
        ),
        fechaDesbloqueado: map['fechaDesbloqueado'] != null
            ? DateTime.parse(map['fechaDesbloqueado'] as String)
            : null,
        desbloqueado: map['desbloqueado'] as bool? ?? false,
      );
}

class WellbeingRecommendation {
  const WellbeingRecommendation({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fuente,
    required this.prioridad,
    required this.fechaGenerada,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final String fuente;
  final PrioridadRecomendacion prioridad;
  final DateTime fechaGenerada;
}

class EmotionPatternReport {
  const EmotionPatternReport({
    required this.emocionesFrecuentes,
    required this.emocionDominante,
    required this.intensidadPromedio,
    required this.cambiosDetectados,
    required this.tendencia,
    required this.resumen,
  });

  final List<String> emocionesFrecuentes;
  final String emocionDominante;
  final double intensidadPromedio;
  final List<String> cambiosDetectados;
  final double tendencia;
  final String resumen;
}

class WritingReport {
  const WritingReport({
    required this.totalEntradas,
    required this.diasConEscritura,
    required this.rachaActual,
    required this.rachaMaxima,
    required this.frecuenciaSemanal,
    required this.promedioPalabras,
    this.ultimaEscritura,
  });

  final int totalEntradas;
  final int diasConEscritura;
  final int rachaActual;
  final int rachaMaxima;
  final double frecuenciaSemanal;
  final double promedioPalabras;
  final DateTime? ultimaEscritura;
}

class EmotionalEvolution {
  const EmotionalEvolution({
    required this.tendencia,
    required this.descripcion,
    required this.emocionesInicio,
    required this.emocionesFin,
    required this.hayMejora,
    required this.hayRecaida,
  });

  final double tendencia;
  final String descripcion;
  final Map<String, int> emocionesInicio;
  final Map<String, int> emocionesFin;
  final bool hayMejora;
  final bool hayRecaida;
}

class WellbeingSnapshot {
  const WellbeingSnapshot({
    required this.patrones,
    required this.escritura,
    required this.evolucion,
    required this.objetivosActivos,
    required this.logrosDesbloqueados,
    required this.recomendaciones,
    required this.fechaGeneracion,
  });

  final EmotionPatternReport patrones;
  final WritingReport escritura;
  final EmotionalEvolution evolucion;
  final List<WellbeingObjective> objetivosActivos;
  final List<WellbeingAchievement> logrosDesbloqueados;
  final List<WellbeingRecommendation> recomendaciones;
  final DateTime fechaGeneracion;
}

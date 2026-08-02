# CHANGELOG — FASE 19 · Pulido final (Serena v1.0 Beta)

Revisión UX, corrección de bugs, optimización de rendimiento y limpieza de
proyecto antes del lanzamiento Beta. Sin cambios de arquitectura, sin cambios
en Hive, Firebase Auth ni el motor emocional.

## UX y modo oscuro
- Barra de estado sigue el brillo del sistema y el tema activo (`main.dart`).
- Gradientes de Splash y Onboarding adaptados al modo oscuro.
- Tarjeta de perfil en Ajustes con colores correctos en tema oscuro.
- Protección contra doble toque en Onboarding y Setup (`_isFinishing`).
- Validación de nombre vacío al editar perfil (feedback con `AppFeedback`).
- Contraste de etiquetas de ChoiceChip por luminancia (Diario y acciones de entrada).
- Botón "Guardar" deshabilitado cuando la entrada está vacía.
- Calendario: botón "Ir a hoy", aviso en meses sin entradas, CTA "Escribir
  reflexión" en días vacíos, y previsualizaciones de día tappables.
- Historial: etiquetas de filtro con año, chips de filtro se deseleccionan al
  re-tocar, y corrección de la sintaxis de los modales de filtro.
- Detalle de entrada: análisis computado una sola vez (no en cada rebuild) y
  estado "Esta entrada ya no existe" cuando la entrada fue borrada.

## Bugs corregidos
- Porcentaje de emoción y confianza ya son 0–100; se eliminaron multiplicaciones
  erróneas por 100 (prompt builder y tarjeta de respuesta).
- La emoción dominante detectada ahora se persiste al editar una entrada.
- La tendencia emocional se calcula por `id` de emoción (antes por nombre), así
  el widget muestra el emoji y color correctos.
- Resumen semanal/mensual e insights: emparejamiento correcto entre entradas
  (más recientes primero) e historial (más antiguo primero).
- Etiquetas de días de la semana en las gráficas de estadísticas ahora reflejan
  las fechas reales.
- Hora/día más frecuente de escritura se calculan por frecuencia real, no por
  primer valor visto.
- Porcentajes positivos/negativos del perfil emocional incluyen las categorías
  mixtas en el denominador.
- Frecuencia de escritura y desbordamiento de mes en el resumen del mes anterior.
- La tarjeta de evolución ya no muestra "Tendencia estable" con datos insuficientes.
- El consejo diario se refresca al cambiar el día sin reiniciar la app.
- Cierre de sesión ya no se bloquea si el sign-out de Google falla.
- Gemini: timeout de 20s en todas las llamadas para evitar "Serena está pensando..."
  indefinido (el modelo se respeta; sin cambios en su lógica).
- Doble toque en botones de acción del dashboard ya no abre varias acciones.

## Rendimiento
- `JournalProvider.entries` reutiliza una vista inmutable cacheada (evita
  reconstrucciones completas en cada notificación).
- Cachés del dashboard se invalidan con un contador de revisión: editar una
  entrada ya refresca perfil, insights y resúmenes.
- El análisis emocional del detalle de entrada se calcula una vez por entrada.

## Persistencia
- Al reiniciar la app, el historial emocional se reconstruye desde las emociones
  dominantes guardadas en las entradas: el dashboard ya no queda vacío.

## Limpieza
- Eliminado código muerto en `UserProfile` (`diaryName`, `isComplete`) y avatar
  duplicado en categorías.
- Análisis estático limpio: `flutter analyze` sin errores ni warnings.

## Verificación final
- `flutter clean` + `flutter pub get` + `flutter analyze` + `flutter test` sin errores.

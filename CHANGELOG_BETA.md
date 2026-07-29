# CHANGELOG — Serena Beta

## Beta v1.0.0 (Julio 2026)

### Emoción automática
- La emoción ahora se detecta automáticamente con IA después de cada entrada.
- Ya no es obligatorio seleccionar el mood antes de escribir.
- Banner "Serena detectó" muestra la emoción detectada con confianza.
- Botón "Cambiar emoción" para override manual si lo deseas.

### Perfil editable
- Ahora puedes editar tu nombre, avatar y personalidad de Serena desde Ajustes.
- Toca el avatar en la tarjeta de perfil para elegir entre 32 avatares organizados por categorías: Minimalista, Naturaleza, Animales, Fantasía, Comida y Corazón.
- Sección "Personalidad de Serena" con 5 opciones: Amigable, Profesional, Motivadora, Tranquila, Reflexiva.

### Placeholder dinámico
- El campo de escritura ahora muestra sugerencias contextuales según la hora del día y tu progreso al escribir.

### Corrección de Spotify
- Playlists corregidas para coincidir con las emociones de la app: Feliz, En calma, Normal, Triste, Cansada.
- Ahora abre playlists reales de Spotify en lugar de resultados de búsqueda genéricos.

### Eliminación de overflows
- Se corrigieron todos los RenderFlex overflow reportados en pantallas y widgets.

### Tema dinámico completo
- Todos los colores hardcoded eliminados de widgets UI.
- Todos los widgets ahora usan `Theme.of(context).colorScheme` en lugar de colores fijos.
- Las 5 paletas de color (morado, azul, verde, rosa, naranja) funcionan correctamente en toda la app.

### Estabilidad
- Análisis estático limpio: 0 errores, 0 warnings.
- Botones revisados: todos tienen función asignada.

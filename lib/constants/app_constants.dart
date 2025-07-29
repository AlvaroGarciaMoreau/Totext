class AppConstants {
  // Configuración de la aplicación
  static const String appTitle = 'ToText - OCR y Voz a Texto';
  static const int maxHistoryEntries = 50;
  
  // Duraciones
  static const Duration speechListenDuration = Duration(seconds: 30);
  static const Duration speechPauseDuration = Duration(seconds: 5);
  
  // Calidad de imagen
  static const int imageQuality = 80;
  
  // Mensajes de error
  static const String errorTakePhoto = 'Error al tomar la foto';
  static const String errorSelectImage = 'Error al seleccionar la imagen';
  static const String errorProcessImage = 'Error al procesar la imagen';
  static const String errorSpeechNotInitialized = 'El reconocimiento de voz no está inicializado.';
  static const String errorMicrophonePermission = 'El permiso para usar el micrófono es necesario.';
  static const String errorAudioDeviceNotAvailable = 'Dispositivo de audio no disponible.';
  static const String errorSpeechNotAvailable = 'Reconocimiento de voz no disponible';
  static const String errorNoTextToShare = 'No hay texto para compartir';
  
  // Mensajes de estado
  static const String statusListening = 'Escuchando...';
  static const String statusProcessing = 'Procesando...';
  static const String statusNoTextFound = 'No se encontró texto en la imagen';
  static const String statusNoAudioDetected = 'No se detectó ningún audio';
  
  // Etiquetas de UI
  static const String homeTitle = 'ToText - OCR y Voz';
  static const String historyTitle = 'Historial';
  static const String historyEmptyMessage = 'No hay textos guardados aún';
  static const String textAreaPlaceholder = 'El texto extraído aparecerá aquí...\n\n• Toca el botón de cámara para tomar una foto y extraer texto\n• Selecciona de galería para procesar imágenes existentes\n• Usa el micrófono para convertir tu voz en texto\n• Una vez que tengas texto, podrás editarlo y compartirlo\n• Ve al historial para revisar textos anteriores';
  static const String editHint = 'Edita tu texto aquí...';
  static const String tapToEdit = '\n\n(Toca para editar)';
  static const String shareSubject = 'Texto extraído con ToText';
  
  // Tooltips
  static const String tooltipEdit = 'Editar texto';
  static const String tooltipSave = 'Guardar';
  static const String tooltipCancel = 'Cancelar';
  static const String tooltipClear = 'Limpiar texto';
  static const String tooltipHome = 'Inicio';
  static const String tooltipCamera = 'Cámara';
  static const String tooltipHistory = 'Historial';
  static const String tooltipStopRecording = 'Detener grabación';
  static const String tooltipStartRecording = 'Grabar voz';
  static const String tooltipVoiceNotAvailable = 'Voz no disponible';
  
  // Opciones de menú
  static const String menuTakePhoto = 'Tomar foto';
  static const String menuSelectGallery = 'Seleccionar de galería';
  static const String menuUseText = 'Usar este texto';
  static const String menuShare = 'Compartir';
  static const String menuDelete = 'Eliminar';
  
  // Botones
  static const String buttonShareText = 'Compartir Texto';
  
  // Fuentes de texto
  static const String sourceCamera = 'camera';
  static const String sourceMicrophone = 'microphone';
  static const String sourceEdited = 'edited';
  
  // Etiquetas de fuente
  static const String sourceCameraLabel = 'Cámara';
  static const String sourceMicrophoneLabel = 'Micrófono';
  static const String sourceEditedLabel = 'Editado';
}

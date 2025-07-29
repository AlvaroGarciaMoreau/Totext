# 📱 ToText - OCR y Voz a Texto

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**ToText** es una aplicación móvil desarrollada en Flutter que permite extraer texto de imágenes mediante OCR (Reconocimiento Óptico de Caracteres) y convertir voz a texto. Los textos extraídos se pueden compartir fácilmente a través de WhatsApp, correo electrónico u otras aplicaciones.

> 🚀 **Nueva Versión 2.0**: Arquitectura completamente refactorizada con servicios especializados, widgets modulares y mejor organización del código para mayor mantenibilidad y escalabilidad.

## ✨ Características Principales

### 📸 **Extracción de Texto por OCR**
- **Captura directa**: Toma fotos con la cámara del dispositivo
- **Galería**: Selecciona imágenes existentes de tu galería
- **Reconocimiento avanzado**: Utiliza Google ML Kit para OCR preciso
- **Múltiples idiomas**: Soporte para texto en español y otros idiomas latinos

### 🎤 **Conversión de Voz a Texto**
- **Reconocimiento en tiempo real**: Convierte tu voz a texto instantáneamente
- **Soporte en español**: Optimizado para reconocimiento de voz en español
- **Indicadores visuales**: Interfaz intuitiva con estados de escucha

### 💾 **Almacenamiento Persistente**
- **Historial completo**: Guarda automáticamente todos los textos extraídos
- **Persistencia local**: Los datos se mantienen incluso después de cerrar la app
- **Gestión inteligente**: Mantiene las 50 entradas más recientes
- **Recuperación de sesión**: Restaura el último texto al abrir la aplicación

### 📤 **Compartir Fácilmente**
- **Integración nativa**: Comparte texto a través del sistema de compartir de Android/iOS
- **Compatible con**: WhatsApp, Telegram, Email, SMS, Google Drive, y más
- **Compartir desde historial**: Opción para compartir textos guardados anteriormente

### 🎨 **Interfaz Intuitiva**
- **Diseño Material 3**: Interfaz moderna y elegante
- **Navegación por pestañas**: Acceso rápido a Inicio e Historial
- **Indicadores de estado**: Feedback visual para todas las operaciones
- **Menús contextuales**: Opciones rápidas para gestionar el historial
- **Arquitectura Modular**: Widgets reutilizables y mantenibles
- **Gestión de Errores**: Mensajes informativos y manejo robusto de excepciones

## 📱 Capturas de Pantalla

| Pantalla Principal | Historial | Opciones de Cámara |
|:------------------:|:---------:|:------------------:|
| *Próximamente*     | *Próximamente* | *Próximamente* |

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK (versión 3.8.0 o superior)
- Android Studio / Xcode
- Un dispositivo Android (API 21+) o iOS (12.0+)

### Pasos de Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/AlvaroGarciaMoreau/Totext.git
   cd Totext
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura los dispositivos**
   ```bash
   flutter devices
   ```

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 🛠️ Configuración de Desarrollo

### Android
La aplicación requiere **Android SDK 36** o superior. Asegúrate de tener configurado:

```gradle
android {
    compileSdk = 36
    targetSdk = 36
    minSdk = 21
    ndkVersion = "27.0.12077973"
}
```

### Permisos Requeridos

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Esta aplicación necesita acceso a la cámara para tomar fotos y extraer texto.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Esta aplicación necesita acceso al micrófono para convertir voz a texto.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta aplicación necesita acceso a la galería para seleccionar imágenes.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Esta aplicación necesita acceso al reconocimiento de voz para convertir audio a texto.</string>
```

## 📦 Dependencias Principales

| Dependencia | Versión | Propósito |
|-------------|---------|-----------|
| `camera` | ^0.10.5+9 | Acceso a la cámara del dispositivo |
| `image_picker` | ^1.0.7 | Selección de imágenes de galería |
| `google_mlkit_text_recognition` | ^0.13.0 | OCR - Reconocimiento de texto |
| `speech_to_text` | ^7.0.0 | Conversión de voz a texto |
| `permission_handler` | ^11.3.0 | Gestión de permisos |
| `share_plus` | ^7.2.2 | Funcionalidad de compartir |
| `shared_preferences` | ^2.2.2 | Almacenamiento local persistente |

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada y HomePage
├── constants/
│   └── app_constants.dart            # Constantes centralizadas de la aplicación
├── models/
│   └── text_entry.dart               # Modelo de datos para entradas de texto
├── services/
│   ├── storage_service.dart          # Servicio de almacenamiento persistente
│   ├── ocr_service.dart              # Servicio de reconocimiento de texto (OCR)
│   ├── speech_service.dart           # Servicio de reconocimiento de voz
│   └── image_service.dart            # Servicio de captura y selección de imágenes
├── utils/
│   ├── permission_utils.dart         # Utilidades para gestión de permisos
│   └── date_utils.dart               # Utilidades para formateo de fechas
└── widgets/
    ├── text_display_widget.dart      # Widget para mostrar/editar texto
    ├── history_list_widget.dart      # Widget para lista del historial
    ├── custom_bottom_app_bar.dart    # Barra de navegación inferior personalizada
    └── camera_options_sheet.dart     # Modal de opciones de cámara
```

### Patrones Utilizados
- **Clean Architecture**: Separación clara entre capas de presentación, dominio y datos
- **Service Layer Pattern**: Encapsulación de lógica de negocio en servicios especializados
- **Widget Composition**: Componentes UI modulares y reutilizables
- **Constants Centralization**: Gestión centralizada de constantes y configuraciones
- **Utilities Pattern**: Funciones auxiliares organizadas por responsabilidad

## 📋 Cómo Usar la Aplicación

### 1. **Extraer Texto de Imágenes**
- Toca el botón de **cámara** en la parte inferior
- Selecciona **"Tomar foto"** o **"Seleccionar de galería"**
- El texto se extraerá automáticamente y aparecerá en pantalla

### 2. **Convertir Voz a Texto**
- Toca el botón de **micrófono**
- Habla claramente (el botón se volverá rojo mientras escucha)
- Toca nuevamente para detener la grabación

### 3. **Gestionar el Historial**
- Ve a la pestaña **"Historial"** para ver todos los textos guardados
- Toca cualquier entrada para usarla como texto actual
- Usa el menú de tres puntos para compartir o eliminar entradas

### 4. **Compartir Texto**
- Una vez que tengas texto extraído, aparecerá el botón **"Compartir Texto"**
- Selecciona la aplicación donde quieres compartir el texto

### 5. **Editar Texto**
- Toca cualquier texto extraído para editarlo
- Usa los botones de **guardar** (✓) o **cancelar** (✗) para confirmar cambios

## 🧪 Desarrollo y Testing

### Estructura de Testing
```bash
# Ejecutar todos los tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format lib/ test/

# Verificar dependencias
flutter pub deps
```

### Variables de Entorno
```bash
# Para desarrollo
export FLUTTER_ENV=development

# Para producción
export FLUTTER_ENV=production
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Si quieres contribuir al proyecto:

1. **Fork** el repositorio
2. Crea una **rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. Abre un **Pull Request**

### Áreas de Mejora
- [ ] Soporte para más idiomas en OCR
- [ ] Modo oscuro/claro con persistencia de preferencias
- [ ] Exportar historial a archivos (JSON, TXT, PDF)
- [ ] Reconocimiento de texto manuscrito
- [ ] Traducción automática de textos
- [ ] Búsqueda y filtrado en el historial
- [ ] Categorización y etiquetado de textos
- [ ] Sincronización en la nube
- [ ] Procesamiento por lotes de múltiples imágenes
- [ ] Comandos de voz para navegación
- [ ] Compresión inteligente de datos
- [ ] Soporte offline completo
- [ ] Testing automatizado (Unit tests, Widget tests)
- [ ] Mejoras de accesibilidad
- [ ] Animaciones y transiciones suaves

## 🔧 Mejoras Recientes (v2.0)

### ✅ **Refactorización Completa**
- **Arquitectura Limpia**: Separación en capas bien definidas
- **Servicios Especializados**: Cada funcionalidad en su propio servicio
- **Widgets Modulares**: Componentes UI reutilizables y mantenibles
- **Constantes Centralizadas**: Gestión única de textos y configuraciones

### ✅ **Mejoras de Código**
- **Mejor Mantenibilidad**: Código más organizado y fácil de mantener
- **Mayor Testabilidad**: Servicios independientes fáciles de testear
- **Escalabilidad Mejorada**: Estructura preparada para nuevas funcionalidades
- **Gestión de Errores**: Manejo más robusto de excepciones
- **Performance Optimizada**: Mejor gestión de recursos y memoria

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Álvaro García Moreau**
- GitHub: [@AlvaroGarciaMoreau](https://github.com/AlvaroGarciaMoreau)

## 🙏 Agradecimientos

- **Google ML Kit** por proporcionar las herramientas de OCR
- **Flutter Team** por el excelente framework
- **Comunidad de Flutter** por los recursos y documentación
- **Contribuidores** que han ayudado a mejorar el proyecto

## 🔄 Historial de Versiones

### v2.0.0 (Enero 2025)
- ✅ Refactorización completa de la arquitectura
- ✅ Separación en servicios especializados
- ✅ Widgets modulares y reutilizables
- ✅ Constantes centralizadas
- ✅ Mejora en gestión de errores
- ✅ Optimización de performance

### v1.0.0 (Versión Inicial)
- ✅ Extracción de texto por OCR
- ✅ Conversión de voz a texto
- ✅ Historial persistente
- ✅ Funcionalidad de compartir
- ✅ Interfaz Material Design

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias:

1. Revisa los [Issues existentes](https://github.com/AlvaroGarciaMoreau/Totext/issues)
2. Crea un [Nuevo Issue](https://github.com/AlvaroGarciaMoreau/Totext/issues/new) si es necesario
3. Proporciona la mayor información posible sobre el problema
4. Incluye capturas de pantalla si es posible
5. Especifica la versión de Flutter y dispositivo utilizado

### 🐛 Reportar Bugs
Cuando reportes un bug, incluye:
- Descripción detallada del problema
- Pasos para reproducir el error
- Comportamiento esperado vs. actual
- Logs de error si están disponibles
- Información del dispositivo y versión de la app

### 💡 Solicitar Funcionalidades
Para solicitar nuevas funcionalidades:
- Describe claramente la funcionalidad deseada
- Explica el caso de uso y beneficios
- Proporciona mockups o ejemplos si es posible

---

⭐ **¡Dale una estrella al proyecto si te resulta útil!** ⭐

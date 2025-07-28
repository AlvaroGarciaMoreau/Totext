# 📱 ToText - OCR y Voz a Texto

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**ToText** es una aplicación móvil desarrollada en Flutter que permite extraer texto de imágenes mediante OCR (Reconocimiento Óptico de Caracteres) y convertir voz a texto. Los textos extraídos se pueden compartir fácilmente a través de WhatsApp, correo electrónico u otras aplicaciones.

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
| `speech_to_text` | ^6.6.0 | Conversión de voz a texto |
| `permission_handler` | ^11.3.0 | Gestión de permisos |
| `share_plus` | ^7.2.2 | Funcionalidad de compartir |
| `shared_preferences` | ^2.2.2 | Almacenamiento local persistente |

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── text_entry.dart      # Modelo de datos para entradas de texto
└── services/
    └── storage_service.dart  # Servicio de almacenamiento persistente
```

### Patrones Utilizados
- **Model-View Pattern**: Separación clara entre datos y presentación
- **Service Pattern**: Encapsulación de lógica de almacenamiento
- **Singleton Pattern**: Gestión de estado global para el almacenamiento

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

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Si quieres contribuir al proyecto:

1. **Fork** el repositorio
2. Crea una **rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. Abre un **Pull Request**

### Áreas de Mejora
- [ ] Soporte para más idiomas en OCR
- [ ] Modo oscuro
- [ ] Exportar historial a archivos
- [ ] Reconocimiento de texto manuscrito
- [ ] Traducción automática de textos
- [ ] Búsqueda en el historial

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Álvaro García Moreau**
- GitHub: [@AlvaroGarciaMoreau](https://github.com/AlvaroGarciaMoreau)

## 🙏 Agradecimientos

- **Google ML Kit** por proporcionar las herramientas de OCR
- **Flutter Team** por el excelente framework
- **Comunidad de Flutter** por los recursos y documentación

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias:

1. Revisa los [Issues existentes](https://github.com/AlvaroGarciaMoreau/Totext/issues)
2. Crea un [Nuevo Issue](https://github.com/AlvaroGarciaMoreau/Totext/issues/new) si es necesario
3. Proporciona la mayor información posible sobre el problema

---

⭐ **¡Dale una estrella al proyecto si te resulta útil!** ⭐

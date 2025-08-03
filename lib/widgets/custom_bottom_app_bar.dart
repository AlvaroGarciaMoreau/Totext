import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final bool isLoading;
  final bool speechEnabled;
  final bool isListening;
  final Function(int) onIndexChanged;
  final VoidCallback onCameraPressed;
  final VoidCallback onMicrophonePressed;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.isLoading,
    required this.speechEnabled,
    required this.isListening,
    required this.onIndexChanged,
    required this.onCameraPressed,
    required this.onMicrophonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Botón de navegación a Inicio
          Expanded(
            child: IconButton(
              onPressed: () => onIndexChanged(0),
              icon: Icon(
                Icons.home,
                size: 32,
                color: selectedIndex == 0 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: AppConstants.tooltipHome,
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de cámara
          Expanded(
            child: IconButton(
              onPressed: isLoading ? null : onCameraPressed,
              icon: const Icon(
                Icons.camera_alt,
                size: 32,
              ),
              tooltip: AppConstants.tooltipCamera,
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de micrófono
          Expanded(
            child: IconButton(
              onPressed: speechEnabled 
                  ? onMicrophonePressed
                  : null,
              icon: Icon(
                isListening ? Icons.mic : (speechEnabled ? Icons.mic : Icons.mic_off),
                size: 32,
                color: isListening 
                    ? Colors.red 
                    : (speechEnabled 
                        ? Theme.of(context).colorScheme.onSurface 
                        : Colors.grey.shade400),
              ),
              tooltip: isListening 
                  ? AppConstants.tooltipStopRecording
                  : (speechEnabled ? AppConstants.tooltipStartRecording : AppConstants.tooltipVoiceNotAvailable),
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de navegación a Búsqueda
          Expanded(
            child: IconButton(
              onPressed: () => onIndexChanged(2),
              icon: Icon(
                Icons.search,
                size: 32,
                color: selectedIndex == 2 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Buscar',
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de navegación a Historial
          Expanded(
            child: IconButton(
              onPressed: () => onIndexChanged(1),
              icon: Icon(
                Icons.history,
                size: 32,
                color: selectedIndex == 1 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: AppConstants.tooltipHistory,
            ),
          ),
        ],
      ),
    );
  }
}

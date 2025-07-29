import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TextDisplayWidget extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool isEditing;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const TextDisplayWidget({
    super.key,
    required this.text,
    required this.isLoading,
    required this.isEditing,
    this.controller,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey.shade50,
      ),
      child: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppConstants.statusProcessing),
                ],
              ),
            )
          : isEditing
              ? TextFormField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: AppConstants.editHint,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: onChanged,
                )
              : SingleChildScrollView(
                  child: GestureDetector(
                    onTap: text.isNotEmpty ? onTap : null,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 200),
                      child: Text(
                        text.isEmpty
                            ? AppConstants.textAreaPlaceholder
                            : '$text${AppConstants.tapToEdit}',
                        style: TextStyle(
                          fontSize: 16,
                          color: text.isEmpty ? Colors.grey.shade600 : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

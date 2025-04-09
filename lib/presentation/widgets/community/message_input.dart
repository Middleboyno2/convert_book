import 'package:flutter/material.dart';
import '../../../config/colors/kcolor.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachment;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.onAttachment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            if (onAttachment != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: onAttachment,
                color: Kolors.kGold,
              ),
            // Text input field
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Kolors.kDarkGray
                      : Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // Send button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSend();
                }
              },
              color: Kolors.kGold,
            ),
          ],
        ),
      ),
    );
  }
}
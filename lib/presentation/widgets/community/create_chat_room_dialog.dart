import 'package:flutter/material.dart';
import '../../../config/colors/kcolor.dart';

class CreateChatRoomDialog extends StatefulWidget {
  final Function(String name, String description, bool isPublic) onCreateRoom;

  const CreateChatRoomDialog({
    super.key,
    required this.onCreateRoom,
  });

  @override
  State<CreateChatRoomDialog> createState() => _CreateChatRoomDialogState();
}

class _CreateChatRoomDialogState extends State<CreateChatRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Chat Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                hintText: 'Enter a name for your chat room',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a room name';
                }
                if (value.length < 3) {
                  return 'Room name must be at least 3 characters';
                }
                if (value.length > 30) {
                  return 'Room name must be less than 30 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'What is this chat room about?',
              ),
              maxLines: 2,
              validator: (value) {
                if (value != null && value.length > 100) {
                  return 'Description must be less than 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Room'),
              subtitle: const Text(
                  'Public rooms are visible to everyone'
              ),
              value: _isPublic,
              activeColor: Kolors.kGold,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Kolors.kGold,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreateRoom(
                _nameController.text.trim(),
                _descriptionController.text.trim(),
                _isPublic,
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
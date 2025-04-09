import 'package:flutter/material.dart';
import '../../../config/colors/kcolor.dart';
import '../../../domain/entities/chat_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Kolors.kGold.withOpacity(0.8) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                // Display attachments if any
                if (message.attachments != null && message.attachments!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildAttachments(),
                  ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Kolors.kGold.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: message.senderPhotoUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          message.senderPhotoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
        ),
      )
          : _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return Center(
      child: Text(
        message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Kolors.kGold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    // TODO: Implement proper attachment handling
    // This is just a placeholder implementation
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.attachment),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (today == messageDate) {
      // Today: just show the time
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDate).inDays == 1) {
      // Yesterday
      return 'Yesterday, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDate).inDays < 7) {
      // Within a week
      return '${_getDayName(timestamp.weekday)}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // More than a week ago
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
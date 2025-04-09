import 'package:flutter/material.dart';
import '../../../config/colors/kcolor.dart';
import '../../../domain/entities/chat_entity.dart';

class ChatRoomCard extends StatelessWidget {
  final ChatRoomEntity chatRoom;
  final VoidCallback onTap;

  const ChatRoomCard({
    super.key,
    required this.chatRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chatRoom.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatMessageTime(chatRoom.lastMessage?.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (chatRoom.description != null && chatRoom.description!.isNotEmpty)
                      Text(
                        chatRoom.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          chatRoom.isPublic ? Icons.public : Icons.lock,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chatRoom.isPublic ? 'Public' : 'Private',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${chatRoom.participantIds.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (chatRoom.lastMessage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${chatRoom.lastMessage!.senderName}: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: chatRoom.lastMessage!.content,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Kolors.kGold.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: chatRoom.photoUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          chatRoom.photoUrl!,
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
        chatRoom.name.isNotEmpty ? chatRoom.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Kolors.kGold,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
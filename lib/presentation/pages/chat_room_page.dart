import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors/kcolor.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/chat_message/chat_message_bloc.dart';
import '../bloc/chat_message/chat_message_event.dart';
import '../bloc/chat_message/chat_message_state.dart';
import '../bloc/chat_room/chat_room_bloc.dart';
import '../bloc/chat_room/chat_room_event.dart';
import '../bloc/chat_room/chat_room_state.dart';
import '../widgets/community/message_bubble.dart';
import '../widgets/community/message_input.dart';
import '../widgets/community/user_search_delegate.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatRoomId;

  const ChatRoomPage({
    Key? key,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  StreamSubscription<ChatRoomsState>? subscription;
  ChatRoomEntity? _chatRoom;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Load the chat room details
    _loadChatRoom();

    // Load messages for this chat room
    context.read<ChatMessagesBloc>().add(
      LoadMessagesEvent(widget.chatRoomId),
    );
  }

  void _loadChatRoom() {
    // First check if we can find the chat room in the current state
    final chatRoomsState = context.read<ChatRoomsBloc>().state;
    ChatRoomEntity? room;
    if (chatRoomsState is ChatRoomsLoaded) {
      try {
        room = chatRoomsState.chatRooms.firstWhere(
              (room) => room.id == widget.chatRoomId,
        );
      } catch (e) {
        room = null;
      }
      if (room != null) {
        setState(() {
          _chatRoom = room;
          _isLoading = false;
        });
        return;
      }
    }

    context.read<ChatRoomsBloc>().add(LoadChatRoomsEvent());

    // Listen for the rooms to be loaded
    subscription = context.read<ChatRoomsBloc>().stream.listen((state) {
      if (state is ChatRoomsLoaded) {
        try {
          final room = state.chatRooms.firstWhere(
                (room) => room.id == widget.chatRoomId,
          );

          setState(() {
            _chatRoom = room;
            _isLoading = false;
          });

          // We found the room, so we can cancel the subscription
          subscription?.cancel();
        } catch (e) {
          // Room not found in the loaded rooms
          setState(() {
            _isLoading = false;
            _errorMessage = 'Chat room not found';
          });
          subscription?.cancel();
        }
      } else if (state is ChatRoomsError) {
        setState(() {
          _isLoading = false;
          _errorMessage = state.message;
        });
        subscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadChatRoom();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chatRoom == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat Room'),
        ),
        body: const Center(
          child: Text('Chat room not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_chatRoom!.name),
        actions: [
          // Add member button (only for private chat rooms and for authenticated users)
          if (!_chatRoom!.isPublic)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      _showUserSearchDialog(context);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          // Room info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showRoomDetails(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthUnauthenticated) {
            return const Center(
              child: Text('Please log in to participate in this chat'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(),
              ),
              if (authState is AuthAuthenticated)
                MessageInput(
                  controller: _messageController,
                  onSend: _sendMessage,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<ChatMessagesBloc, ChatMessagesState>(
      listener: (context, state) {
        if (state is MessageSendSuccess) {
          // Scroll to the bottom when a new message is sent
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else if (state is MessageSendFailure) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatMessagesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatMessagesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatMessagesBloc>().add(
                      LoadMessagesEvent(widget.chatRoomId),
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Get messages from state or use empty list
        final messages = state is ChatMessagesLoaded ? state.messages : [];

        if (messages.isEmpty) {
          return const Center(
            child: Text('No messages yet. Be the first to say something!'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Display newest messages at the bottom
          itemCount: messages.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageBubble(
              message: message,
              isCurrentUser: _isCurrentUser(message.senderId),
            );
          },
        );
      },
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatMessagesBloc>().add(
      SendMessageEvent(
        chatRoomId: widget.chatRoomId,
        content: content,
      ),
    );

    _messageController.clear();
  }

  bool _isCurrentUser(String senderId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return senderId == authState.user.id;
    }
    return false;
  }

  void _showUserSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: UserSearchDelegate(
        onUserSelected: (user) {
          // Add the selected user to the chat room
          context.read<ChatRoomsBloc>().add(
            AddUserToChatRoomEvent(
              chatRoomId: widget.chatRoomId,
              userId: user.id,
            ),
          );

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.displayName ?? 'User'} added to the chat room'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showRoomDetails(BuildContext context) {
    if (_chatRoom == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_chatRoom!.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_chatRoom!.description != null && _chatRoom!.description!.isNotEmpty)
                Text(
                  _chatRoom!.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _chatRoom!.isPublic ? Icons.public : Icons.lock,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _chatRoom!.isPublic ? 'Public Room' : 'Private Room',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_chatRoom!.participantIds.length} participants',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created on ${_formatDate(_chatRoom!.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // List of participants (for private rooms)
              if (!_chatRoom!.isPublic && _chatRoom!.participantIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Participants:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // This would ideally show the list of participants
                // In a real app, you'd need to fetch user details for each ID
                ...List.generate(
                  _chatRoom!.participantIds.length > 5
                      ? 5
                      : _chatRoom!.participantIds.length,
                      (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'User ${_chatRoom!.participantIds[index].substring(0, 6)}...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_chatRoom!.participantIds.length > 5)
                  Text(
                    '...and ${_chatRoom!.participantIds.length - 5} more',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
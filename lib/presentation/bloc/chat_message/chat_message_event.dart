import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';

abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatMessagesEvent {
  final String chatRoomId;

  const LoadMessagesEvent(this.chatRoomId);

  @override
  List<Object> get props => [chatRoomId];
}

class MessagesUpdatedEvent extends ChatMessagesEvent {
  final List<MessageEntity> messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}

class SendMessageEvent extends ChatMessagesEvent {
  final String chatRoomId;
  final String content;
  final List<String>? attachmentUrls;

  const SendMessageEvent({
    required this.chatRoomId,
    required this.content,
    this.attachmentUrls,
  });

  @override
  List<Object?> get props => [chatRoomId, content, attachmentUrls];
}

class DeleteMessageEvent extends ChatMessagesEvent {
  final String chatRoomId;
  final String messageId;

  const DeleteMessageEvent({
    required this.chatRoomId,
    required this.messageId,
  });

  @override
  List<Object> get props => [chatRoomId, messageId];
}
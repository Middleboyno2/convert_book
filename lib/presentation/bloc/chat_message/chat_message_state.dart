import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();

  @override
  List<Object> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<MessageEntity> messages;

  const ChatMessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatMessagesState {
  final List<MessageEntity> messages;

  const MessageSending({required this.messages});

  @override
  List<Object> get props => [messages];
}

class MessageSendSuccess extends ChatMessagesState {
  final String messageId;

  const MessageSendSuccess(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageSendFailure extends ChatMessagesState {
  final String message;

  const MessageSendFailure(this.message);

  @override
  List<Object> get props => [message];
}
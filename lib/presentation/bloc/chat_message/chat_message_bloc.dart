import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';

import '../../../domain/usecases/chat/get_message_usecase.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';
import 'chat_message_event.dart';
import 'chat_message_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  String? _currentChatRoomId;

  ChatMessagesBloc({
    required this.getMessages,
    required this.sendMessage,
  }) : super(ChatMessagesInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesErrorEvent>(_onMessError);

  }
  Future<void> _onMessError(event, emit) async{
    emit(ChatMessagesError('Failed to load messages: ${event.error}'));
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event,
      Emitter<ChatMessagesState> emit,
      ) async {
    // Only reload if chat room has changed
    if (_currentChatRoomId != event.chatRoomId) {
      emit(ChatMessagesLoading());

      // Cancel existing subscription if there is one
      await _messagesSubscription?.cancel();

      // Update current chat room id
      _currentChatRoomId = event.chatRoomId;

      try {
        // Subscribe to the messages stream
        _messagesSubscription = getMessages(
          ChatRoomParams(chatRoomId: event.chatRoomId),
        ).listen(
              (messages) {
            add(MessagesUpdatedEvent(messages));
          },
          onError: (error) {
            emit(ChatMessagesError('Failed to load messages: $error'));
          },
        );
      } catch (e) {
        emit(ChatMessagesError('Failed to load messages: $e'));
      }
    }
  }

  void _onMessagesUpdated(
      MessagesUpdatedEvent event,
      Emitter<ChatMessagesState> emit,
      ) {
    emit(ChatMessagesLoaded(event.messages));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatMessagesState> emit,
      ) async {
    // Keep the current state while sending
    final currentState = state;

    // Show sending indicator
    emit(MessageSending(
      messages: currentState is ChatMessagesLoaded ? currentState.messages : [],
    ));

    final result = await sendMessage(
      SendMessageParams(
        chatRoomId: event.chatRoomId,
        content: event.content,
        attachmentUrls: event.attachmentUrls,
      ),
    );

    result.fold(
          (failure) {
        emit(MessageSendFailure('Failed to send message'));
        // Return to previous state
        if (currentState is ChatMessagesLoaded) {
          emit(currentState);
        }
      },
          (messageId) {
        // Message sent successfully - the stream will update with the new message
        emit(MessageSendSuccess(messageId));

        // Return to previous state with messages
        if (currentState is ChatMessagesLoaded) {
          emit(currentState);
        }
      },
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
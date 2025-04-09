import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/usecases/chat/add_user_to_chat_room_usecase.dart';
import '../../../domain/usecases/chat/create_chat_room_usecase.dart';
import '../../../domain/usecases/chat/get_chat_room_use_case.dart';
import '../../../domain/usecases/chat/join_chat_room_usecase.dart';
import '../../../domain/usecases/chat/leave_chat_room.dart';
import '../../../domain/usecases/chat/remove_user_from_chat_room_usecase.dart';
import '../../../domain/usecases/chat/search_chat_room_use_case.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomsBloc extends Bloc<ChatRoomsEvent, ChatRoomsState> {
  final GetChatRoomsUseCase getChatRooms;
  final CreateChatRoomUseCase createChatRoom;
  final JoinChatRoomUseCase joinChatRoom;
  final LeaveChatRoomUseCase leaveChatRoom;
  final AddUserToChatRoomUseCase addUserToChatRoom;
  final RemoveUserFromChatRoomUseCase removeUserFromChatRoom;
  final SearchChatRoomsUseCase searchChatRooms;

  StreamSubscription<List<ChatRoomEntity>>? _chatRoomsSubscription;

  ChatRoomsBloc({
    required this.getChatRooms,
    required this.createChatRoom,
    required this.joinChatRoom,
    required this.leaveChatRoom,
    required this.addUserToChatRoom,
    required this.removeUserFromChatRoom,
    required this.searchChatRooms,
  }) : super(ChatRoomsInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<ChatRoomsUpdatedEvent>(_onChatRoomsUpdated);
    on<CreateChatRoomEvent>(_onCreateChatRoom);
    on<JoinChatRoomEvent>(_onJoinChatRoom);
    on<LeaveChatRoomEvent>(_onLeaveChatRoom);
    on<AddUserToChatRoomEvent>(_onAddUserToChatRoom);
    on<RemoveUserFromChatRoomEvent>(_onRemoveUserFromChatRoom);
    on<SearchChatRoomsEvent>(_onSearchChatRooms);
    on<ChatRoomsErrorEvent>(_onChatRoomsError);
  }

  Future<void> _onLoadChatRooms(
      LoadChatRoomsEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    emit(ChatRoomsLoading());

    try {
      // Cancel any existing subscription
      await _chatRoomsSubscription?.cancel();

      // Start listening to the chat rooms stream
      _chatRoomsSubscription = getChatRooms(NoParams()).listen(
            (chatRooms) {
          add(ChatRoomsUpdatedEvent(chatRooms));
        },
        onError: (error) {
          add(ChatRoomsErrorEvent(error.toString()));
        },
      );
    } catch (e) {
      emit(ChatRoomsError('Failed to load chat rooms: $e'));
    }
  }

  Future<void> _onChatRoomsUpdated(
      ChatRoomsUpdatedEvent event,
      Emitter<ChatRoomsState> emit,
      ) async{
    emit(ChatRoomsLoaded(event.chatRooms));
  }

  Future<void> _onChatRoomsError(
      ChatRoomsErrorEvent event,
      Emitter<ChatRoomsState> emit,
      ) async{
    emit(ChatRoomsError(event.message));
  }

  Future<void> _onCreateChatRoom(
      CreateChatRoomEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    emit(ChatRoomCreating());

    final result = await createChatRoom(
      CreateChatRoomParams(
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      ),
    );

    result.fold(
          (failure) {
        String message = 'Failed to create chat room';
        if (failure is ServerFailure) {
          message = 'Server error occurred';
        } else if (failure is NetworkFailure) {
          message = 'Network connection issue';
        } else if (failure is NotAuthenticatedFailure) {
          message = 'You need to be logged in';
        }
        emit(ChatRoomCreationFailure(message));
      },
          (chatRoom) {
        emit(ChatRoomCreationSuccess(chatRoom));
        // Return to the loaded state with the current list of chat rooms
        if (state is ChatRoomsLoaded) {
          emit(ChatRoomsLoaded((state as ChatRoomsLoaded).chatRooms));
        } else {
          // Reload chat rooms if we don't have the current list
          add(LoadChatRoomsEvent());
        }
      },
    );
  }

  Future<void> _onJoinChatRoom(
      JoinChatRoomEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    final currentState = state;
    if (currentState is ChatRoomsLoaded) {
      emit(ChatRoomsLoading());

      final result = await joinChatRoom(
        JoinChatRoomParams(chatRoomId: event.chatRoomId),
      );

      result.fold(
            (failure) {
          String message = 'Failed to join chat room';
          if (failure is ServerFailure) {
            message = 'Server error occurred';
          } else if (failure is NetworkFailure) {
            message = 'Network connection issue';
          } else if (failure is NotAuthenticatedFailure) {
            message = 'You need to be logged in';
          }
          emit(ChatRoomsError(message));
          // Return to previous state
          emit(currentState);
        },
            (_) {
          // Successfully joined, reload chat rooms
          add(LoadChatRoomsEvent());
        },
      );
    }
  }

  Future<void> _onLeaveChatRoom(
      LeaveChatRoomEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    final currentState = state;
    if (currentState is ChatRoomsLoaded) {
      emit(ChatRoomsLoading());

      final result = await leaveChatRoom(
        LeaveChatRoomParams(chatRoomId: event.chatRoomId),
      );

      result.fold(
            (failure) {
          String message = 'Failed to leave chat room';
          if (failure is ServerFailure) {
            message = 'Server error occurred';
          } else if (failure is NetworkFailure) {
            message = 'Network connection issue';
          } else if (failure is NotAuthenticatedFailure) {
            message = 'You need to be logged in';
          }
          emit(ChatRoomsError(message));
          // Return to previous state
          emit(currentState);
        },
            (_) {
          // Successfully left, reload chat rooms
          add(LoadChatRoomsEvent());
        },
      );
    }
  }

  Future<void> _onAddUserToChatRoom(
      AddUserToChatRoomEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    final currentState = state;

    emit(ChatRoomUpdating());

    final result = await addUserToChatRoom(
      AddUserToChatRoomParams(
        chatRoomId: event.chatRoomId,
        userId: event.userId,
      ),
    );

    result.fold(
          (failure) {
        String message = 'Failed to add user to chat room';
        if (failure is ServerFailure) {
          message = 'Server error occurred';
        } else if (failure is NetworkFailure) {
          message = 'Network connection issue';
        } else if (failure is NotAuthenticatedFailure) {
          message = 'You need to be logged in';
        } else if (failure is NotFoundFailure) {
          message = 'Chat room not found';
        } else if (failure is UnauthorizedFailure) {
          message = 'You do not have permission to add users to this chat room';
        }
        emit(ChatRoomUpdateFailure(message));
        // Return to previous state if available
        if (currentState is ChatRoomsLoaded) {
          emit(currentState);
        }
      },
          (_) {
        // Successfully added user, show success state
        emit(ChatRoomUpdateSuccess('User added successfully'));
        // Then reload chat rooms
        add(LoadChatRoomsEvent());
      },
    );
  }

  Future<void> _onRemoveUserFromChatRoom(
      RemoveUserFromChatRoomEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    final currentState = state;

    emit(ChatRoomUpdating());

    final result = await removeUserFromChatRoom(
      RemoveUserFromChatRoomParams(
        chatRoomId: event.chatRoomId,
        userId: event.userId,
      ),
    );

    result.fold(
          (failure) {
        String message = 'Failed to remove user from chat room';
        if (failure is ServerFailure) {
          message = 'Server error occurred';
        } else if (failure is NetworkFailure) {
          message = 'Network connection issue';
        } else if (failure is NotAuthenticatedFailure) {
          message = 'You need to be logged in';
        } else if (failure is NotFoundFailure) {
          message = 'Chat room not found';
        } else if (failure is UnauthorizedFailure) {
          message = 'You do not have permission to remove users from this chat room';
        }
        emit(ChatRoomUpdateFailure(message));
        // Return to previous state if available
        if (currentState is ChatRoomsLoaded) {
          emit(currentState);
        }
      },
          (_) {
        // Successfully removed user, show success state
        emit(ChatRoomUpdateSuccess('User removed successfully'));
        // Then reload chat rooms
        add(LoadChatRoomsEvent());
      },
    );
  }

  Future<void> _onSearchChatRooms(
      SearchChatRoomsEvent event,
      Emitter<ChatRoomsState> emit,
      ) async {
    emit(ChatRoomsLoading());

    final result = await searchChatRooms(
      SearchChatRoomsParams(query: event.query),
    );

    result.fold(
          (failure) {
        String message = 'Failed to search chat rooms';
        if (failure is ServerFailure) {
          message = 'Server error occurred';
        } else if (failure is NetworkFailure) {
          message = 'Network connection issue';
        } else if (failure is NotAuthenticatedFailure) {
          message = 'You need to be logged in';
        }
        emit(ChatRoomsError(message));
      },
          (chatRooms) {
        emit(ChatRoomsLoaded(chatRooms));
      },
    );
  }

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    return super.close();
  }
}
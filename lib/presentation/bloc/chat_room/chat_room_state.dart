import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';

abstract class ChatRoomsState extends Equatable {
  const ChatRoomsState();

  @override
  List<Object> get props => [];
}

class ChatRoomsInitial extends ChatRoomsState {}

class ChatRoomsLoading extends ChatRoomsState {}

class ChatRoomsLoaded extends ChatRoomsState {
  final List<ChatRoomEntity> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class ChatRoomsError extends ChatRoomsState {
  final String message;

  const ChatRoomsError(this.message);

  @override
  List<Object> get props => [message];
}

// States for Creating a Chat Room
class ChatRoomCreating extends ChatRoomsState {}

class ChatRoomCreationSuccess extends ChatRoomsState {
  final ChatRoomEntity chatRoom;

  const ChatRoomCreationSuccess(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class ChatRoomCreationFailure extends ChatRoomsState {
  final String message;

  const ChatRoomCreationFailure(this.message);

  @override
  List<Object> get props => [message];
}

// States for Updating a Chat Room (adding/removing members)
class ChatRoomUpdating extends ChatRoomsState {}

class ChatRoomUpdateSuccess extends ChatRoomsState {
  final String message;

  const ChatRoomUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ChatRoomUpdateFailure extends ChatRoomsState {
  final String message;

  const ChatRoomUpdateFailure(this.message);

  @override
  List<Object> get props => [message];
}
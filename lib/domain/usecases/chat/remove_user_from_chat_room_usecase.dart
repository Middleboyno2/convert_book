import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class RemoveUserFromChatRoomUseCase implements UseCase<void, RemoveUserFromChatRoomParams> {
  final ChatRepository repository;

  RemoveUserFromChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveUserFromChatRoomParams params) {
    return repository.removeUserFromChatRoom(params.chatRoomId, params.userId);
  }
}

class RemoveUserFromChatRoomParams extends Equatable {
  final String chatRoomId;
  final String userId;

  const RemoveUserFromChatRoomParams({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object> get props => [chatRoomId, userId];
}

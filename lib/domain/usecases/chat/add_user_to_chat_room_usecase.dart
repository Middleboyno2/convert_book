import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class AddUserToChatRoomUseCase implements UseCase<void, AddUserToChatRoomParams> {
  final ChatRepository repository;

  AddUserToChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddUserToChatRoomParams params) {
    return repository.addUserToChatRoom(params.chatRoomId, params.userId);
  }
}

class AddUserToChatRoomParams extends Equatable {
  final String chatRoomId;
  final String userId;

  const AddUserToChatRoomParams({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object> get props => [chatRoomId, userId];
}
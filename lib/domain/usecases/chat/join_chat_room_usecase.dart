// Join Chat Room Use Case
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class JoinChatRoomUseCase implements UseCase<void, JoinChatRoomParams> {
  final ChatRepository repository;

  JoinChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinChatRoomParams params) {
    return repository.joinChatRoom(params.chatRoomId);
  }
}

class JoinChatRoomParams extends Equatable {
  final String chatRoomId;

  const JoinChatRoomParams({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}
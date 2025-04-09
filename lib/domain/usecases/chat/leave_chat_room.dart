import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class LeaveChatRoomUseCase implements UseCase<void, LeaveChatRoomParams> {
  final ChatRepository repository;

  LeaveChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LeaveChatRoomParams params) {
    return repository.leaveChatRoom(params.chatRoomId);
  }
}

class LeaveChatRoomParams extends Equatable {
  final String chatRoomId;

  const LeaveChatRoomParams({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}
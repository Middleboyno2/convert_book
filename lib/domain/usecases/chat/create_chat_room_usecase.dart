import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/chat_repository.dart';

class CreateChatRoomUseCase implements UseCase<ChatRoomEntity, CreateChatRoomParams> {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, ChatRoomEntity>> call(CreateChatRoomParams params) {
    return repository.createChatRoom(
      params.name,
      params.description,
      params.isPublic,
    );
  }
}

class CreateChatRoomParams extends Equatable {
  final String name;
  final String description;
  final bool isPublic;

  const CreateChatRoomParams({
    required this.name,
    required this.description,
    required this.isPublic,
  });

  @override
  List<Object?> get props => [name, description, isPublic];
}
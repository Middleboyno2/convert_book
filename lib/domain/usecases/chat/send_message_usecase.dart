import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class SendMessageUseCase implements UseCase<String, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SendMessageParams params) {
    return repository.sendMessage(
      params.chatRoomId,
      params.content,
      params.attachmentUrls,
    );
  }
}

class SendMessageParams extends Equatable {
  final String chatRoomId;
  final String content;
  final List<String>? attachmentUrls;

  const SendMessageParams({
    required this.chatRoomId,
    required this.content,
    this.attachmentUrls,
  });

  @override
  List<Object?> get props => [chatRoomId, content, attachmentUrls];
}
import 'package:equatable/equatable.dart';

import '../../../core/usecase/stream_usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/chat_repository.dart';

class GetMessagesUseCase implements StreamUseCase<List<MessageEntity>, ChatRoomParams> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Stream<List<MessageEntity>> call(ChatRoomParams params) {
    return repository.getMessages(params.chatRoomId);
  }
}

class ChatRoomParams extends Equatable {
  final String chatRoomId;

  const ChatRoomParams({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}
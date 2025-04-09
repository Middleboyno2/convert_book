
import '../../../core/usecase/stream_usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/chat_repository.dart';

class GetChatRoomsUseCase implements StreamUseCase<List<ChatRoomEntity>, NoParams> {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  @override
  Stream<List<ChatRoomEntity>> call(NoParams params) {
    return repository.getChatRooms();
  }
}

class NoParams {}
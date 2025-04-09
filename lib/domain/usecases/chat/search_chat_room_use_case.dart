import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/chat_repository.dart';

class SearchChatRoomsUseCase implements UseCase<List<ChatRoomEntity>, SearchChatRoomsParams> {
  final ChatRepository repository;

  SearchChatRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> call(SearchChatRoomsParams params) {
    return repository.searchChatRooms(params.query);
  }
}

class SearchChatRoomsParams extends Equatable {
  final String query;

  const SearchChatRoomsParams({required this.query});

  @override
  List<Object> get props => [query];
}
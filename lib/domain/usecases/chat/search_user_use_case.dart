import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/chat_repository.dart';

class SearchUsersUseCase implements UseCase<List<UserEntity>, SearchUsersParams> {
  final ChatRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(SearchUsersParams params) {
    return repository.searchUsers(params.query);
  }
}

class SearchUsersParams extends Equatable {
  final String query;

  const SearchUsersParams({required this.query});

  @override
  List<Object> get props => [query];
}
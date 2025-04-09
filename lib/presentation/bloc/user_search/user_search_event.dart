import 'package:equatable/equatable.dart';

abstract class UserSearchEvent extends Equatable {
  const UserSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchUsersEvent extends UserSearchEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object> get props => [query];
}
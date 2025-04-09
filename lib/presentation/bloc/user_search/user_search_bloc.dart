import 'package:bloc/bloc.dart';
import 'package:doantotnghiep/presentation/bloc/user_search/user_search_event.dart';
import 'package:doantotnghiep/presentation/bloc/user_search/user_search_state.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/chat/search_user_use_case.dart';



class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final SearchUsersUseCase searchUsers;

  UserSearchBloc({
    required this.searchUsers,
  }) : super(UserSearchInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
  }

  Future<void> _onSearchUsers(
      SearchUsersEvent event,
      Emitter<UserSearchState> emit,
      ) async {
    emit(UserSearchLoading());

    final result = await searchUsers(SearchUsersParams(query: event.query));

    result.fold(
          (failure) => emit(UserSearchError(_mapFailureToMessage(failure))),
          (users) => emit(UserSearchLoaded(users)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Error del servidor';
      case NetworkFailure:
        return 'Error de conexión';
      case NotAuthenticatedFailure:
        return 'Debe iniciar sesión para realizar esta acción';
      default:
        return 'Error inesperado';
    }
  }
}
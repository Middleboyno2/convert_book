import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../bloc/user_search/user_search_bloc.dart';
import '../../bloc/user_search/user_search_event.dart';
import '../../bloc/user_search/user_search_state.dart';

class UserSearchDelegate extends SearchDelegate<UserEntity?> {
  final Function(UserEntity) onUserSelected;

  UserSearchDelegate({required this.onUserSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return const Center(
        child: Text('Por favor ingrese al menos 3 caracteres para buscar'),
      );
    }

    context.read<UserSearchBloc>().add(SearchUsersEvent(query));

    return BlocBuilder<UserSearchBloc, UserSearchState>(
      builder: (context, state) {
        if (state is UserSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserSearchError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (state is UserSearchLoaded) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text('No se encontraron usuarios con este criterio'),
            );
          }

          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.displayName?[0] ?? '?')
                      : null,
                ),
                title: Text(user.displayName ?? 'Usuario'),
                subtitle: Text('ID: ${user.id}'),
                onTap: () {
                  onUserSelected(user);
                  close(context, user);
                },
              );
            },
          );
        }

        return const Center(
          child: Text('Busca usuarios por nombre o ID'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Busca usuarios para añadir al chat',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
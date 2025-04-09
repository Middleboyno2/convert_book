// lib/presentation/pages/chat/add_user_to_chat_page.dart
import 'package:doantotnghiep/presentation/bloc/chat_room/chat_room_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../bloc/chat_room/chat_room_event.dart';
import '../../bloc/user_search/user_search_bloc.dart';
import '../../bloc/user_search/user_search_event.dart';
import '../../bloc/user_search/user_search_state.dart';

class AddUserToChatPage extends StatefulWidget {
  final String chatRoomId;

  const AddUserToChatPage({
    Key? key,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<AddUserToChatPage> createState() => _AddUserToChatPageState();
}

class _AddUserToChatPageState extends State<AddUserToChatPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir usuario al chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por ID o nombre',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          Expanded(
            child: BlocBuilder<UserSearchBloc, UserSearchState>(
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
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => _addUserToChat(user),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Busca usuarios para añadirlos al chat'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    context.read<UserSearchBloc>().add(SearchUsersEvent(query));
  }

  void _addUserToChat(UserEntity user) {
    context.read<ChatRoomsBloc>().add(
      AddUserToChatRoomEvent(
        chatRoomId: widget.chatRoomId,
        userId: user.id,
      ),
    );

    // Mostrar snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.displayName} añadido al chat')),
    );
  }
}
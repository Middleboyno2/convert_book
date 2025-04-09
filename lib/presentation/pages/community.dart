import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors/kcolor.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/chat_room/chat_room_bloc.dart';
import '../bloc/chat_room/chat_room_event.dart';
import '../bloc/chat_room/chat_room_state.dart';
import '../widgets/community/chat_room_card.dart';
import '../widgets/community/create_chat_room_dialog.dart';
import '../widgets/empty/empty_book.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Create tab controller for public/private chats
    _tabController = TabController(length: 2, vsync: this);

    // Load chat rooms when the page is first loaded
    context.read<ChatRoomsBloc>().add(LoadChatRoomsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  // Reset search results
                  context.read<ChatRoomsBloc>().add(LoadChatRoomsEvent());
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'filter_public') {
                _tabController.animateTo(0);
              } else if (value == 'filter_private') {
                _tabController.animateTo(1);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'filter_public',
                child: Text('Public Chats'),
              ),
              const PopupMenuItem<String>(
                value: 'filter_private',
                child: Text('Private Chats'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Public'),
            Tab(text: 'Private'),
          ],
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthUnauthenticated) {
            return _buildUnauthenticatedView();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Public chat rooms tab
              _buildChatRoomsList(isPublic: true),
              // Private chat rooms tab
              _buildChatRoomsList(isPublic: false),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return FloatingActionButton(
              backgroundColor: Kolors.kGold,
              onPressed: () {
                _showCreateChatRoomDialog(context);
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search chat rooms...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Kolors.kGrayLight),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (query) {
        if (query.length >= 3) {
          // Search chat rooms by name
          context.read<ChatRoomsBloc>().add(SearchChatRoomsEvent(query));
        } else if (query.isEmpty) {
          // Reset to show all chat rooms
          context.read<ChatRoomsBloc>().add(LoadChatRoomsEvent());
        }
      },
    );
  }

  Widget _buildUnauthenticatedView() {
    return EmptyBook(
      title: 'Please login to access the community',
      buttonText: 'Login',
      onPressed: () {
        Navigator.pushNamed(context, '/auth');
      },
    );
  }

  Widget _buildChatRoomsList({required bool isPublic}) {
    return BlocBuilder<ChatRoomsBloc, ChatRoomsState>(
      builder: (context, state) {
        if (state is ChatRoomsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatRoomsError) {
          return _buildErrorView(state.message);
        } else if (state is ChatRoomsLoaded) {
          // Filter chat rooms by public/private status
          final filteredRooms = state.chatRooms
              .where((room) => room.isPublic == isPublic)
              .toList();

          if (filteredRooms.isEmpty) {
            return EmptyBook(
              title: isPublic
                  ? 'No public chat rooms found'
                  : 'No private chat rooms found',
              buttonText: 'Create a new chat room',
              onPressed: () {
                _showCreateChatRoomDialog(context);
              },
            );
          }

          return ListView.builder(
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = filteredRooms[index];
              return ChatRoomCard(
                chatRoom: chatRoom,
                onTap: () => _navigateToChatRoom(context, chatRoom),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatRoomsBloc>().add(LoadChatRoomsEvent());
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showCreateChatRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateChatRoomDialog(
        onCreateRoom: (name, description, isPublic) {
          context.read<ChatRoomsBloc>().add(
            CreateChatRoomEvent(
              name: name,
              description: description,
              isPublic: isPublic,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToChatRoom(BuildContext context, ChatRoomEntity chatRoom) {
    context.pushNamed('chat_room', pathParameters: {'chatRoomId': chatRoom.id});
  }
}
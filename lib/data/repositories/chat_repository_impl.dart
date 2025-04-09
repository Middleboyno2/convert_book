import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<List<ChatRoomEntity>> getChatRooms() {
    return remoteDataSource.getChatRooms();
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatRoomId) {
    return remoteDataSource.getMessages(chatRoomId);
  }

  @override
  Future<Either<Failure, ChatRoomEntity>> createChatRoom(
      String name,
      String description,
      bool isPublic,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final chatRoom = await remoteDataSource.createChatRoom(name, description, isPublic);
        return Right(chatRoom);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage(
      String chatRoomId,
      String content,
      List<String>? attachmentUrls,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final messageId = await remoteDataSource.sendMessage(
          chatRoomId,
          content,
          attachmentUrls,
        );
        return Right(messageId);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> joinChatRoom(String chatRoomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.joinChatRoom(chatRoomId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> leaveChatRoom(String chatRoomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.leaveChatRoom(chatRoomId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addUserToChatRoom(
      String chatRoomId,
      String userId,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addUserToChatRoom(chatRoomId, userId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeUserFromChatRoom(
      String chatRoomId,
      String userId,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        // This method needs to be implemented in the data source
        await remoteDataSource.removeUserFromChatRoom(chatRoomId, userId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> searchChatRooms(String query) async {
    if (await networkInfo.isConnected) {
      try {
        // This method needs to be implemented in the data source
        final chatRooms = await remoteDataSource.searchChatRooms(query);
        return Right(chatRooms);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.searchUsers(query);
        return Right(users);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(
      String chatRoomId,
      String messageId,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMessage(chatRoomId, messageId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isUserInChatRoom(String chatRoomId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.isUserInChatRoom(chatRoomId);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
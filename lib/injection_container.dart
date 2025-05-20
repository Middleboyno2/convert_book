import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doantotnghiep/domain/usecases/document/delete_document_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/get_local_document_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/is_document_cached_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/save_document_locally_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_document_category_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_document_cover_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_reading_progress_usecase.dart';
import 'package:doantotnghiep/domain/usecases/profile/upload_profile_image_usecase.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/chat_message/chat_message_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/chat_room/chat_room_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_event.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/user_search/user_search_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';

import 'core/network/network_info.dart';
import 'data/datasources/local/document_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/chat_remote_datasource.dart';
import 'data/datasources/remote/document_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/document_repository.dart';
import 'domain/usecases/chat/add_user_to_chat_room_usecase.dart';
import 'domain/usecases/chat/create_chat_room_usecase.dart';
import 'domain/usecases/chat/get_chat_room_use_case.dart';
import 'domain/usecases/chat/get_message_usecase.dart';
import 'domain/usecases/chat/join_chat_room_usecase.dart';
import 'domain/usecases/chat/leave_chat_room.dart';
import 'domain/usecases/chat/remove_user_from_chat_room_usecase.dart';
import 'domain/usecases/chat/search_chat_room_use_case.dart';
import 'domain/usecases/chat/search_user_use_case.dart';
import 'domain/usecases/chat/send_message_usecase.dart';
import 'domain/usecases/document/get_document_usecase.dart';
import 'domain/usecases/document/get_documents_usecase.dart';
import 'domain/usecases/document/get_download_url_usecase.dart';
import 'domain/usecases/document/upload_document_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/send_password_reset_email_usecase.dart';
import 'domain/usecases/sign_in_with_apple_usecase.dart';
import 'domain/usecases/sign_in_with_email_password_usecase.dart';
import 'domain/usecases/sign_in_with_google_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/sign_up_with_email_password_usecase.dart';


final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth

  // Bloc
  sl.registerFactory(
      () => SettingBloc(
      )
  );
  sl.registerFactory(
        () => AuthBloc(
      getCurrentUser: sl(),
      signInWithEmailPassword: sl(),
      signUpWithEmailPassword: sl(),
      signInWithGoogle: sl(),
      signInWithApple: sl(),
      signOut: sl(),
      sendPasswordResetEmail: sl(),
      upLoadProfileImage: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
        () => DocumentBloc(
      getDocuments: sl(),
      getDocument: sl(),
      uploadDocument: sl(),
      getDownloadUrl: sl(),
      deleteDocument: sl(),
      authBloc: sl(),
      updateDocumentCategory: sl(),
      updateReadingProgress: sl(),
      updateDocumentCover: sl(),
    ),
  );

  sl.registerFactory(
        () => DocumentReaderBloc(
      getDownloadUrl: sl(),
      getLocalDocument: sl(),
      isDocumentCached: sl(),
      saveDocumentLocally: sl(),
    ),
  );

  sl.registerFactory(
        ()=> ChatRoomsBloc(
      getChatRooms: sl(),
      createChatRoom: sl(),
      joinChatRoom: sl(),
      leaveChatRoom: sl(),
      addUserToChatRoom: sl(),
      removeUserFromChatRoom: sl(),
      searchChatRooms: sl()
    ),
  );

  sl.registerFactory(
      ()=> ChatMessagesBloc(
          getMessages: sl(),
          sendMessage: sl()
      ),
  );
  sl.registerFactory(
        () => UserSearchBloc(
      searchUsers: sl(),
    ),
  );

  // Use cases
  // auth
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));

  // document
  sl.registerLazySingleton(() => GetDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => GetDownloadUrlUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDocumentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDocumentCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReadingProgressUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDocumentCoverUseCase(sl()));
  sl.registerLazySingleton(() => GetLocalDocumentUseCase(sl()));
  sl.registerLazySingleton(() => IsDocumentCachedUseCase(sl()));
  sl.registerLazySingleton(() => SaveDocumentLocallyUseCase(sl()));

  // chat
  sl.registerLazySingleton(() => GetChatRoomsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => JoinChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => LeaveChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => AddUserToChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => RemoveUserFromChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => SearchChatRoomsUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<DocumentRepository>(
        () => DocumentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<DocumentRemoteDataSource>(
        () => DocumentRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      auth: sl(), // This should come from authentication
    ),
  );

  sl.registerLazySingleton<DocumentLocalDataSource>(
        () => DocumentLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
        () => ChatRemoteDataSourceImpl(
      database: sl(),
      auth: sl(),
    ),
  );



  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FirebaseDatabase.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.createInstance());
}

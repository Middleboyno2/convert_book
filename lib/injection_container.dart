import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doantotnghiep/domain/usecases/document/delete_document_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_document_category_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_document_cover_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/update_reading_progress_usecase.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_event.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';

import 'core/network/network_info.dart';
import 'data/datasources/local/document_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/document_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/document_repository.dart';
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
        () => AuthBloc(
      getCurrentUser: sl(),
      signInWithEmailPassword: sl(),
      signUpWithEmailPassword: sl(),
      signInWithGoogle: sl(),
      signInWithApple: sl(),
      signOut: sl(),
      sendPasswordResetEmail: sl(),
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
      localDataSource: sl(),
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

  // document
  sl.registerLazySingleton(() => GetDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => GetDownloadUrlUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDocumentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDocumentCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReadingProgressUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDocumentCoverUseCase(sl()));

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

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
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
        () => DocumentLocalDataSourceImpl(
      getDirectory: () async => await getApplicationDocumentsDirectory(),
    ),
  );



  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.createInstance());
}

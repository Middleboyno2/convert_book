import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doantotnghiep/core/utils/firebase_storage_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/enums.dart';
import '../../models/user_model.dart';
import 'package:path/path.dart' as path;

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String name, String phone);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> upLoadProfileImage(File file);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final FirebaseStorageHelper _firebaseStorageHelper;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore,
        _firebaseStorageHelper = FirebaseStorageHelper(storage: storage, auth: firebaseAuth);

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) {
        return null;
      }
      // Xác định provider
      Provider provider = Provider.email;
      if (user.providerData.isNotEmpty) {
        String providerId = user.providerData[0].providerId;
        if (providerId == 'google.com') {
          provider = Provider.google;
        } else if (providerId == 'apple.com') {
          provider = Provider.apple;
        }else {
          provider = Provider.anonymous;
        }
      }
      return UserModel.fromFirebaseUser(user, provider);
    });
  }

  Future<void> saveLocalStorage(String key, String value) async{
    // luu trong local storage SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      //await saveLocalStorage('user', user!.uid ??  '');
      // Xác định provider
      Provider provider = Provider.email;
      if (user!.providerData.isEmpty) {
        String providerId = user.providerData[0].providerId;
        if (providerId == 'google.com') {
          provider = Provider.google;
        } else if (providerId == 'apple.com') {
          provider = Provider.apple;
        }else {
          provider = Provider.anonymous;
        }
      }
      return UserModel.fromFirebaseUser(user, provider);
          return null;
    } catch (e) {
      throw AuthException('Lỗi khi lấy thông tin người dùng hiện tại: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //await saveLocalStorage('user', result.user?.uid ??  '');
      return UserModel.fromFirebaseUser(result.user!, Provider.email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('Không tìm thấy tài khoản với email này');
        case 'wrong-password':
          throw AuthException('Mật khẩu không đúng');
        case 'user-disabled':
          throw AuthException('Tài khoản này đã bị vô hiệu hóa');
        case 'invalid-email':
          throw AuthException('Email không hợp lệ');
        default:
          throw AuthException('Lỗi đăng nhập: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Lỗi đăng nhập: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String name, String phone) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // await saveLocalStorage('user', result.user?.uid ??  '');
      final String? uid = result.user?.uid;
      await result.user?.updateDisplayName(name);
      // Tạo bản ghi tài liệu trong Firestore
      final docData = {
        'id': uid,
        'email': email,
        'displayName': name,
        'phoneNumber': phone,
        'provider': Provider.email.name,
      };
      await _firestore.collection('users').add(docData);
      return UserModel.fromFirebaseUser(result.user!, Provider.email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException('Email này đã được sử dụng');
        case 'invalid-email':
          throw AuthException('Email không hợp lệ');
        case 'weak-password':
          throw AuthException('Mật khẩu quá yếu');
        case 'operation-not-allowed':
          throw AuthException('Đăng ký bằng email và mật khẩu chưa được kích hoạt');
        default:
          throw AuthException('Lỗi đăng ký: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Lỗi đăng ký: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Đăng nhập Google đã bị hủy');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final String? uid = userCredential.user?.uid;
      // await saveLocalStorage('user', uid ??  '');
      // Tạo bản ghi tài liệu trong Firestore
      final docData = {
        'id': uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'phoneNumber': userCredential.user?.phoneNumber,
        'photoUrl': userCredential.user?.photoURL,
        'provider': Provider.google.name,
      };
      await _firestore.collection('users').add(docData);

      return UserModel.fromFirebaseUser(userCredential.user!, Provider.google);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Lỗi đăng nhập Google: ${e.message}');
    } catch (e) {
      throw AuthException('Lỗi đăng nhập Google: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Kiểm tra tính khả dụng của Apple Sign In
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw AuthException('Đăng nhập bằng Apple không khả dụng trên thiết bị này');
      }
      // Thực hiện Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // Tạo OAuthCredential từ Apple
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      // Đăng nhập vào Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      final String? uid = userCredential.user?.uid;
      // Cập nhật displayName nếu chưa có (Apple chỉ trả về tên trong lần đăng nhập đầu tiên)
      if (userCredential.user != null &&
          userCredential.user!.displayName == null &&
          appleCredential.givenName != null) {
        await userCredential.user!.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName}'
        );
      }
      // Tạo bản ghi tài liệu trong Firestore
      final docData = {
        'id': uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'phoneNumber': userCredential.user?.phoneNumber,
        'photoUrl': userCredential.user?.photoURL,
        'provider': Provider.google.name,
      };
      await _firestore.collection('users').add(docData);
      return UserModel.fromFirebaseUser(userCredential.user!, Provider.apple);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Lỗi đăng nhập Apple: ${e.message}');
    } catch (e) {
      throw AuthException('Lỗi đăng nhập Apple: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      // await saveLocalStorage('user', '');
    } catch (e) {
      throw AuthException('Lỗi đăng xuất: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw AuthException('Email không hợp lệ');
        case 'user-not-found':
          throw AuthException('Không tìm thấy tài khoản với email này');
        default:
          throw AuthException('Lỗi khi gửi email đặt lại mật khẩu: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Lỗi khi gửi email đặt lại mật khẩu: ${e.toString()}');
    }
  }

  @override
  Future<void> upLoadProfileImage(File file) async{
    try{
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('Người dùng chưa đăng nhập');
      }
      final imagePath = await _firebaseStorageHelper.uploadImageCover(file);
      try {
        // Cập nhật photoURL trong Firebase Auth
        await user.updatePhotoURL(imagePath);

        // Tìm document của user trong Firestore
        final querySnapshot = await _firestore.collection('users')
            .where('id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Nếu tìm thấy, cập nhật
          await querySnapshot.docs.first.reference.update({'photoUrl': imagePath});
        } else {
          print('Không tìm thấy document người dùng trong Firestore');
        }

        // Reload user để đảm bảo thông tin mới nhất
        await user.reload();
        print('Đã cập nhật thành công cả Auth và Firestore');
      } catch (e) {
        print('Lỗi khi cập nhật thông tin: $e');
        throw AuthException('Lỗi khi cập nhật thông tin: $e');
      }
    }catch(e){
      throw AuthException('loi tai anh len');
    }
  }
}
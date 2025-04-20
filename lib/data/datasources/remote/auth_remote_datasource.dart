import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/enums.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

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

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
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
      }
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
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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

      // Cập nhật displayName nếu chưa có (Apple chỉ trả về tên trong lần đăng nhập đầu tiên)
      if (userCredential.user != null &&
          userCredential.user!.displayName == null &&
          appleCredential.givenName != null) {
        await userCredential.user!.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName}'
        );
      }
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
}
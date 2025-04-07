import '../../core/utils/enums.dart';
import '../../domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.isEmailVerified,
    super.phoneNumber,
    required super.provider,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser, Provider provider) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      phoneNumber: firebaseUser.phoneNumber,
      provider: provider,
    );
  }
  // chuyển data ve dang json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'provider': provider.toString(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      provider: _providerFromString(json['provider']),
    );
  }

  static Provider _providerFromString(String providerString) {
    if (providerString.contains('email')) return Provider.email;
    if (providerString.contains('google')) return Provider.google;
    if (providerString.contains('apple')) return Provider.apple;
    return Provider.anonymous;
  }
}
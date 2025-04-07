import 'package:equatable/equatable.dart';
import '../../core/utils/enums.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final String? phoneNumber;
  final Provider provider;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.phoneNumber,
    required this.provider,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    isEmailVerified,
    phoneNumber,
    provider
  ];
}
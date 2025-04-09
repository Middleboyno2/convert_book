import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = '']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {

  const ServerFailure([super.message = 'Lỗi máy chủ']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi bộ nhớ đệm']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Lỗi xác thực']);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([super.message = 'Email đã được sử dụng']);
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure([super.message = 'Email không hợp lệ']);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([super.message = 'Mật khẩu quá yếu']);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([super.message = 'Không tìm thấy người dùng']);
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure([super.message = 'Mật khẩu không đúng']);
}

class UserDisabledFailure extends AuthFailure {
  const UserDisabledFailure([super.message = 'Tài khoản đã bị vô hiệu hóa']);
}

class SignInCancelledFailure extends AuthFailure {
  const SignInCancelledFailure([super.message = 'Đăng nhập đã bị hủy']);
}

class SignInFailedFailure extends AuthFailure {
  const SignInFailedFailure([super.message = 'Đăng nhập thất bại']);
}

class AppleSignInNotAvailableFailure extends AuthFailure {
  const AppleSignInNotAvailableFailure([super.message = 'Đăng nhập bằng Apple không khả dụng']);
}


class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Khong tim thay thong tin hop le']);
}

class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure([super.message = 'Khong ho tro file']);
}

class NotAuthenticatedFailure extends Failure {
  const NotAuthenticatedFailure([super.message = 'chua dang nhap']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'loi j day']);
}

class CoverUpdateFailure extends Failure{
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Không có quyền thực hiện hành động này']);
}

// Add new failure for chat operations
class ChatOperationFailure extends Failure {
  const ChatOperationFailure([super.message = 'Không thể thực hiện thao tác trò chuyện']);
}
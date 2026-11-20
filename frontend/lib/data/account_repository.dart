import 'app_user.dart';
import 'result.dart';

abstract class AccountRepository {
  Future<Result<AppUser>> fetchMe();
  Future<Result<AppUser>> updateMe({String? name, String? email});
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  );
}

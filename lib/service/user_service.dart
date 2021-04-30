import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/database.dart';

class UserService {
  /// Save a [user] into the local database
  static Future<void> save(User user) async {
    await db.insert(
      userTable,
      user.toMap(),
    );
  }
}
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

class UserService {
  /// Save a [user] into the local database
  static Future<void> save(User user) async {
    await db.insert(
      userTable,
      user.toMap(),
    );
  }

  /// Update a [user] into the local database
  static Future<void> update(User user) async {
    await db.update(
      userTable,
      user.toMap(),
      where: "$columnId = '${user.id}'",
    );
  }

  /// Check if the user exists
  static Future<bool> doesUserExist(String userId) async {
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: "$columnId = '$userId'",
    );

    return maps.isNotEmpty;
  }
}

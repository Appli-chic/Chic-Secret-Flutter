import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/model/database/vault_user.dart';
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
  static Future<bool> exists(String userId) async {
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: "$columnId = '$userId'",
    );

    return maps.isNotEmpty;
  }

  /// Retrieve the user by ID
  static Future<User?> getUserById(String userId) async {
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: "$columnId = '$userId'",
      limit: 1,
    );

    if (maps.length > 0) {
      return User.fromMap(maps[0]);
    }

    return null;
  }

  /// Retrieve the user by email
  static Future<User?> getUserByEmail(String email) async {
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: "$columnUserEmail = '$email'",
      limit: 1,
    );

    if (maps.length > 0) {
      return User.fromMap(maps[0]);
    }

    return null;
  }

  /// Retrieve the users linked to the vault
  static Future<List<User>> getUsersByVault(String vaultId) async {
    List<User> users = [];

    var query = """
    SELECT u.$columnId, u.$columnUserEmail, u.$columnCreatedAt, 
    u.$columnUpdatedAt, u.$columnDeletedAt
    FROM $userTable as u
    LEFT JOIN $vaultUserTable vu et ON vu.$columnVaultUserUserId = u.$columnId
    WHERE vu.$columnVaultUserVaultId = '$vaultId' AND vu.$columnDeletedAt IS NULL 
    AND u.$columnDeletedAt IS NULL
    """;

    var maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        users.add(User.fromMap(map));
      }
    }

    return users;
  }
}

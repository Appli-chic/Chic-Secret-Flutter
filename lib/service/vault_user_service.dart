import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class VaultUserService {
  /// Update the vault user already exists
  static Future<void> update(VaultUser vaultUser) async {
    await db.update(
      vaultUserTable,
      vaultUser.toMap(),
      where:
          "$columnVaultUserVaultId = '${vaultUser.vaultId}' AND $columnVaultUserUserId = '${vaultUser.userId}'",
    );
  }

  /// Save a [vaultUser] into the local database
  static Future<void> save(VaultUser vaultUser) async {
    await db.insert(
      vaultUserTable,
      vaultUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks if the vault user already exists
  static Future<bool> exists(VaultUser vaultUser) async {
    var data = await db.query(
      vaultUserTable,
      where:
          "$columnVaultUserVaultId = '${vaultUser.vaultId}' AND $columnVaultUserUserId = '${vaultUser.userId}'",
    );

    return data.isNotEmpty;
  }

  /// Get all the vault users to synchronize from the locale database to the server
  static Future<List<VaultUser>> getVaultUsersToSynchronize(
      DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      vaultUserTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return VaultUser.fromMap(maps[i]);
    });
  }
}

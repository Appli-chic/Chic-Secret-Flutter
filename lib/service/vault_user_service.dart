import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class VaultUserService {
  static Future<void> update(VaultUser vaultUser) async {
    await db.update(
      vaultUserTable,
      vaultUser.toMap(),
      where:
          "$columnVaultUserVaultId = '${vaultUser.vaultId}' AND $columnVaultUserUserId = '${vaultUser.userId}'",
    );
  }

  static Future<void> save(VaultUser vaultUser) async {
    await db.insert(
      vaultUserTable,
      vaultUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> exists(VaultUser vaultUser) async {
    var data = await db.query(
      vaultUserTable,
      where:
          "$columnVaultUserVaultId = '${vaultUser.vaultId}' AND $columnVaultUserUserId = '${vaultUser.userId}'",
    );

    return data.isNotEmpty;
  }

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

  static Future<void> delete(String vaultId, String userId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $vaultUserTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnVaultUserVaultId = '$vaultId' AND $columnVaultUserUserId = '$userId'
    """);
  }

  static Future<void> deleteFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $vaultUserTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnVaultUserVaultId = '$vaultId'
    """);
  }
}

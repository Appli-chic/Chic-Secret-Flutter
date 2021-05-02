import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class VaultService {
  /// Update a [vault] into the local database
  static Future<void> update(Vault vault) async {
    await db.update(
      vaultTable,
      vault.toMap(),
      where: "$columnId = '${vault.id}'",
    );
  }

  /// Save a [vault] into the local database
  static Future<void> save(Vault vault) async {
    await db.insert(
      vaultTable,
      vault.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all the vaults
  static Future<List<Vault>> getAll() async {
    List<Vault> vaults = [];
    List<Map<String, dynamic>> maps = await db.query(
      vaultTable,
      where: "$columnDeletedAt IS NULL"
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        vaults.add(Vault.fromMap(map));
      }
    }

    return vaults;
  }

  /// Get all the vaults to synchronize from the locale database to the server
  static Future<List<Vault>> getVaultsToSynchronize(DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      vaultTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return Vault.fromMap(maps[i]);
    });
  }
}

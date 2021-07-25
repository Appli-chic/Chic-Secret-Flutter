import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/model/database/vault_user.dart';
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

  /// Checks if the vault already exists
  static Future<bool> exists(Vault vault) async {
    var data = await db.query(
      vaultTable,
      where: "$columnId = '${vault.id}'",
    );

    return data.isNotEmpty;
  }

  /// Retrieve all the vaults
  static Future<List<Vault>> getAll() async {
    List<Vault> vaults = [];

    var query = """
    SELECT DISTINCT v.$columnId, v.$columnVaultName, v.$columnVaultSignature,
    v.$columnVaultUserId, v.$columnCreatedAt, v.$columnUpdatedAt, v.$columnDeletedAt,
    
    vu.$columnVaultUserVaultId as vu_$columnVaultUserVaultId, 
    vu.$columnVaultUserUserId as vu_$columnVaultUserUserId,
    vu.$columnCreatedAt as vu_$columnCreatedAt, 
    vu.$columnUpdatedAt as vu_$columnUpdatedAt, 
    vu.$columnDeletedAt as vu_$columnDeletedAt
    
    FROM $vaultTable as v
    LEFT JOIN $vaultUserTable as vu ON vu.$columnVaultUserVaultId = v.$columnId
    WHERE v.$columnDeletedAt IS NULL
    AND vu.$columnDeletedAt IS NULL
    
    ORDER BY v.$columnId, v.$columnCreatedAt
    """;

    var maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        var vault = Vault.fromMap(map);

        var vaultQueried = vaults.where((v) => v.id == vault.id).toList();
        if (vaultQueried.isEmpty) {
          if (map["vu_" + columnVaultUserVaultId] != null) {
            vault.vaultUsers.add(VaultUser.fromMap(map, prefix: "vu_"));
          }

          vaults.add(vault);
        } else {
          vaultQueried[0].vaultUsers.add(VaultUser.fromMap(map, prefix: "vu_"));
        }
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

import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/utils/database.dart';

class VaultService {
  /// Save a [vault] into the local database
  static Future<void> save(Vault vault) async {
    await db.insert(
      vaultTable,
      vault.toMap(),
    );
  }

  /// Retrieve all the vaults
  static Future<List<Vault>> getAll() async {
    List<Vault> vaults = [];
    List<Map<String, dynamic>> maps = await db.query(
      vaultTable,
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        vaults.add(Vault.fromMap(map));
      }
    }

    return vaults;
  }
}

import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String vaultTable = "vault";
const String columnVaultName = "name";
const String columnVaultSignature = "signature";

class Vault {
  String id;
  String name;
  String signature;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Vault({
    required this.id,
    required this.name,
    required this.signature,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a map of [data] into a vault
  factory Vault.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return Vault(
      id: data[columnId],
      name: data[columnVaultName],
      signature: data[columnVaultSignature],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  // Transform a vault into a map of data
  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (this.deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    return {
      columnId: id,
      columnVaultName: name,
      columnVaultSignature: signature,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}

import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String vaultTable = "vault";
const String columnVaultName = "name";
const String columnVaultSignature = "signature";
const String columnVaultUserId = "user_id";

class Vault {
  String id;
  String name;
  String signature;
  String? userId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  List<VaultUser> vaultUsers = [];

  Vault({
    required this.id,
    required this.name,
    required this.signature,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a json to a vault
  factory Vault.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return Vault(
      id: json['ID'],
      name: json['Name'],
      signature: json['Signature'],
      userId: json['UserID'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform a vault to a json
  Map<String, dynamic> toJson() {
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = id;
    data['Name'] = name;
    data['Signature'] = signature;
    data['UserID'] = userId;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

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
      userId: data[columnVaultUserId],
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
      columnVaultUserId: userId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}

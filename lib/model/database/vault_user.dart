import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String vaultUserTable = "vault_user";
const String columnVaultUserVaultId = "vault_id";
const String columnVaultUserUserId = "user_id";

class VaultUser {
  String vaultId;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  VaultUser({
    required this.vaultId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory VaultUser.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return VaultUser(
      vaultId: json['VaultID'],
      userId: json['UserID'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  Map<String, dynamic> toJson() {
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    final Map<String, dynamic> data = Map<String, dynamic>();
    data['VaultID'] = vaultId;
    data['UserID'] = userId;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

  factory VaultUser.fromMap(Map<String, dynamic> data, {String? prefix}) {
    var createdAtString = DateTime.parse(prefix != null
        ? data[prefix + columnCreatedAt]
        : data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(prefix != null
        ? data[prefix + columnUpdatedAt]
        : data[columnUpdatedAt]);
    var deletedAtString;

    var deletedDate =
        prefix != null ? data[prefix + columnDeletedAt] : data[columnDeletedAt];

    if (deletedDate != null) {
      deletedAtString = DateTime.parse(prefix != null
          ? data[prefix + columnDeletedAt]
          : data[columnDeletedAt]);
    }

    return VaultUser(
      vaultId: prefix != null
          ? data[prefix + columnVaultUserVaultId]
          : data[columnVaultUserVaultId],
      userId: prefix != null
          ? data[prefix + columnVaultUserUserId]
          : data[columnVaultUserUserId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (this.deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    return {
      columnVaultUserVaultId: vaultId,
      columnVaultUserUserId: userId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}

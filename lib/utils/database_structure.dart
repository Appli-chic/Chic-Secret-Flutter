import 'package:chic_secret/model/database/vault.dart';

const String columnId = "id";
const String columnCreatedAt = "created_at";
const String columnUpdatedAt = "updated_at";
const String columnDeletedAt = "deleted_at";

const String CREATE_VAULT_TABLE = '''
CREATE TABLE $vaultTable(
$columnId TEXT PRIMARY KEY, 
$columnVaultName TEXT, 
$columnVaultSignature TEXT, 
$columnCreatedAt DATETIME, 
$columnUpdatedAt DATETIME, 
$columnDeletedAt DATETIME
)
''';
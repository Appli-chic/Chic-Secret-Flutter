import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/password.dart';
import 'package:chic_secret/model/database/vault.dart';

const String columnId = "id";
const String columnCreatedAt = "created_at";
const String columnUpdatedAt = "updated_at";
const String columnDeletedAt = "deleted_at";

const String createVaultTable = '''
CREATE TABLE $vaultTable(
$columnId TEXT PRIMARY KEY, 
$columnVaultName TEXT, 
$columnVaultSignature TEXT, 
$columnCreatedAt DATETIME, 
$columnUpdatedAt DATETIME, 
$columnDeletedAt DATETIME
)
''';

const String createCategoryTable = '''
CREATE TABLE $categoryTable(
$columnId TEXT PRIMARY KEY, 
$columnCategoryName TEXT, 
$columnCategoryColor TEXT, 
$columnCategoryIcon INTEGER, 
$columnCategoryVaultId TEXT, 
$columnCreatedAt DATETIME, 
$columnUpdatedAt DATETIME, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnCategoryVaultId) REFERENCES $vaultTable(id)
)
''';

const String createPasswordTable = '''
CREATE TABLE $passwordTable(
$columnId TEXT PRIMARY KEY, 
$columnPasswordName TEXT, 
$columnPasswordUsername TEXT, 
$columnPasswordHash TEXT, 
$columnPasswordVaultId TEXT, 
$columnPasswordCategoryId TEXT, 
$columnCreatedAt DATETIME, 
$columnUpdatedAt DATETIME, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnPasswordVaultId) REFERENCES $vaultTable(id)
FOREIGN KEY($columnPasswordCategoryId) REFERENCES $categoryTable(id)
)
''';
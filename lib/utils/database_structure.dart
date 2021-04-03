import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
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
CREATE TABLE $entryTable(
$columnId TEXT PRIMARY KEY, 
$columnEntryName TEXT, 
$columnEntryUsername TEXT, 
$columnEntryHash TEXT, 
$columnEntryVaultId TEXT, 
$columnEntryCategoryId TEXT, 
$columnCreatedAt DATETIME, 
$columnUpdatedAt DATETIME, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnEntryVaultId) REFERENCES $vaultTable(id)
FOREIGN KEY($columnEntryCategoryId) REFERENCES $categoryTable(id)
)
''';
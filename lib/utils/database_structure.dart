import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';

const String columnId = "id";
const String columnCreatedAt = "created_at";
const String columnUpdatedAt = "updated_at";
const String columnDeletedAt = "deleted_at";

const String createVaultTable = '''
CREATE TABLE $vaultTable(
$columnId TEXT PRIMARY KEY NOT NULL, 
$columnVaultName TEXT NOT NULL, 
$columnVaultSignature TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME
)
''';

const String createCategoryTable = '''
CREATE TABLE $categoryTable(
$columnId TEXT PRIMARY KEY NOT NULL, 
$columnCategoryName TEXT NOT NULL, 
$columnCategoryColor TEXT NOT NULL, 
$columnCategoryIcon INTEGER NOT NULL, 
$columnCategoryVaultId TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnCategoryVaultId) REFERENCES $vaultTable($columnId)
)
''';

const String createEntryTable = '''
CREATE TABLE $entryTable(
$columnId TEXT PRIMARY KEY NOT NULL, 
$columnEntryName TEXT NOT NULL, 
$columnEntryUsername TEXT NOT NULL, 
$columnEntryHash TEXT NOT NULL, 
$columnEntryComment TEXT, 
$columnEntryVaultId TEXT NOT NULL, 
$columnEntryCategoryId TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnEntryVaultId) REFERENCES $vaultTable($columnId)
FOREIGN KEY($columnEntryCategoryId) REFERENCES $categoryTable($columnId)
)
''';

const String createTagTable = '''
CREATE TABLE $tagTable(
$columnId TEXT PRIMARY KEY NOT NULL, 
$columnTagName TEXT NOT NULL, 
$columnTagVaultId TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnTagVaultId) REFERENCES $vaultTable($columnId)
)
''';

const String createEntryTagTable = '''
CREATE TABLE $entryTagTable(
$columnEntryTagEntryId TEXT NOT NULL, 
$columnEntryTagTagId TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnEntryTagEntryId) REFERENCES $entryTable($columnId)
FOREIGN KEY($columnEntryTagTagId) REFERENCES $tagTable($columnId)
PRIMARY KEY($columnEntryTagEntryId, $columnEntryTagTagId)
)
''';

const String createCustomFieldTable = '''
CREATE TABLE $customFieldTable(
$columnId TEXT PRIMARY KEY NOT NULL, 
$columnCustomFieldName TEXT NOT NULL,
$columnCustomFieldValue TEXT NOT NULL,  
$columnCustomFieldEntryId TEXT NOT NULL, 
$columnCreatedAt DATETIME NOT NULL, 
$columnUpdatedAt DATETIME NOT NULL, 
$columnDeletedAt DATETIME,
FOREIGN KEY($columnCustomFieldEntryId) REFERENCES $entryTable($columnId)
)
''';
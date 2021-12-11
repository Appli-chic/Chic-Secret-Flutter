import 'dart:ffi';
import 'dart:io';

import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/src/windows/setup_impl.dart';
import 'package:path/path.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as s3;
import 'package:path_provider/path_provider.dart' as path;

const int version = 5;
late Database db;

/// Init the local database for all the platforms
Future<void> initDatabase() async {
  if (Platform.isWindows) {
    var location = findPackagePath(Directory.current.path);
    if (location != null) {
      var path = normalize(join(location, 'src', 'windows', 'sqlite3.dll'));
      open.overrideFor(OperatingSystem.windows, () {
        try {
          return DynamicLibrary.open(path);
        } catch (e) {
          stderr.writeln('Failed to load sqlite3.dll at $path');
          rethrow;
        }
      });
    }
    s3.sqlite3.openInMemory().dispose();
    databaseFactory = databaseFactoryFfi;
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();

    var factoryDb = databaseFactoryFfi;
    final dbPath = await _getDatabasePath();
    db = await factoryDb.openDatabase(
      join(dbPath, databaseName),
      options: OpenDatabaseOptions(
        version: version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  } else {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);

    db = await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
}

/// Get the database path
Future<String> _getDatabasePath() async {
  if (Platform.isWindows) {
    var ref = await path.getApplicationSupportDirectory();
    return ref.path;
  } else {
    var dbPath = await getDatabasesPath();
    return dbPath;
  }
}

/// Execute scripts to upgrade the database
_onUpgrade(Database db, int oldVersion, int newVersion) async {
  var batch = db.batch();

  if (oldVersion <= 1) {
    batch.execute(createUserTable);
  } else if (oldVersion <= 2) {
    batch.execute(
        "ALTER TABLE $entryTable ADD $columnEntryPasswordSize INTEGER");
    batch.execute(
        "ALTER TABLE $entryTable ADD $columnEntryHashUpdatedAt DATETIME");
  } else if (oldVersion <= 3) {
    batch.execute("ALTER TABLE $userTable ADD $columnUserIsSubscribed INTEGER");
    batch.execute("ALTER TABLE $userTable ADD $columnUserSubscription TEXT");
    batch.execute(
        "ALTER TABLE $userTable ADD $columnUserSubscriptionStartDate DATETIME");
    batch.execute(
        "ALTER TABLE $userTable ADD $columnUserSubscriptionEndDate DATETIME");
  } else if (oldVersion <= 4) {
    batch.execute(createVaultUserTable);
  }

  await batch.commit();
}

/// Execute the scripts to create the database structure
_onCreate(Database db, int version) async {
  var batch = db.batch();
  batch.execute(createUserTable);
  batch.execute(createVaultTable);
  batch.execute(createCategoryTable);
  batch.execute(createEntryTable);
  batch.execute(createTagTable);
  batch.execute(createEntryTagTable);
  batch.execute(createCustomFieldTable);
  batch.execute(createVaultUserTable);
  await batch.commit();
}

bool transformIntToBool(int value) {
  return value == 1 ? true : false;
}

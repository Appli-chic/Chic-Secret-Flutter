import 'dart:io';

import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';

const int version = 1;
late Database db;

Future<void> initDatabase() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();

    var factoryDb = databaseFactoryFfi;
    db = await factoryDb.openDatabase(
      databaseName,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: _onCreate,
      ),
    );
  } else {
    var databasesPath = await getDatabasesPath();
    if (databasesPath != null) {
      String path = join(databasesPath, databaseName);

      db = await openDatabase(
        path,
        version: version,
        onCreate: _onCreate,
      );
    } else {
      throw Error();
    }
  }
}

_onCreate(db, version) async {
  var batch = db.batch();
  batch.execute(CREATE_VAULT_TABLE);
  await batch.commit();
}
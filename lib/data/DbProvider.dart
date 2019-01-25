import 'dart:async';
import 'dart:io';
import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  DbProvider._();

  static final DbProvider db = DbProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mfa_authenticator.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("""CREATE TABLE ${OtpItemDataMapper.otpItemTableName} (
            id INTEGER PRIMARY KEY,
            secret TEXT,
            issuer TEXT,
            account TEXT,
            time_based BOOL,
            length INTEGER,
            created_at DATE DEFAULT (datetime('now'))
          )""");
    });
  }
}

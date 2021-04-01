import 'package:chic_secret/model/database/password.dart';
import 'package:chic_secret/utils/database.dart';

class PasswordService {
  static Future<Password> save(Password password) async {
    await db.insert(
      passwordTable,
      password.toMap(),
    );

    return password;
  }
}
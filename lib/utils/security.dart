import 'package:chic_secret/utils/constant.dart';
import 'package:encrypt/encrypt.dart';

class Security {
  static String encrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(key)));
    var encrypted = encrypter.encrypt(message, iv: IV.fromUtf8(iv));
    return encrypted.base64;
  }

  static String decrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(key)));
    var encrypted = Encrypted.from64(message);
    return encrypter.decrypt(encrypted, iv: IV.fromUtf8(iv));
  }
}

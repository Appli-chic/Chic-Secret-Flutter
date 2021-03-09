import 'package:chic_secret/utils/constant.dart';
import 'package:encrypt/encrypt.dart';

class Security {
  static String encrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = encrypter.encrypt(message, iv: IV.fromUtf8(key));
    return encrypted.base64;
  }

  static String decrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = Encrypted.fromBase64(message);
    return encrypter.decrypt(encrypted, iv: IV.fromUtf8(key));
  }
}

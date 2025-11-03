import 'package:encrypt/encrypt.dart';

class EncryptUtils {
  static final key = Key.fromLength(32);
  static final iv = IV.fromLength(8);
  static final encrypter = Encrypter(Salsa20(key));

  static String encryptText(String plainText) {
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedBase64) {
    final encrypted = Encrypted.fromBase64(encryptedBase64);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

import 'package:encrypt/encrypt.dart';

class Cypherer {
  static String encryptText(String decryptedText, String secretKey, String secretIv) {
    final Key key = Key.fromBase64(secretKey);
    final IV iv = IV.fromUtf8(secretIv);

    final Encrypter encrypter = Encrypter(AES(key));
    final Encrypted encrypted = encrypter.encrypt(decryptedText, iv: iv);

    return encrypted.base64;
  }

  static String decryptText(String encryptedText, String secretKey, String secretIv) {
    final Key key = Key.fromBase64(secretKey);
    final IV iv = IV.fromUtf8(secretIv);

    final Encrypter encrypter = Encrypter(AES(key));
    final String dectypted = encrypter.decrypt64(encryptedText, iv: iv);

    return dectypted;
  }
}
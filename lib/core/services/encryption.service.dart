import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static const int _keyLength = 32;    // AES-256
  static const int _iterations = 10000;

  /// Generate random salt (recommended length: 16 bytes)
  String generateRandomSalt([int length = 16]) {
    final rand = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  /// Derive key from password + salt using PBKDF2
  Key _deriveKey(String password, String salt) {
    final keyBytes = pbkdf2(
      password: utf8.encode(password),
      salt: utf8.encode(salt),
      iterations: _iterations,
      keyLength: _keyLength,
    );
    return Key(keyBytes);
  }

  Uint8List pbkdf2({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    var block = List<int>.from(salt)..addAll([0, 0, 0, 1]);
    var last = hmac.convert(block).bytes;
    var output = last;

    for (var i = 1; i < iterations; i++) {
      last = hmac.convert(last).bytes;
      for (var j = 0; j < output.length; j++) {
        output[j] ^= last[j];
      }
    }

    return Uint8List.fromList(output.sublist(0, keyLength));
  }

  /// Encrypt plaintext with password
  Map<String, String> encrypt(String plaintext, String password) {
    final salt = generateRandomSalt();
    final key = _deriveKey(password, salt);
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return {
      'cipherText': encrypted.base64,
      'salt': salt,
      'iv': iv.base64,
    };
  }

  /// Decrypt ciphertext with password, salt, and iv
  String decrypt(String cipherText, String password, String salt, String ivBase64) {
    final key = _deriveKey(password, salt);
    final iv = IV.fromBase64(ivBase64);
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(cipherText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/key.model.dart';
import 'package:performance_tracker/repositories/key.repository.dart';

class KeyService {
  final _keyRepo = locator<KeyRepository>();
  final aiKeyname = "AI";

  Future<String?> getAiApiKey() async {
    var encryptedKey = this._keyRepo.getKeyByName(aiKeyname)?.keyVal ?? '';
    var decrypted = await this.decryptValue(encryptedKey);
    return decrypted;
  }

  addAiApiKey(String keyVal) async {
    var encryptedKey = await _encryptValue(keyVal);
    var key = SecretAppKey(keyName: aiKeyname, keyVal: encryptedKey);
    this._keyRepo.addKey(key);
  }

  removeAiApiKey() {
    var key = _keyRepo.getKeyByName(aiKeyname);
    key != null && _keyRepo.removeKey(key);
  }

  final _secureStorage = FlutterSecureStorage();

  Future<String> _getOrCreateEncryptionKey() async {
    const keyName = 'KeyEncryptionSecret';

    var key = await _secureStorage.read(key: keyName);
    if (key != null) return key;

    final newKey = base64Encode(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );

    await _secureStorage.write(key: keyName, value: newKey);

    return newKey;
  }

  Future<String> _encryptValue(String plainText) async {
    final keyString = await _getOrCreateEncryptionKey();
    final key = Key.fromBase64(keyString);
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Store IV + ciphertext together
    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decryptValue(String cipherText) async {
    try {
      
    final keyString = await _getOrCreateEncryptionKey();
    final parts = cipherText.split(':');

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);

    final key = Key.fromBase64(keyString);
    final encrypter = Encrypter(AES(key));

    return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return '';
    }
  }
}

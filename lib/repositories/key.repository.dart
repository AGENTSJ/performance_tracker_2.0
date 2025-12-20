import 'package:hive_flutter/hive_flutter.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/models/key.model.dart';

class KeyRepository {
  final Box<SecretAppKey> _keyBox = Hive.box<SecretAppKey>(Collections.key.value);

  SecretAppKey? getKeyByName(String keyName) {
    try {
      return this._keyBox.values.firstWhere((k) => k.keyName == keyName);
    } catch (e) {
      return null;
    }
  }

  bool removeKey(SecretAppKey key) {
    try {
      key.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> addKey(SecretAppKey key) async {
    for(var exKey in _keyBox.values)
    {
      if(exKey.keyName == key.keyName)
      {
        exKey.delete();
      }
    }
    await _keyBox.add(key);
  }
}

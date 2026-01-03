import 'package:hive/hive.dart';

part 'key.model.g.dart';

@HiveType(typeId: 34) // ensure this typeId is unique in your project
class SecretAppKey extends HiveObject {
  @HiveField(0)
  String keyName;

  @HiveField(1)
  String keyVal;

  SecretAppKey({
    required this.keyName,
    required this.keyVal,
  });
}

import 'package:hive/hive.dart';

part 'credential.g.dart';

@HiveType(typeId: 0)
class Credential extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  String? note;

  Credential({
    required this.title,
    required this.username,
    required this.password,
    this.note,
  });
}

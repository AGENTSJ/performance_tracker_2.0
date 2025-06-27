import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/modules/nutritionModule/models/user.model.dart';

class UserRepository {
  final _userBox = Hive.box<User>(Collections.users.value);
  final userId = 1;

  Future<User?> getUser({int userId =1}) async
  {
    try
    {
      var user = _userBox.values.firstWhere(
        (u) => u.id == userId,
      );
      return user;
    }
    catch (e)
    {
      return null;
    }
  }

  updateUser(User user) async 
  {
    await _userBox.put(user.key, user);
  }

  addUser(User user) async
  {
    await _userBox.add(user);
  }
}
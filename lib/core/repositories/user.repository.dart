import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/core/models/user.model.dart';

class UserRepository {
  final _userBox = Hive.box<User>(Collections.users.value);
  final userId = 1;

  Future<User?> getUser({int userId =1}) async
  {
    var users = _userBox.values.toList();
    if(users.isEmpty)
    {
      return null;
    }
    return users[0];
  }

  updateUser(User user) async 
  {
    await _userBox.put(user.key, user);
  }

  Future<User>addUser(User user) async
  {
    int key = await _userBox.add(user);
    var newUser = await getUser(userId: key);
    return newUser!;
  }

  List<User> getAllUser()
  {
    return _userBox.values.toList();
  }
  clearAllUser()async
  {
    await _userBox.clear();
  }
}
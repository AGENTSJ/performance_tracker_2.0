import "package:performance_tracker/DI.dart";
import "package:performance_tracker/models/user.model.dart";
import "package:performance_tracker/repositories/user.repository.dart";

class UserService {
  final _userRepo = locator<UserRepository>();

  Future<User> getUserData() async {
    var user = await _userRepo.getUser();
    if (user == null) {
      user = User(
        id: 1,
        name: 'User 101',
        age: 22,
        gender: Gender.male,
        height: 173,
        weight: 71,
        activityLevel: ActivityLevel.moderatelyActive,
        userGoals: UserGoals(calorieLimit: 1800, stepGoal: 5000,targetWeight: 71,caloricChangeGoal: 200),
        createdAt: DateTime.now()
      );
      await _userRepo.addUser(user);
    }
    return user;
  }

  updateUser(User user) {
    return _userRepo.updateUser(user);
  }

  List<User> getAllUser()
  {
    return _userRepo.getAllUser();
  }

  Future<User> addUser(User user)
  {
    return _userRepo.addUser(user);
  }
}

import "package:performance_tracker/DI.dart";
import "package:performance_tracker/modules/nutritionModule/models/user.model.dart";
import "package:performance_tracker/modules/sharedModule/repositories/user.repository.dart";



class UserService {

  final  _userRepo = locator<UserRepository>();

  Future<User?>getUserData() async
  {
    var user = await  _userRepo.getUser();
    if(user== null)
    {
      user = User(id: 1, name: 'Abhijith SJ', age: 22, gender: Gender.male, height: 173, weight: 71, activityLevel: ActivityLevel.moderatelyActive,userGoals: UserGoals(calorieLimit: 1800, stepGoal: 5000));
      await _userRepo.addUser(user);
    }
    return user;
  }

  updateUser(User user)
  {
    return _userRepo.updateUser(user);
  }
}
import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
  Future<void> updateProfile(UserProfile profile);
  Stream<UserProfile?> watchProfile(String userId);
}

import 'package:mobile/repositories/auth_repository.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/profile_response.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  Future<User> login(String email, String password) async {
    final response = await _authRepository.login(email, password);
    return response['user'] as User;
  }

  Future<User> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _authRepository.register(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      passwordConfirmation: password,
      phone: phone,
    );
    return response['user'] as User;
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  Future<ProfileData> getProfile() async => _authRepository.getProfile();

  Future<Map<String, dynamic>> getTransactions({int page = 1, int perPage = 15}) async =>
      _authRepository.getTransactions(page: page, perPage: perPage);

  Future<Uri> topupBalance({required double amount, String? successUrl, String? failUrl}) async =>
      _authRepository.topupBalance(amount: amount, successUrl: successUrl, failUrl: failUrl);

  Future<Map<String, dynamic>> getFavorites() async => _authRepository.getFavorites();

  Future<Map<String, dynamic>> getClubs({int page = 1, int perPage = 15, String? search, String? status, String? sort, String? order}) async =>
      _authRepository.getClubs(page: page, perPage: perPage, search: search, status: status, sort: sort, order: order);

  Future<Map<String, dynamic>> getClub(String slug) async => _authRepository.getClub(slug);

  Future<Map<String, dynamic>> donateToClub(String slug, double amount) async => _authRepository.donateToClub(slug, amount);

  Future<Map<String, dynamic>> donateToCourse(String slug, double amount) async => _authRepository.donateToCourse(slug, amount);

  Future<Map<String, dynamic>> getCourses({int page = 1, int perPage = 15, String? search, int? categoryId, String? status, String? sort, String? order}) async =>
      _authRepository.getCourses(page: page, perPage: perPage, search: search, categoryId: categoryId, status: status, sort: sort, order: order);

  Future<Map<String, dynamic>> getCourse(String slug) async => _authRepository.getCourse(slug);

  Future<Map<String, dynamic>> toggleFavorite({required int favorableId, required String favorableType}) async =>
      _authRepository.toggleFavorite(favorableId: favorableId, favorableType: favorableType);

}

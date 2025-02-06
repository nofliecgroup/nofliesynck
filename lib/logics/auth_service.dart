import 'package:appwrite/appwrite.dart';
import 'package:nofliesynck/auths/auth_helpers/service_tiers.dart';

class AuthService {
  final Client client;
  final Account account;
  final Databases databases;

  AuthService() :
        client = Client()
            .setEndpoint('https://cloud.appwrite.io/v1')
            .setProject('679cacab003e3885bc26'),
        account = Account(Client()),
        databases = Databases(Client());

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create user profile with subscription details
      await databases.createDocument(
        databaseId: 'users',
        collectionId: 'profiles',
        documentId: ID.unique(),
        data: {
          'userId': user.$id,
          'name': name,
          'email': email,
          'serviceTier': ServiceTier.trial.toString(),
          'trialStartDate': DateTime.now().toIso8601String(),
          'trialEndDate': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
          'isTrialExpired': false,
          'isPremium': false,
          'lastLoginDate': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login user
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Update last login date and check trial/premium status
      final userProfile = await getUserProfile(session.userId);
      await updateLoginStatus(userProfile);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final documents = await databases.listDocuments(
        databaseId: 'users',
        collectionId: 'profiles',
        queries: [
          Query.equal('userId', userId),
        ],
      );

      if (documents.documents.isEmpty) {
        throw Exception('User profile not found');
      }

      return documents.documents.first.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLoginStatus(Map<String, dynamic> profile) async {
    final now = DateTime.now();
    final trialEndDate = DateTime.parse(profile['trialEndDate']);

    // Check if trial has expired
    final isTrialExpired = now.isAfter(trialEndDate) &&
        profile['serviceTier'] == ServiceTier.trial.toString();

    await databases.updateDocument(
      databaseId: 'users',
      collectionId: 'profiles',
      documentId: profile['\$id'],
      data: {
        'lastLoginDate': now.toIso8601String(),
        'isTrialExpired': isTrialExpired,
        'serviceTier': isTrialExpired ? ServiceTier.free.toString() : profile['serviceTier'],
      },
    );
  }

  Future<bool> canAccessPremiumService(String userId) async {
    final profile = await getUserProfile(userId);
    final now = DateTime.now();

    if (profile['isPremium']) return true;

    if (profile['serviceTier'] == ServiceTier.trial.toString()) {
      final trialEndDate = DateTime.parse(profile['trialEndDate']);
      return now.isBefore(trialEndDate);
    }

    return false;
  }

  Future<void> upgradeToPremium(String userId) async {
    // Implement your payment processing logic here

    await databases.updateDocument(
      databaseId: 'users',
      collectionId: 'profiles',
      documentId: userId,
      data: {
        'serviceTier': ServiceTier.premium.toString(),
        'isPremium': true,
        'isTrialExpired': false,
      },
    );
  }
}
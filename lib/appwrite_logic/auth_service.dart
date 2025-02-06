import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:nofliesynck/appwrite_logic/appwrite_global_service.dart';
import 'package:nofliesynck/appwrite_logic/trial_appwrite_service.dart';
import 'package:nofliesynck/logger_info/app_logger.dart';

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  final Account _account = AppwriteGlobalService.account;
  final TrialAppwriteService _trialService = TrialAppwriteService();

  // Registration
  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      AppLogger.logInfo('Attempting to register user: $email');

      // Create user account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Send verification email
      await _account.createVerification(
        url: 'https://yourdomain.com/verify-email', // Replace with your verification URL
      );

      // Initialize trial for the new user
      await _trialService.createUserTrial(user.$id);

      AppLogger.logInfo('User registered successfully: ${user.$id}');

      return AuthResponse(
        success: true,
        message: 'Registration successful. Please check your email for verification.',
        data: {
          'userId': user.$id,
          'email': user.email,
          'name': user.name,
          'emailVerified': false,
        },
      );
    } on AppwriteException catch (e) {
      AppLogger.logError('Registration failed: ${e.message}');
      return AuthResponse(
        success: false,
        message: _getReadableErrorMessage(e.type ?? e.message ?? 'Registration failed'),
      );
    } catch (e) {
      AppLogger.logError('Unexpected error during registration: $e');
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred during registration.',
      );
    }
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.logInfo('Attempting login for user: $email');

      // Create email session
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Get user details
      final user = await _account.get();

      // Verify email status
      if (!user.emailVerification) {
        AppLogger.logWarn('Unverified email login attempt: $email');
        return AuthResponse(
          success: false,
          message: 'Please verify your email before logging in.',
        );
      }

      // Verify trial status
      final deviceInfo = await _getDeviceInfo();
      final trialStatus = await _trialService.verifyTrialStatus(
        user.$id,
        deviceInfo['device_id']!,
      );

      AppLogger.logInfo('Login successful: ${user.$id}');

      return AuthResponse(
        success: true,
        message: 'Login successful',
        data: {
          'userId': user.$id,
          'email': user.email,
          'name': user.name,
          'sessionId': session.$id,
          'trial': trialStatus,
        },
      );
    } on AppwriteException catch (e) {
      AppLogger.logError('Login failed: ${e.message}');
      return AuthResponse(
        success: false,
        message: _getReadableErrorMessage(e.type ?? e.message ?? 'Login failed'),
      );
    } catch (e) {
      AppLogger.logError('Unexpected error during login: $e');
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred during login.',
      );
    }
  }

  // Email Verification
  Future<AuthResponse> verifyEmail(String userId, String secret) async {
    try {
      AppLogger.logInfo('Attempting to verify email for user: $userId');

      await _account.updateVerification(
        userId: userId,
        secret: secret,
      );

      AppLogger.logInfo('Email verified successfully for user: $userId');

      return AuthResponse(
        success: true,
        message: 'Email verified successfully.',
      );
    } on AppwriteException catch (e) {
      AppLogger.logError('Email verification failed: ${e.message}');
      return AuthResponse(
        success: false,
        message: _getReadableErrorMessage(e.type ?? e.message ?? 'Verification failed'),
      );
    }
  }

  // Password Reset
  Future<AuthResponse> requestPasswordReset(String email) async {
    try {
      AppLogger.logInfo('Requesting password reset for: $email');

      await _account.createRecovery(
        email: email,
        url: 'https://yourdomain.com/reset-password', // Replace with your reset password URL
      );

      return AuthResponse(
        success: true,
        message: 'Password reset instructions have been sent to your email.',
      );
    } on AppwriteException catch (e) {
      AppLogger.logError('Password reset request failed: ${e.message}');
      return AuthResponse(
        success: false,
        message: _getReadableErrorMessage(e.type ?? e.message ?? 'Reset request failed'),
      );
    }
  }

  // Logout
  Future<AuthResponse> logout() async {
    try {
      AppLogger.logInfo('Attempting to logout current session');

      await _account.deleteSession(sessionId: 'current');

      AppLogger.logInfo('Logout successful');

      return AuthResponse(
        success: true,
        message: 'Logged out successfully',
      );
    } on AppwriteException catch (e) {
      AppLogger.logError('Logout failed: ${e.message}');
      return AuthResponse(
        success: false,
        message: _getReadableErrorMessage(e.type ?? e.message ?? 'Logout failed'),
      );
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      AppLogger.logError('Failed to get current user: ${e.message}');
      return null;
    }
  }

  // Helper method to get device info
  Future<Map<String, String>> _getDeviceInfo() async {
    // Implement device info collection logic here
    // You'll need to use package:device_info_plus
    return {
      'device_id': 'unique_device_id',
      'device_name': 'device_name',
      'platform': 'platform',
    };
  }

  // Helper method to convert Appwrite error messages to user-friendly messages
  String _getReadableErrorMessage(String error) {
    switch (error.toLowerCase()) {
      case 'user_already_exists':
        return 'An account with this email already exists.';
      case 'invalid_credentials':
        return 'Invalid email or password.';
      case 'user_not_found':
        return 'No account found with this email.';
      case 'verification_already_sent':
        return 'A verification email was already sent. Please check your inbox.';
      case 'rate_limit_exceeded':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}


/* import 'package:appwrite/appwrite.dart';
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

  Future<void> logout() async {
    await account.deleteSession(sessionId: client.endPoint);
  }

}
 */

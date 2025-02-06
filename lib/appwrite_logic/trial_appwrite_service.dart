import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:nofliesynck/appwrite_logic/appwrite_global_service.dart';
import 'package:nofliesynck/logger_info/app_logger.dart';

class TrialAppwriteService {
  static final TrialAppwriteService _instance =
      TrialAppwriteService._internal();
  factory TrialAppwriteService() => _instance;

  TrialAppwriteService._internal();

  //static bool _initialized = false;

  static const String userTrialsCollection = AppwriteGlobalService.usersTrials;
  static const String trialDevicesCollection =
      AppwriteGlobalService.trialDevices;
  static const String trialVerificationLogsCollection =
      AppwriteGlobalService.trialVerificationLogs;
  static const String databaseId = AppwriteGlobalService.databaseId;

  // Enums for trial status
  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_EXPIRED = 'expired';
  static const String STATUS_CONVERTED = 'converted';

  Future<void> _ensureInitialized() async {
    try {
      await AppwriteGlobalService.init();
    } catch (e) {
      throw Exception("AppwriteService failed to initialize: $e");
    }
  }

  // User Trials Management
  Future<Document> createUserTrial(String userId) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Creating trial for user: $userId');
      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 14));

      final data = {
        'user_id': userId,
        'trial_start_date': now.toIso8601String(),
        'trial_end_date': trialEndDate.toIso8601String(),
        'is_trial_active': true,
        'trial_status': STATUS_ACTIVE,
        'last_verified_date': now.toIso8601String(),
      };

      final document = await AppwriteGlobalService.database.createDocument(
        databaseId: databaseId,
        collectionId: userTrialsCollection,
        documentId: ID.unique(),
        data: data,
      );

      AppLogger.logInfo('Trial created successfully for user: $userId');
      return document;
    } catch (e) {
      AppLogger.logError('Error creating trial: $e');
      rethrow;
    }
  }

  Future<Document?> getUserTrial(String userId) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Fetching trial for user: $userId');
      final response = await AppwriteGlobalService.database.listDocuments(
        databaseId: databaseId,
        collectionId: userTrialsCollection,
        queries: [Query.equal('user_id', userId)],
      );

      if (response.documents.isEmpty) {
        AppLogger.logInfo('No trial found for user: $userId');
        return null;
      }

      AppLogger.logInfo('Trial found for user: $userId');
      return response.documents.first;
    } catch (e) {
      AppLogger.logError('Error getting user trial: $e');
      rethrow;
    }
  }

  // Adding the missing getUserDevices method
  Future<List<Document>> getUserDevices(String userId) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Getting devices for user: $userId');
      final response = await AppwriteGlobalService.database.listDocuments(
        databaseId: databaseId,
        collectionId: trialDevicesCollection,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('is_active', true),
        ],
      );

      return response.documents;
    } catch (e) {
      AppLogger.logError('Error getting user devices: $e');
      rethrow;
    }
  }

  // Adding the missing logVerification method
  Future<Document> logVerification(
      Map<String, dynamic> verificationData) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Logging verification: $verificationData');
      return await AppwriteGlobalService.database.createDocument(
        databaseId: databaseId,
        collectionId: trialVerificationLogsCollection,
        documentId: ID.unique(),
        data: {
          'user_id': verificationData['user_id'],
          'device_id': verificationData['device_id'],
          'verification_type': verificationData['verification_type'],
          'verification_status': verificationData['verification_status'],
          'client_timestamp': verificationData['client_timestamp'],
          'server_timestamp': DateTime.now().toIso8601String(),
          'time_difference_seconds':
              verificationData['time_difference_seconds'],
          'details': verificationData['details'],
        },
      );
    } catch (e) {
      AppLogger.logError('Error logging verification: $e');
      rethrow;
    }
  }

  Future<void> updateTrialStatus(String documentId, String status) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Updating trial status: $documentId to $status');

      if (![STATUS_ACTIVE, STATUS_EXPIRED, STATUS_CONVERTED].contains(status)) {
        throw ArgumentError('Invalid trial status: $status');
      }

      await AppwriteGlobalService.database.updateDocument(
        databaseId: databaseId,
        collectionId: userTrialsCollection,
        documentId: documentId,
        data: {
          'trial_status': status,
          'is_trial_active': status == STATUS_ACTIVE,
          'last_verified_date': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.logInfo('Trial status updated successfully');
    } catch (e) {
      AppLogger.logError('Error updating trial status: $e');
      rethrow;
    }
  }

  Future<Document> registerDevice(
      String userId, Map<String, dynamic> deviceInfo) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo('Registering device for user: $userId');

      // Validate required device info
      final requiredFields = ['device_id', 'device_name', 'platform'];
      for (final field in requiredFields) {
        if (!deviceInfo.containsKey(field) || deviceInfo[field] == null) {
          throw ArgumentError('Missing required device info: $field');
        }
      }

      final document = await AppwriteGlobalService.database.createDocument(
        databaseId: databaseId,
        collectionId: trialDevicesCollection,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'device_id': deviceInfo['device_id'],
          'device_name': deviceInfo['device_name'],
          'platform': deviceInfo['platform'],
          'last_access_date': DateTime.now().toIso8601String(),
          'is_active': true,
        },
      );

      AppLogger.logInfo('Device registered successfully');
      return document;
    } catch (e) {
      AppLogger.logError('Error registering device: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyTrialStatus(
      String userId, String deviceId) async {
    _ensureInitialized();

    try {
      AppLogger.logInfo(
          'Verifying trial status for user: $userId, device: $deviceId');

      final trial = await getUserTrial(userId);
      if (trial == null) {
        return _createVerificationResponse(false, 'No trial found');
      }

      // Verify device
      final devices = await getUserDevices(userId);
      final isDeviceRegistered = devices.any((device) =>
          device.data['device_id'] == deviceId &&
          device.data['is_active'] == true);

      if (!isDeviceRegistered) {
        return _createVerificationResponse(false, 'Unregistered device');
      }

      // Check trial expiration
      final now = DateTime.now();
      final trialEndDate = DateTime.parse(trial.data['trial_end_date']);

      if (now.isAfter(trialEndDate)) {
        await updateTrialStatus(trial.$id, STATUS_EXPIRED);
        return _createVerificationResponse(false, 'Trial expired');
      }

      // Log successful verification
      await _logVerificationAttempt(
          userId, deviceId, true, 'Trial verified successfully');

      return {
        'isValid': true,
        'message': 'Trial active',
        'daysRemaining': trialEndDate.difference(now).inDays,
        'trialEndDate': trialEndDate.toIso8601String(),
        'status': trial.data['trial_status'],
      };
    } catch (e) {
      AppLogger.logError('Error verifying trial status: $e');
      await _logVerificationAttempt(userId, deviceId, false, e.toString());
      rethrow;
    }
  }

  Map<String, dynamic> _createVerificationResponse(
      bool isValid, String message) {
    return {
      'isValid': isValid,
      'message': message,
      'daysRemaining': isValid ? null : 0,
    };
  }

  Future<void> _logVerificationAttempt(
      String userId, String deviceId, bool success, String details) async {
    try {
      final now = DateTime.now();
      await logVerification({
        'user_id': userId,
        'device_id': deviceId,
        'verification_type': 'trial_status',
        'verification_status': success ? 'success' : 'failed',
        'client_timestamp': now.toIso8601String(),
        'time_difference_seconds': 0,
        'details': details,
      });
    } catch (e) {
      AppLogger.logError('Error logging verification attempt: $e');
    }
  }
}

/* import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:nofliesynck/appwrite_logic/appwrite_global_service.dart';
import 'package:nofliesynck/logger_info/app_logger.dart';

class TrialAppwriteService {

  static const String userTrialsCollection = AppwriteGlobalService.usersTrials;
  static const String trialDevicesCollection =
      AppwriteGlobalService.trialDevices;
  static const String trialVerificationLogsCollection =
      AppwriteGlobalService.trialVerificationLogs;

  final Database = AppwriteGlobalService.database;
  final String databaseId = AppwriteGlobalService.databaseId;


  // User Trials Management
  Future<Document> createUserTrial(String userId) async {
    AppLogger.logInfo('Creating trial for user: $userId');
    final now = DateTime.now();
    final trialEndDate = now.add(const Duration(days: 14));

    return await AppwriteGlobalService.database.createDocument(
      databaseId: databaseId,
      collectionId: userTrialsCollection,
      documentId: ID.unique(),
      data: {
        'user_id': userId,
        'trial_start_date': now.toIso8601String(),
        'trial_end_date': trialEndDate.toIso8601String(),
        'is_trial_active': true,
        'trial_status': 'active',
        'last_verified_date': now.toIso8601String(),
      },
    );

  }

  Future<Document?> getUserTrial(String userId) async {
    try {
      final response = await AppwriteGlobalService.database.listDocuments(
        databaseId: databaseId,
        collectionId: userTrialsCollection,
        queries: [
          Query.equal('user_id', userId),
        ],
      );

      if (response.documents.isEmpty) return null;
      return response.documents.first;
    } catch (e) {
      AppLogger.logError('Error getting user trial: $e');
      //print('Error getting user trial: $e');
      return null;
    }
  }

  Future<void> updateTrialStatus(String documentId, String status) async {
    await AppwriteGlobalService.database.updateDocument(
      databaseId: databaseId,
      collectionId: userTrialsCollection,
      documentId: documentId,
      data: {
        'trial_status': status,
        'is_trial_active': status == 'active',
        'last_verified_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // Device Management
  Future<Document> registerDevice(
      String userId, Map<String, dynamic> deviceInfo) async {
        AppLogger.logInfo('Registering device for user: $userId');
    return await AppwriteGlobalService.database.createDocument(
      databaseId: databaseId,
      collectionId: trialDevicesCollection,
      documentId: ID.unique(),
      data: {
        'user_id': userId,
        'device_id': deviceInfo['device_id'],
        'device_name': deviceInfo['device_name'],
        'platform': deviceInfo['platform'],
        'last_access_date': DateTime.now().toIso8601String(),
        'is_active': true,
      },
    );
  }

  Future<List<Document>> getUserDevices(String userId) async {
    AppLogger.logInfo('Getting devices for user: $userId');
    final response = await AppwriteGlobalService.database.listDocuments(
      databaseId: databaseId,
      collectionId: trialDevicesCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.equal('is_active', true),
      ],
    );

    return response.documents;
  }

  // Verification Logging
  Future<Document> logVerification(
      Map<String, dynamic> verificationData) async {
        AppLogger.logInfo('Logging verification: $verificationData');
    return await AppwriteGlobalService.database.createDocument(
      databaseId: databaseId,
      collectionId: trialVerificationLogsCollection,
      documentId: ID.unique(),
      data: {
        'user_id': verificationData['user_id'],
        'device_id': verificationData['device_id'],
        'verification_type': verificationData['verification_type'],
        'verification_status': verificationData['verification_status'],
        'client_timestamp': verificationData['client_timestamp'],
        'server_timestamp': DateTime.now().toIso8601String(),
        'time_difference_seconds': verificationData['time_difference_seconds'],
        'details': verificationData['details'],
      },
    );
  }

  Future<List<Document>> getVerificationLogs(
    String userId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<String> queries = [Query.equal('user_id', userId)];

    if (status != null) {
      queries.add(Query.equal('verification_status', status));
    }

    if (startDate != null) {
      queries.add(Query.greaterThanEqual(
          'server_timestamp', startDate.toIso8601String()));
    }

    if (endDate != null) {
      queries.add(
          Query.lessThanEqual('server_timestamp', endDate.toIso8601String()));
    }

    final response = await AppwriteGlobalService.database.listDocuments(
      databaseId: databaseId,
      collectionId: trialVerificationLogsCollection,
      queries: queries,
    );

    AppLogger.logInfo('Verification logs: ${response.documents}');
    return response.documents;

  }

  // Trial Status Verification
  Future<Map<String, dynamic>> verifyTrialStatus(
      String userId, String deviceId) async {
        AppLogger.logInfo('Verifying trial status for user: $userId');
    final trial = await getUserTrial(userId);
    if (trial == null) {
      return {
        'isValid': false,
        'message': 'No trial found',
      };
    }

    final devices = await getUserDevices(userId);
    final isDeviceRegistered = devices.any((device) =>
        device.data['device_id'] == deviceId &&
        device.data['is_active'] == true);

    if (!isDeviceRegistered) {
      return {
        'isValid': false,
        'message': 'Unregistered device',
      };
    }

    final now = DateTime.now();
    final trialEndDate = DateTime.parse(trial.data['trial_end_date']);

    if (now.isAfter(trialEndDate)) {
      await updateTrialStatus(trial.$id, 'expired');
      return {
        'isValid': false,
        'message': 'Trial expired',
      };
    }

    return {
      'isValid': true,
      'message': 'Trial active',
      'daysRemaining': trialEndDate.difference(now).inDays,
    };
  }
}
 */

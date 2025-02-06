import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class TrialService {
  static const int trialDurationDays = 14;
  static const String _keyTrialStart = 'trial_start_time';
  static const String _keyDeviceId = 'device_id';
  static const String _keyFirstLogin = 'first_login';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Singleton pattern
  static final TrialService _instance = TrialService._internal();
  factory TrialService() => _instance;
  TrialService._internal();

  Future<void> initializeTrial(String userId) async {
    final isFirstLogin = await _isFirstLogin();
    if (isFirstLogin) {
      await _startTrial(userId);
    }
    await _verifyDeviceIntegrity();
  }

  Future<bool> _isFirstLogin() async {
    final firstLogin = await _secureStorage.read(key: _keyFirstLogin);
    if (firstLogin == null) {
      await _secureStorage.write(key: _keyFirstLogin, value: 'true');
      return true;
    }
    return false;
  }

  Future<void> _startTrial(String userId) async {
    final currentTime = await _getVerifiedTime();
    final trialData = {
      'startTime': currentTime.millisecondsSinceEpoch,
      'userId': userId,
      'deviceId': await _getDeviceIdentifier(),
      'appVersion': await _getAppVersion(),
    };

    await _secureStorage.write(
      key: _keyTrialStart,
      value: jsonEncode(trialData),
    );
  }

  Future<bool> isTrialValid() async {
    try {
      final trialData = await _getTrialData();
      if (trialData == null) return false;

      final startTime = DateTime.fromMillisecondsSinceEpoch(trialData['startTime']);
      final currentTime = await _getVerifiedTime();

      // Check for time manipulation
      if (currentTime.isBefore(startTime)) {
        await _handleTimeManipulation();
        return false;
      }

      final difference = currentTime.difference(startTime).inDays;
      return difference <= trialDurationDays;
    } catch (e) {
      print('Error checking trial validity: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getTrialData() async {
    final trialDataStr = await _secureStorage.read(key: _keyTrialStart);
    if (trialDataStr == null) return null;
    return jsonDecode(trialDataStr);
  }

  Future<DateTime> _getVerifiedTime() async {
    try {
      final response = await http.head(Uri.parse('https://google.com'));
      final serverDate = response.headers['date'];
      if (serverDate != null) {
        return HttpDate.parse(serverDate);
      }
    } catch (e) {
      print('Error getting network time: $e');
    }
    return DateTime.now(); // Fallback to device time
  }

  Future<String> _getDeviceIdentifier() async {
    String? deviceId = await _secureStorage.read(key: _keyDeviceId);

    if (deviceId == null) {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }

      if (deviceId != null) {
        await _secureStorage.write(key: _keyDeviceId, value: deviceId);
      }
    }

    return deviceId ?? 'unknown_device';
  }

  Future<void> _verifyDeviceIntegrity() async {
    final trialData = await _getTrialData();
    if (trialData == null) return;

    final currentDeviceId = await _getDeviceIdentifier();
    if (trialData['deviceId'] != currentDeviceId) {
      await _handleDeviceChange();
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _handleTimeManipulation() async {
    // Invalidate trial and notify server
    await _secureStorage.delete(key: _keyTrialStart);
    // You can add server notification logic here
  }

  Future<void> _handleDeviceChange() async {
    // Invalidate trial on device change
    await _secureStorage.delete(key: _keyTrialStart);
    // You can add server notification logic here
  }

  Future<Map<String, dynamic>> getTrialStatus() async {
    final trialData = await _getTrialData();
    if (trialData == null) {
      return {
        'isActive': false,
        'daysRemaining': 0,
        'isExpired': true,
      };
    }

    final startTime = DateTime.fromMillisecondsSinceEpoch(trialData['startTime']);
    final currentTime = await _getVerifiedTime();
    final daysElapsed = currentTime.difference(startTime).inDays;
    final daysRemaining = trialDurationDays - daysElapsed;

    return {
      'isActive': daysRemaining > 0,
      'daysRemaining': daysRemaining > 0 ? daysRemaining : 0,
      'isExpired': daysRemaining <= 0,
      'startDate': startTime.toIso8601String(),
      'endDate': startTime.add(Duration(days: trialDurationDays)).toIso8601String(),
    };
  }
}

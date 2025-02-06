import 'package:appwrite/appwrite.dart';


class AppwriteGlobalService {
  static final Client client = Client();
  static late final Account account;
  static late final Databases database;
  final storage = Storage(client);

  // Database and Collection IDs
  static const String databaseId = '67a48e68001a107e0078';
  static const String usersTrials = '67a48e850003a479c23c';
  static const String trialVerificationLogs = '67a490ab0010944f8d8d';
  static const String trialDevices = '67a48f76001a4c5196f7'; // student collection to be created on



  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    client
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67a48db60018070aa12a");

    account = Account(client);
    database = Databases(client);

    _isInitialized = true;
  }
  // Check if the service is initialized before performing database operations
  void ensureInitialized() {
    if (!_isInitialized) {
      throw Exception("AppwriteService is not initialized. Call init() before using.");
    }
  }

}

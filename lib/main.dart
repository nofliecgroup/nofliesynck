import 'package:flutter/material.dart';
import 'package:nofliesynck/appwrite_logic/appwrite_global_service.dart';
import 'package:nofliesynck/appwrite_logic/auth_ui_service.dart';
import 'package:nofliesynck/screens/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthUIService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoFliesyNck Application',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        isDark: false,
        toggleTheme: () {

        },
      ),
    );
  }
}

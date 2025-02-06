import 'package:flutter/material.dart';

class NetworkReportingDisplay extends StatefulWidget {
  const NetworkReportingDisplay({super.key});

  @override
  State<NetworkReportingDisplay> createState() => _NetworkReportingDisplayState();
}

class _NetworkReportingDisplayState extends State<NetworkReportingDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Network Reporting"),
      ),
      body: const Center(
        child: Text("Network Reporting"),
      ),
    );
  }
}
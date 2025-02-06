// components/bottom_actions.dart
import 'package:flutter/material.dart';
import 'package:nofliesynck/auths/login.dart';
import 'package:nofliesynck/auths/registration.dart';
import 'package:nofliesynck/components/action_button.dart';
import 'package:nofliesynck/screens/password_gen.dart';

class BottomActionsPanel extends StatelessWidget {
  const BottomActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionButton(
            icon: Icons.password,
            label: "Generate Secure Password",
            color: Colors.blue,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdvancedPasswordGenerator(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.person_add,
                  label: "Register",
                  color: Colors.green,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhanceRegistration(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.login,
                  label: "Login",
                  color: Colors.purple,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedLogin(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

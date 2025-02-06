import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nofliesynck/helpers/animated_background.dart';
import 'package:zxcvbn/zxcvbn.dart';

class AdvancedPasswordGenerator extends StatefulWidget {
  const AdvancedPasswordGenerator({super.key});

  @override
  State<AdvancedPasswordGenerator> createState() => _AdvancedPasswordGeneratorState();
}

class _AdvancedPasswordGeneratorState extends State<AdvancedPasswordGenerator>
    with SingleTickerProviderStateMixin {
  String _generatedPassword = '';
  int _passwordLength = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;
  bool _avoidAmbiguous = true;
  bool _enforceUnique = true;
  double _passwordStrength = 0.0;
  bool _isGenerating = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Zxcvbn _zxcvbn = Zxcvbn();

  static const String _uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijkmnpqrstuvwxyz';
  static const String _numbers = '23456789';
  static const String _specialBasic = '!@#\$%^&*()-_=+';
  static const String _specialExtended = '[]{}|;:,.<>?/~`';

  final Random _secureRandom = Random.secure();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _generateNewPassword();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Previous helper methods remain the same...
  // (_getSecureRandomBytes, generateEnhancedPassword, etc.)

  Future<void> _generateNewPassword() async {
    setState(() => _isGenerating = true);

    try {
      // Add a slight delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 300));

      final newPassword = generateEnhancedPassword(
        length: _passwordLength,
        useUpper: _includeUppercase,
        useLower: _includeLowercase,
        useNumbers: _includeNumbers,
        useSpecial: _includeSpecialChars,
        avoidAmbiguous: _avoidAmbiguous,
        enforceUnique: _enforceUnique,
      );

      // Simulate haptic feedback
      HapticFeedback.mediumImpact();

      setState(() {
        _generatedPassword = newPassword;
        final result = _zxcvbn.evaluate(newPassword);
        _passwordStrength = (result.score ?? 0) / 4.0;
      });
    } catch (e) {
      _showErrorDialog('Error', e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Password copied!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Password Generator'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: AnimatedBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordDisplay(),
                  const SizedBox(height: 24),
                  _buildOptionsCard(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(),
                  const SizedBox(height: 24),
                  if (_generatedPassword.isNotEmpty)
                    _buildPasswordAnalysis(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  _generatedPassword.isNotEmpty ? _generatedPassword : 'Generate a password...',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Courier',
                    letterSpacing: 1.2,
                    color: _generatedPassword.isEmpty ? Colors.grey : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _generatedPassword.isEmpty ? null : _copyToClipboard,
                tooltip: 'Copy to clipboard',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isGenerating ? null : _generateNewPassword,
                tooltip: 'Generate new password',
              ),
            ],
          ),
          if (_generatedPassword.isNotEmpty) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: Colors.grey[200],
              color: ColorTween(
                begin: Colors.red,
                end: Colors.green,
              ).lerp(_passwordStrength),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildLengthSelector(),
          const SizedBox(height: 20),
          _buildCharacterOptions(),
          const SizedBox(height: 20),
          _buildAdvancedOptions(),
        ],
      ),
    );
  }

  Widget _buildLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password Length',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              _passwordLength.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha:0.2),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withValues(alpha:0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: _passwordLength.toDouble(),
            min: 8,
            max: 64,
            divisions: 56,
            label: _passwordLength.toString(),
            onChanged: (value) {
              setState(() => _passwordLength = value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Character Types',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildOptionChip(
              'Uppercase (A-Z)',
              _includeUppercase,
                  (value) => setState(() => _includeUppercase = value),
            ),
            _buildOptionChip(
              'Lowercase (a-z)',
              _includeLowercase,
                  (value) => setState(() => _includeLowercase = value),
            ),
            _buildOptionChip(
              'Numbers (0-9)',
              _includeNumbers,
                  (value) => setState(() => _includeNumbers = value),
            ),
            _buildOptionChip(
              'Special (!@#\$)',
              _includeSpecialChars,
                  (value) => setState(() => _includeSpecialChars = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Options',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildOptionChip(
              'Avoid Ambiguous',
              _avoidAmbiguous,
                  (value) => setState(() => _avoidAmbiguous = value),
            ),
            _buildOptionChip(
              'Unique Characters',
              _enforceUnique,
                  (value) => setState(() => _enforceUnique = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: value,
      label: Text(label),
      onSelected: onChanged,
      selectedColor: Theme.of(context).primaryColor.withValues(alpha:0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateNewPassword,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isGenerating
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Generate New Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPasswordAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            'Strength',
            '${(_passwordStrength * 100).round()}%',
            _getStrengthColor(_passwordStrength),
          ),
          _buildAnalysisItem(
            'Entropy',
            '${_calculateEntropy(_generatedPassword).toStringAsFixed(2)} bits',
            Colors.blue,
          ),
          _buildAnalysisItem(
            'Crack Time',
            _getCrackTimeEstimate(),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              //... continuing from previous implementation

            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  // Core password generation methods
  Uint8List _getSecureRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes;
  }

  String generateEnhancedPassword({
    required int length,
    required bool useUpper,
    required bool useLower,
    required bool useNumbers,
    required bool useSpecial,
    required bool avoidAmbiguous,
    required bool enforceUnique,
  }) {
    if (length < 8) {
      throw ArgumentError('Password length must be at least 8 characters');
    }

    final List<String> charSets = [];
    if (useUpper) charSets.add(_uppercase);
    if (useLower) charSets.add(_lowercase);
    if (useNumbers) charSets.add(_numbers);
    if (useSpecial) {
      charSets.add(_specialBasic);
      if (!avoidAmbiguous) charSets.add(_specialExtended);
    }

    if (charSets.isEmpty) {
      throw ArgumentError('At least one character set must be selected');
    }

    final List<String> password = [];
    for (final charSet in charSets) {
      password.add(_getSecureChar(charSet));
    }

    final String allChars = charSets.join();
    while (password.length < length) {
      final char = _getSecureChar(allChars);
      if (!enforceUnique || !password.contains(char)) {
        password.add(char);
      }
    }

    _secureShuffleList(password);

    final result = password.join();

    if (!_validatePassword(result, useUpper, useLower, useNumbers, useSpecial)) {
      return generateEnhancedPassword(
        length: length,
        useUpper: useUpper,
        useLower: useLower,
        useNumbers: useNumbers,
        useSpecial: useSpecial,
        avoidAmbiguous: avoidAmbiguous,
        enforceUnique: enforceUnique,
      );
    }

    return result;
  }

  String _getSecureChar(String charSet) {
    final bytes = _getSecureRandomBytes(4);
    final index = bytes.buffer.asByteData().getUint32(0) % charSet.length;
    return charSet[index];
  }

  void _secureShuffleList(List<String> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = _secureRandom.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  bool _validatePassword(
      String password,
      bool requireUpper,
      bool requireLower,
      bool requireNumbers,
      bool requireSpecial,
      ) {
    if (requireUpper && !password.contains(RegExp(r'[A-Z]'))) return false;
    if (requireLower && !password.contains(RegExp(r'[a-z]'))) return false;
    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) return false;
    if (requireSpecial &&
        !password.contains(RegExp(r'[!@#\$%^&*()-_=+\[\]{}|;:,.<>?/~`]'))) {
      return false;
    }
    return true;
  }

  double _calculateEntropy(String password) {
    final int length = password.length;
    int poolSize = 0;

    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()-_=+\[\]{}|;:,.<>?/~`]'))) {
      poolSize += 32;
    }

    return (length * log(poolSize) / log(2));
  }

  String _getCrackTimeEstimate() {
    final entropy = _calculateEntropy(_generatedPassword);
    final strengthDescriptions = [
      {'threshold': 128, 'time': 'centuries or more'},
      {'threshold': 100, 'time': 'several centuries'},
      {'threshold': 80, 'time': 'decades'},
      {'threshold': 60, 'time': 'years'},
      {'threshold': 50, 'time': 'months'},
      {'threshold': 40, 'time': 'weeks'},
      {'threshold': 30, 'time': 'days'},
      {'threshold': 20, 'time': 'hours'},
    ];

    for (var description in strengthDescriptions) {
      // Cast 'threshold' to num and 'time' to String.
      num threshold = description['threshold'] as num;
      String time = description['time'] as String;

      if (entropy >= threshold) {
        return time;
      }
    }
    return 'minutes or less';
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* void _showPasswordInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password Strength Info',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Very Strong',
                'Contains mix of characters, good length, unique',
                Colors.green,
              ),
              _buildInfoItem(
                'Strong',
                'Good variety but could be improved',
                Colors.blue,
              ),
              _buildInfoItem(
                'Medium',
                'Missing some character types or too short',
                Colors.orange,
              ),
              _buildInfoItem(
                'Weak',
                'Too simple or too short',
                Colors.red,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } */

  /* Widget _buildInfoItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } */

}

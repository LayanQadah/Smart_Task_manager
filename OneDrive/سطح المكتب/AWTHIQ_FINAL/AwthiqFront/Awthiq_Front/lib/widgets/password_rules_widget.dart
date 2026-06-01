import 'package:flutter/material.dart';

bool hasEnglishOnly(String p) =>
    p.isNotEmpty && !RegExp(r'[^\x00-\x7F]').hasMatch(p);

bool hasUppercase(String p) => p.contains(RegExp(r'[A-Z]'));

bool hasLowercase(String p) => p.contains(RegExp(r'[a-z]'));

bool hasMinLength(String p) => p.length >= 8;

bool hasSymbol(String p) => p.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|~]'));

bool isPasswordValid(String p) =>
    hasEnglishOnly(p) &&
    hasUppercase(p) &&
    hasLowercase(p) &&
    hasMinLength(p) &&
    hasSymbol(p);

class PasswordRulesWidget extends StatefulWidget {
  final TextEditingController controller;
  const PasswordRulesWidget({required this.controller, super.key});

  @override
  State<PasswordRulesWidget> createState() => _PasswordRulesWidgetState();
}

class _PasswordRulesWidgetState extends State<PasswordRulesWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.text;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _rule('باللغة الإنجليزية فقط',          hasEnglishOnly(p)),
          _rule('حرف كبير واحد على الأقل (A-Z)',  hasUppercase(p)),
          _rule('حرف صغير واحد على الأقل (a-z)',  hasLowercase(p)),
          _rule('8 خانات على الأقل',               hasMinLength(p)),
          _rule('رمز واحد على الأقل (!@#...)',     hasSymbol(p)),
        ],
      ),
    );
  }

  Widget _rule(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: passed ? const Color(0xFF1B4563) : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: passed ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}

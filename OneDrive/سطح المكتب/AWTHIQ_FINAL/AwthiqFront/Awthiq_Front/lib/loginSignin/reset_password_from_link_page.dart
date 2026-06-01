import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/password_rules_widget.dart';

class ResetPasswordFromLinkPage extends StatefulWidget {
  final String token;
  const ResetPasswordFromLinkPage({required this.token, super.key});

  @override
  State<ResetPasswordFromLinkPage> createState() => _ResetPasswordFromLinkPageState();
}

class _ResetPasswordFromLinkPageState extends State<ResetPasswordFromLinkPage> {
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _done      = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      _showMsg('يرجى تعبئة جميع الحقول', isError: true);
      return;
    }
    if (!isPasswordValid(_passCtrl.text)) {
      _showMsg('كلمة المرور لا تستوفي الشروط', isError: true);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _showMsg('كلمتا المرور غير متطابقتين', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.resetPasswordByToken(widget.token, _passCtrl.text);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _done = true);
    } else {
      _showMsg(result['error'] ?? 'حدث خطأ، الرابط منتهي الصلاحية', isError: true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعيين كلمة مرور جديدة', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B4563),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _done ? _successView() : _formView(),
      ),
    );
  }

  Widget _successView() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        const Text('تم تغيير كلمة المرور بنجاح!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        const SizedBox(height: 12),
        const Text('يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _formView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.lock_reset, color: Color(0xFF1B4563), size: 60),
        const SizedBox(height: 16),
        const Text('أدخلي كلمة المرور الجديدة', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF1B4563))),
        const SizedBox(height: 24),
        _field(_passCtrl, 'كلمة المرور الجديدة', obscure: true),
        const SizedBox(height: 8),
        PasswordRulesWidget(controller: _passCtrl),
        _field(_confirmCtrl, 'تأكيد كلمة المرور', obscure: true),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _isLoading ? null : _reset,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xCA90B3FF), Color(0xE017283A)],
              ),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('تغيير كلمة المرور',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

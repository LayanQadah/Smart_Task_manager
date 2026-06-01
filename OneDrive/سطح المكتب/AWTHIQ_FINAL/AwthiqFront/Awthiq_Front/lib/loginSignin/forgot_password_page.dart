import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/backgrounds.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _idCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent      = false;

  String _maskedEmail = '';
  bool   _hasEmail    = false;
  bool   _showOptions = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    if (_idCtrl.text.trim().isEmpty) {
      _showMsg('يرجى إدخال رقم الهوية', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.checkUserForReset(_idCtrl.text.trim());
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _maskedEmail = result['masked_email'] ?? '';
        _hasEmail    = result['has_email'] == true;
        _showOptions = true;
      });
    } else {
      _showMsg(result['error'] ?? 'حدث خطأ', isError: true);
    }
  }

  Future<void> _sendLink(String method) async {
    setState(() => _isLoading = true);
    final result = await ApiService.sendResetLink(_idCtrl.text.trim(), method);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _sent = true);
    } else {
      _showMsg(result['error'] ?? 'حدث خطأ', isError: true);
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Column(
            children: [
              // ── الجزء العلوي ──────────────────────────────────
              SizedBox(
                height: screenHeight * 0.45,
                child: Stack(
                  children: [
                    HomeBackground(),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset("assets/HandAwthiq.png", width: 250),
                    ),
                  ],
                ),
              ),

              // ── الجزء السفلي ──────────────────────────────────
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: _sent
                        ? _sentView()
                        : _showOptions
                            ? _optionsView()
                            : _idView(),
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── خطوة 1: إدخال رقم الهوية ──────────────────────────────────────────────

  Widget _idView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('نسيت كلمة المرور؟',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        const SizedBox(height: 6),
        const Text('أدخل رقم الهوية وسنرسل لك رابط إعادة التعيين',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        _field(_idCtrl, 'رقم الهوية / السجل التجاري', keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _btn('التالي', _checkUser),
      ],
    );
  }

  // ── خطوة 2: اختيار طريقة الإرسال ─────────────────────────────────────────

  Widget _optionsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('اختر طريقة استلام الرابط',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        const SizedBox(height: 6),
        const Text('سيصلك رابط لإعادة تعيين كلمة المرور',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        if (_hasEmail)
          _optionCard(
            icon: Icons.email_outlined,
            title: 'إرسال على الإيميل',
            subtitle: _maskedEmail,
            onTap: () => _sendLink('email'),
          ),
        if (_isLoading) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF1B4563).withValues(alpha: 0.3)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: const Color(0xFF1B4563), size: 28),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B4563))),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── تم الإرسال ─────────────────────────────────────────────────────────────

  Widget _sentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        const Icon(Icons.mark_email_read, color: Colors.green, size: 70),
        const SizedBox(height: 16),
        const Text('تم إرسال الرابط!',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        const SizedBox(height: 10),
        const Text(
            'افتح الرابط المرسل وستنتقل لصفحة تغيير كلمة المرور.\nالرابط صالح لمدة 10 دقائق.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.6)),
      ],
    );
  }

  // ── مساعدات ───────────────────────────────────────────────────────────────

  Widget _field(TextEditingController c, String hint,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
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
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
        ),
      ),
    );
  }
}

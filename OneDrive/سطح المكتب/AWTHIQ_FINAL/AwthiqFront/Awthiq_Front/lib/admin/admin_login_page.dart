import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import 'admin_home_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_userController.text.trim().isEmpty || _passController.text.isEmpty) {
      _snack('يرجى تعبئة جميع الحقول', Colors.red);
      return;
    }
    setState(() => _loading = true);
    final res = await ApiService.adminLogin(
        _userController.text.trim(), _passController.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
        (_) => false,
      );
    } else {
      _snack(res['error'] ?? 'خطأ في تسجيل الدخول', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // ── الجزء العلوي ──────────────────────────────────────
          SizedBox(
            height: screenHeight * 0.45,
            child: Stack(
              children: [
                HomeBackground(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset('assets/HandAwthiq.png', width: 250),
                ),
              ],
            ),
          ),

          // ── الجزء السفلي ──────────────────────────────────────
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── اللوقو والعنوان ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // أيقونة الأدمن يسار
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
                            ),
                          ),
                          child: const Icon(Icons.admin_panel_settings,
                              color: Colors.white, size: 22),
                        ),
                        // لوقو + شعار يمين
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('assets/logo7.png', width: 110),
                            const SizedBox(height: 2),
                            const Text(
                              'توثيق سريع، ثقة دائمة.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1B4563),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── عنوان الصفحة ──
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'لوحة تحكم المسؤول',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4563),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'أدخل بيانات الدخول للمتابعة',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── حقل اسم المستخدم ──
                    _field('اسم المستخدم', _userController, false),
                    const SizedBox(height: 14),

                    // ── حقل كلمة المرور ──
                    _field('كلمة المرور', _passController, _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )),

                    const SizedBox(height: 24),

                    // ── زر الدخول ──
                    GestureDetector(
                      onTap: _loading ? null : _login,
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
                          child: _loading
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'دخول',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, bool obscure,
      {Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

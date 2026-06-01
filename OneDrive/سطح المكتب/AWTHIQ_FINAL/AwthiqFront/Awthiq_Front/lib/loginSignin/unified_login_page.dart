import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../user/individual_home_page.dart';
import '../company/company_home_page.dart';
import '../trainer/trainer_home_page.dart';
import '../services/api_service.dart';

class UnifiedLoginPage extends StatefulWidget {
  final String type;
  const UnifiedLoginPage({required this.type, super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController   = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password   = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('يرجى تعبئة جميع الحقول');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.login(identifier, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final userType = result['user_type'];
      Widget page;
      if (userType == 'user') {
        page = IndividualHomePage();
      } else if (userType == 'company') {
        page = const CompanyHomePage();
      } else {
        page = const TrainingHomePage();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    } else {
      _showError(result['error'] ?? 'خطأ في تسجيل الدخول');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset("assets/logo7.png", width: 120),
                          const SizedBox(height: 1),
                          const Text(
                            'توثيق سريع، ثقة دائمة.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _identifierController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: widget.type == "individual" ? 'رقم الهوية' : 'البريد الإلكتروني',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoading ? null : _login,
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
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'دخول',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                      ),
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      const Text('ليس لديك حساب؟ '),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage(type: widget.type)),
                        ),
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

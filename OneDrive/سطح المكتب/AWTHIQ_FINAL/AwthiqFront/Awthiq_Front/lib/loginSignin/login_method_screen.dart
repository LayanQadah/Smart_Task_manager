import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import 'unified_login_page.dart';

class LoginMethodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isMobile = w < 600;

    return Scaffold(
      body: Column(
        children: [
          // الجزء العلوي
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                HomeBackground(),
                Positioned(
                  top: 40, left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/HandAwthiq.png",
                    width: isMobile ? w * 0.55 : h * 0.45,
                  ),
                ),
              ],
            ),
          ),

          // الجزء الأبيض
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: h * 0.025),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Image.asset("assets/logo7.png", width: 120),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "توثيق سريع, ثقة دائمة",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.03),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => UnifiedLoginPage(type: "individual"),
                            )),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(colors: [Color(0xCA90B3FF), Color(0xE017283A)]),
                              ),
                              child: const Center(
                                child: Text("تسجيل الدخول",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green.shade100,
                            ),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 16, color: Colors.green.shade800),
                                  children: const [
                                    TextSpan(text: "تسجيل الدخول باستخدام ", style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: "نفاذ", style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

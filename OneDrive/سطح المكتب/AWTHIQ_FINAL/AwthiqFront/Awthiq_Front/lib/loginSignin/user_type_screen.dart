import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import 'unified_login_page.dart';
import 'login_method_screen.dart';

class UserTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: Column(
        children: [

          // 🔝 الجزء العلوي
          Expanded(
            flex: 5,
            child: Stack(
              children: [

                HomeBackground(),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/HandAwthiq.png",
                    width: w * 0.55,
                  ),
                ),

              ],
            ),
          ),

          // 🔽 الجزء السفلي
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w < 600 ? w * 0.05 : 30, vertical: h * 0.025),
                child: Column(
                  children: [

                    // اللوقو + النص
                    Row(
                      children: [
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(
                              "assets/logo7.png",
                              width: w < 600 ? w * 0.28 : 130,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'توثيق سريع، ثقة دائمة.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1B4563),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: h * 0.025),

                    // زر أفراد
                    _buildButton(
                      context: context,
                      text: 'أوثق أفراد',
                      subText: "Awthiq Individuals",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginMethodScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: h * 0.02),

                    // زر شركات
                    _buildButton(
                      context: context,
                      text: 'أوثق شركات',
                      subText: "Awthiq Companies",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnifiedLoginPage(type: "company"),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: h * 0.02),

                    // زر مؤسسات
                    _buildButton(
                      context: context,
                      text: 'أوثق مؤسسات التدريب',
                      subText: "Awthiq Training Institutions",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnifiedLoginPage(type: "training"),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: h * 0.02),

                  ],
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

  Widget _buildButton({required BuildContext context, required String text, required String subText, required VoidCallback onTap}) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xCA90B3FF), Color(0xE017283A)],
          ),
        ),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subText,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 13 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

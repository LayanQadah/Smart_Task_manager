import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart'; // تأكدي من مسار ملف الخلفيات في مشروعك

class UploadFilePage extends StatelessWidget {
  const UploadFilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. البار العلوي (AppBar) بتصميم بسيط
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "إرفاق ملف المهارة",
              style: TextStyle(
                color: Color(0xFF1B4563),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 15),
            // هنا يمكنك وضع شعار أوثق الصغير
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 2. الخلفية المتعرجة (HomeBackground)
           HomeBackground(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 3. منطقة الرفع (تصميم زجاجي يتناسب مع الخلفية)
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // شفافية خفيفة
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF7FA8E6).withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // أيقونة الرفع بتدرج لوني خفيف
                      const Icon(
                        Icons.cloud_upload_rounded,
                        size: 90,
                        color: Color(0xFF7FA8E6),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "اضغط هنا لرفع المهارة",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1B4563),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "يجب أن يكون الملف بصيغة PDF أو صورة",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // لدفع الزر إلى الأسفل

                // 4. زر تأكيد الإرفاق (التصميم المتدرج الموحد)
                GestureDetector(
                  onTap: () {
                    // منطق الرفع هنا
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4563).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "تأكيد الإرفاق",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
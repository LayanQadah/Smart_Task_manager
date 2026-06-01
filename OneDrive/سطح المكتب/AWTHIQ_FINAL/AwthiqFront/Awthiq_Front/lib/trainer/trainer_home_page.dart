import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import 'course_page.dart';
import '../company/search_by_id.dart';
import '../company/search_by_description.dart';
import '../company/change_employee_job.dart';
import '../company/issue_certificate_page.dart';
import '../company/company_employees_page.dart';
import '../company/company_profile_page.dart';
import '../loginSignin/user_type_screen.dart';

class TrainingHomePage extends StatefulWidget {
  const TrainingHomePage({super.key});

  @override
  State<TrainingHomePage> createState() => _TrainingHomePageState();
}

class _TrainingHomePageState extends State<TrainingHomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _InstitutionHomeContent(),
      const CompanyProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF1B4563)),
              onPressed: () => _showLogoutDialog(context),
            ),
            const Text('توثيق سريع، ثقة دائمة.',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 14)),
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(children: [HomeBackground(), pages[currentIndex]]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: const Color(0xFF1B4563),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'ملف المؤسسة'),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFECEFF1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: const Text(
                "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dialogBtn("إلغاء", () => Navigator.pop(context)),
                _dialogBtn("خروج", () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => UserTypeScreen()),
                    (route) => false,
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _InstitutionHomeContent extends StatelessWidget {
  const _InstitutionHomeContent();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("مرحباً", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              Text("المؤسسة التدريبية", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(width: 20),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFADCBE3).withValues(alpha: 0.6),
            ),
            child: const Icon(Icons.school, size: 60, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cards = [
      ('الدورات التدريبية',              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesPage()))),
      ('البحث عن موظف بالرقم التعريفي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchByIdPage()))),
      ('تغيير المسمى الوظيفي',          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeEmployeeJobPage()))),
      ('وصف الموظف المطلوب',            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchByDescriptionPage()))),
      ('إصدار شهادة لموظف',             () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueCertificatePage()))),
      ('موظفين المؤسسة',                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyEmployeesPage()))),
    ];

    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 500;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: isMobile ? 1.8 : 2.2,
        ),
        children: cards.map((c) => _card(c.$1, c.$2)).toList(),
      ),
    );
  }

  Widget _card(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFFBFD8FF), Color(0xFFA7E3D7), Color(0xFF7FA8E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF1B4563)),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

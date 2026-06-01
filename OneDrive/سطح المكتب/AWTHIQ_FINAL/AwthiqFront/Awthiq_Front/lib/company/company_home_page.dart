import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import 'change_employee_job.dart';
import 'search_by_id.dart';
import 'search_by_description.dart';
import 'issue_certificate_page.dart';
import 'company_employees_page.dart';
import '../loginSignin/user_type_screen.dart';
import 'company_profile_page.dart';

class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({super.key});

  @override
  State<CompanyHomePage> createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildCompanyContent(),
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
              onPressed: () => showLogoutDialog(context),
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
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'الملف'),
        ],
      ),
    );
  }

  // دالة بناء محتوى "الرئيسية" (بدون AppBar)
  Widget _buildCompanyContent() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          _buildOptionsGrid(),
        ],
      ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("مرحباً", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              Text("الشركة الرقمية", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(width: 20),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFADCBE3).withOpacity(0.6),
            ),
            child: const Icon(Icons.location_city, size: 60, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
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
        children: [
          _buildCompanyCard("البحث عن موظف بالرقم التعريفي", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByIdPage()));
          }),
          _buildCompanyCard("تغيير المسمى الوظيفي", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmployeeJobPage()));
          }),
          _buildCompanyCard("وصف الموظف المطلوب", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByDescriptionPage()));
          }),
          _buildCompanyCard("إصدار شهادة لموظف", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const IssueCertificatePage()));
          }),
          _buildCompanyCard("موظفين الشركة", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyEmployeesPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(String title, VoidCallback onTap) {
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
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

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: const Text("هل انت متأكد من انك تريد تسجيل الخروج؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton("إلغاء", () => Navigator.pop(context)),
                    _buildDialogButton("نعم", () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserTypeScreen()), (route) => false);
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
          boxShadow: [BoxShadow(color: const Color(0xFF1B4563).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
      ),
    );
  }
}

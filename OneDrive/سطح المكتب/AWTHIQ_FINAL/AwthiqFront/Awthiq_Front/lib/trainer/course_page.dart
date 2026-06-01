import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';
import 'add_course_page.dart';
import 'course_details_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<CourseModel> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final courses = await ApiService.getCourses();
    if (mounted) setState(() { _courses = courses; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('الدورات',
            style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)))
                        : _courses.isEmpty
                            ? const Center(
                                child: Text('لا توجد دورات حالياً',
                                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final cols = constraints.maxWidth < 500 ? 2 : 3;
                                  final ratio = constraints.maxWidth < 500 ? 0.95 : 1.1;
                                  return GridView.builder(
                                    itemCount: _courses.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: ratio,
                                    ),
                                    itemBuilder: (_, index) => _courseCard(_courses[index]),
                                  );
                                },
                              ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCoursePage()),
                    );
                    if (added == true) _load();
                  },
                  child: Container(
                    width: double.infinity, height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(colors: [Color(0xFF7FA8E6), Color(0xFF1B4563)]),
                    ),
                    child: const Center(
                      child: Text('إضافة دورة تدريبية',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(CourseModel course) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsPage(course: course)));
        _load();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFFBFD8FF), Color(0xFFA7E3D7), Color(0xFF7FA8E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        course.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                      ),
                    ),
                  ),
                ),
                if (course.participantsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("${course.participantsCount} متدرب",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1B4563))),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFF7FA8E6), Color(0xFF1B4563)]),
                  ),
                  child: const Text('عرض التفاصيل', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

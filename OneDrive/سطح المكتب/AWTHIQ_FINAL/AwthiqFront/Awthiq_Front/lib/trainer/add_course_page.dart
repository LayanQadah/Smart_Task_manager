import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _nameController      = TextEditingController();
  final _descController      = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController   = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _startDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة اسم الدورة وتاريخ البدء'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    final data = <String, String>{
      'name':        _nameController.text.trim(),
      'description': _descController.text.trim(),
      'start_date':  _startDateController.text.trim(),
    };
    if (_endDateController.text.trim().isNotEmpty) {
      data['end_date'] = _endDateController.text.trim();
    }
    final res = await ApiService.createCourse(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الدورة بنجاح'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في إنشاء الدورة'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("إضافة دورة",
            style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Text("قم بإدخال معلومات الدورة",
                      style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  _input("اسم الدورة *", _nameController),
                  _input("وصف الدورة", _descController, maxLines: 3),
                  Row(
                    children: [
                      Expanded(child: _dateInput("إلى", _endDateController)),
                      const SizedBox(width: 10),
                      Expanded(child: _dateInput("من *", _startDateController)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      width: 200, height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(colors: [Color(0xFF7FA8E6), Color(0xFF1B4563)]),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("إضافة الدورة",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _input(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B4563)),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B4563), width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _dateInput(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: TextAlign.center,
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            controller.text =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B4563)),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B4563), width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

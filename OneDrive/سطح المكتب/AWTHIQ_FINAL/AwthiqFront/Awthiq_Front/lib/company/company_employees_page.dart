import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyEmployeesPage extends StatefulWidget {
  const CompanyEmployeesPage({super.key});

  @override
  State<CompanyEmployeesPage> createState() => _CompanyEmployeesPageState();
}

class _CompanyEmployeesPageState extends State<CompanyEmployeesPage> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;
  final _uidCtrl = TextEditingController();
  bool _adding   = false;
  String? _addError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _uidCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ApiService.getCompanyEmployees();
    if (mounted) setState(() { _employees = list; _loading = false; });
  }

  Future<void> _add() async {
    final uid = _uidCtrl.text.trim();
    if (uid.isEmpty) {
      setState(() => _addError = 'أدخل الرقم التعريفي');
      return;
    }
    setState(() { _adding = true; _addError = null; });
    final res = await ApiService.addCompanyEmployee(uid);
    if (!mounted) return;
    setState(() => _adding = false);
    if (res['success'] == true) {
      _uidCtrl.clear();
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الموظف بنجاح'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    } else {
      setState(() => _addError = res['error'] ?? 'حدث خطأ');
    }
  }

  Future<void> _remove(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إزالة الموظف', textAlign: TextAlign.right),
        content: Text('هل تريد إزالة $name من قائمة موظفيك؟', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إزالة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await ApiService.removeCompanyEmployee(uid);
      if (mounted && ok) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('موظفو الشركة',
            style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── حقل إضافة موظف ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('إضافة موظف برقم ملفه',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563), fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _adding ? null : _add,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                          ),
                          child: Center(
                            child: _adding
                                ? const SizedBox(height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('إضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _uidCtrl,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'AW-XXXXXXXX',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_addError != null) ...[
                  const SizedBox(height: 8),
                  Text(_addError!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.right),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── قائمة الموظفين ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)))
                : _employees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text('لم تضف أي موظفين بعد',
                                style: TextStyle(color: Colors.grey, fontSize: 15)),
                            const SizedBox(height: 6),
                            const Text('أضف موظفين لتسهيل إصدار الشهادات لهم',
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _employees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _employeeCard(_employees[i]),
                        ),
                      ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(Map<String, dynamic> emp) {
    final uid   = emp['unique_id'] as String? ?? '';
    final name  = emp['name']      as String? ?? '-';
    final photo = emp['profile_photo'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // زر الإزالة
          GestureDetector(
            onTap: () => _remove(uid, name),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_remove_outlined, color: Colors.red.shade400, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // البيانات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4563))),
                const SizedBox(height: 3),
                Text(uid, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // الصورة
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFF0F7FF),
            backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
            child: (photo == null || photo.isEmpty)
                ? const Icon(Icons.person, color: Color(0xFF1B4563), size: 22)
                : null,
          ),
        ],
      ),
    );
  }
}

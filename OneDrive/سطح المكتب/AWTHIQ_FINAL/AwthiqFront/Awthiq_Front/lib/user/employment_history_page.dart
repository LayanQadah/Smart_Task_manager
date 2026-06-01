import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class EmploymentHistoryPage extends StatefulWidget {
  const EmploymentHistoryPage({super.key});

  @override
  State<EmploymentHistoryPage> createState() => _EmploymentHistoryPageState();
}

class _EmploymentHistoryPageState extends State<EmploymentHistoryPage> {
  List<CareerModel> _jobs = [];
  bool _loading = true;

  // حقول إضافة وظيفة جديدة
  final _companyCtrl   = TextEditingController();
  final _titleCtrl     = TextEditingController();
  final _startCtrl     = TextEditingController();
  final _endCtrl       = TextEditingController();
  final _descCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _companyCtrl.dispose(); _titleCtrl.dispose();
    _startCtrl.dispose();   _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await ApiService.getProfile();
    if (mounted) {
      final jobs = profile?.careerHistory ?? [];
      jobs.sort((a, b) {
        // الوظيفة الحالية (بدون تاريخ انتهاء) تأتي أولاً
        if (a.endDate == null && b.endDate != null) return -1;
        if (a.endDate != null && b.endDate == null) return 1;
        // ثم ترتيب تنازلي حسب تاريخ البدء
        return b.startDate.compareTo(a.startDate);
      });
      setState(() { _jobs = jobs; _loading = false; });
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteCareer(id);
    if (ok) {
      _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف السجل'), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddDialog() {
    _companyCtrl.clear(); _titleCtrl.clear();
    _startCtrl.clear();   _endCtrl.clear(); _descCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة وظيفة', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('اسم الشركة',    _companyCtrl),
              _field('المسمى الوظيفي', _titleCtrl),
              _field('تاريخ البدء (YYYY-MM-DD)', _startCtrl),
              _field('تاريخ الانتهاء (اتركه فارغاً إن كان حالياً)', _endCtrl),
              _field('الوصف (اختياري)', _descCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4563)),
            onPressed: () async {
              if (_companyCtrl.text.trim().isEmpty || _titleCtrl.text.trim().isEmpty || _startCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى تعبئة الحقول المطلوبة'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              final data = {
                'company_name': _companyCtrl.text.trim(),
                'job_title':    _titleCtrl.text.trim(),
                'start_date':   _startCtrl.text.trim(),
                if (_endCtrl.text.trim().isNotEmpty) 'end_date': _endCtrl.text.trim(),
                if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
              };
              final result = await ApiService.addCareer(data);
              if (result['success'] == true) {
                _load();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'خطأ'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1B4563), size: 28),
            onPressed: _showAddDialog,
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('تاريخ التوظيف',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 10),
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)))
              : _jobs.isEmpty
                  ? const Center(child: Text('لا يوجد سجل وظيفي بعد', style: TextStyle(color: Color(0xFF1B4563))))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _jobs.length,
                        itemBuilder: (_, i) => _buildJobCard(_jobs[i]),
                      ),
                    ),
                    ),
        ],
      ),
    );
  }

  Widget _buildJobCard(CareerModel job) {
    final isCurrent = job.endDate == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: const Color(0xFF7FA8E6), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!job.addedByCompany)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _delete(job.id),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (job.addedByCompany)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B4563).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('من الشركة', style: TextStyle(fontSize: 11, color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                      ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FA8E6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('حالي', style: TextStyle(fontSize: 11, color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                      ),
                    Text(job.jobTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(job.companyName, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  '${job.startDate} – ${job.endDate ?? 'حتى الآن'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (job.description != null && job.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(job.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? const Color(0xFF7FA8E6) : Colors.grey.shade200,
            ),
            child: Icon(Icons.work_outline,
                color: isCurrent ? Colors.white : Colors.grey, size: 22),
          ),
        ],
      ),
    );
  }
}

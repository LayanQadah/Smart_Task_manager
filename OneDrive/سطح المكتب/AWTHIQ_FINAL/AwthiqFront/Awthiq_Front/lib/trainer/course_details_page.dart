import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class CourseDetailsPage extends StatefulWidget {
  final CourseModel course;
  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final _enrollCtrl = TextEditingController();
  final _titleCtrl  = TextEditingController();
  final _dateCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();

  List<Map<String, dynamic>> _participants = [];
  Set<String> _selected = {};
  bool _loadingParticipants = true;
  bool _isEnrolling = false;
  bool _isIssuing   = false;

  Uint8List? _fileBytes;
  String?    _fileName;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.course.name;
    if (widget.course.endDate != null) _dateCtrl.text = widget.course.endDate!;
    _loadParticipants();
  }

  @override
  void dispose() {
    _enrollCtrl.dispose();
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    setState(() => _loadingParticipants = true);
    final list = await ApiService.getCourseParticipants(widget.course.id);
    if (mounted) setState(() { _participants = list; _loadingParticipants = false; });
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == _participants.length) {
        _selected.clear();
      } else {
        _selected = _participants.map((p) => p['unique_id'] as String).toSet();
      }
    });
  }

  void _toggleOne(String uid) {
    setState(() {
      if (_selected.contains(uid)) { _selected.remove(uid); } else { _selected.add(uid); }
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    if (mounted) setState(() { _fileBytes = file.bytes!; _fileName = file.name; });
  }

  Future<void> _enroll() async {
    if (_enrollCtrl.text.trim().isEmpty) return;
    setState(() => _isEnrolling = true);
    final res = await ApiService.enrollParticipant(widget.course.id, _enrollCtrl.text.trim());
    setState(() => _isEnrolling = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل المتدرب بنجاح'), backgroundColor: Colors.green),
      );
      _enrollCtrl.clear();
      _loadParticipants();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _confirmRemove(String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFECEFF1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Text('هل تريدين حذف "$name" من الدورة؟',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dialogBtn('إلغاء', () => Navigator.pop(context, false)),
                _dialogBtn('حذف', () => Navigator.pop(context, true), isRed: true),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final ok = await ApiService.removeCourseParticipant(widget.course.id, uid);
    if (!mounted) return;
    if (ok) {
      setState(() => _selected.remove(uid));
      _loadParticipants();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المتدرب من الدورة'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الحذف'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _dialogBtn(String label, VoidCallback onTap, {bool isRed = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: isRed
                ? [Colors.red.shade300, Colors.red.shade700]
                : [const Color(0xFF8FBDEB), const Color(0xFF1B4563)],
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _issueSelected() async {
    if (_selected.isEmpty) return;
    final title = _titleCtrl.text.trim();
    final date  = _dateCtrl.text.trim();
    if (title.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم الشهادة والتاريخ مطلوبان'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isIssuing = true);
    final res = await ApiService.issueSelectedCertificates(
      courseId:    widget.course.id,
      uniqueIds:   _selected.toList(),
      title:       title,
      issueDate:   date,
      description: _descCtrl.text.trim(),
      fileBytes:   _fileBytes,
      fileName:    _fileName,
    );
    setState(() => _isIssuing = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'تم إصدار الشهادات'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.course.name,
            style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildCourseInfo(),
                  const SizedBox(height: 16),
                  _buildParticipantsList(),
                  const SizedBox(height: 16),
                  _buildEnrollSection(),
                  if (_selected.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildIssueSection(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("معلومات الدورة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4563))),
          const Divider(),
          _infoRow("اسم الدورة", widget.course.name),
          if (widget.course.description.isNotEmpty) _infoRow("الوصف", widget.course.description),
          _infoRow("تاريخ البدء", widget.course.startDate),
          if (widget.course.endDate != null) _infoRow("تاريخ الانتهاء", widget.course.endDate!),
          _infoRow("عدد المتدربين", "${_participants.length}"),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_participants.isNotEmpty)
                GestureDetector(
                  onTap: _toggleAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                    ),
                    child: Text(
                      _selected.length == _participants.length ? 'إلغاء الكل' : 'تحديد الكل',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const Text("المتدربون المسجلون",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingParticipants)
            const Center(child: Padding(padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF1B4563))))
          else if (_participants.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('لا يوجد متدربون مسجلون حتى الآن',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ))
          else
            ..._participants.map((p) {
              final uid     = p['unique_id'] as String? ?? '';
              final name    = p['name']      as String? ?? '';
              final checked = _selected.contains(uid);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: checked ? const Color(0xFFE8F4FD) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: checked ? const Color(0xFF1B4563) : Colors.transparent, width: 1.5),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: checked,
                      onChanged: (_) => _toggleOne(uid),
                      activeColor: const Color(0xFF1B4563),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const CircleAvatar(radius: 18, backgroundColor: Color(0xFFADCBE3),
                        child: Icon(Icons.person, size: 20, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleOne(uid),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563), fontSize: 14)),
                            Text(uid,  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _confirmRemove(uid, name),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEnrollSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("تسجيل متدرب جديد",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4563))),
          const SizedBox(height: 12),
          TextField(
            controller: _enrollCtrl,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "الرقم التعريفي للمتدرب (AW-XXXXXXX)",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isEnrolling ? null : _enroll,
            child: Container(
              width: double.infinity, height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
              ),
              child: Center(
                child: _isEnrolling
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("تسجيل", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueSection() {
    final allSelected = _selected.length == _participants.length && _participants.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4563).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_selected.length} محدد',
                      style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              const Text("إصدار الشهادات",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4563))),
            ],
          ),
          const Divider(height: 20),
          const Align(alignment: Alignment.centerRight,
              child: Text('اسم الشهادة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerRight,
              child: Text('تاريخ الإصدار:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _dateCtrl.text = picked.toIso8601String().substring(0, 10));
            },
            child: AbsorbPointer(
              child: TextField(
                controller: _dateCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  isDense: true,
                  suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF1B4563)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerRight,
              child: Text('الوصف (اختياري):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            textAlign: TextAlign.right,
            maxLines: 2,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerRight,
              child: Text('صورة / ملف الشهادة (اختياري):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8FBDEB)),
              ),
              child: Column(
                children: [
                  Icon(_fileBytes != null ? Icons.check_circle : Icons.upload_file,
                      color: _fileBytes != null ? Colors.green : const Color(0xFF1B4563), size: 30),
                  const SizedBox(height: 6),
                  Text(
                    _fileBytes != null ? (_fileName ?? 'تم اختيار الملف') : 'اضغطي لرفع صورة أو PDF',
                    style: TextStyle(
                        color: _fileBytes != null ? Colors.green : const Color(0xFF1B4563),
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: (_selected.isEmpty || _isIssuing) ? null : _issueSelected,
            child: Opacity(
              opacity: _selected.isEmpty ? 0.45 : 1.0,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                ),
                child: Center(
                  child: _isIssuing
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _selected.isEmpty
                              ? 'اختاري متدربين أولاً'
                              : allSelected
                                  ? 'إصدار الشهادات للجميع (${_selected.length})'
                                  : 'إصدار الشهادات للمحددين (${_selected.length})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.left)),
        ],
      ),
    );
  }
}

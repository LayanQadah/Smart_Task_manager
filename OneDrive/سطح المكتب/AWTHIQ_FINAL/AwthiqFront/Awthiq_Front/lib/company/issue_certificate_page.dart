import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class IssueCertificatePage extends StatefulWidget {
  const IssueCertificatePage({super.key});

  @override
  State<IssueCertificatePage> createState() => _IssueCertificatePageState();
}

class _IssueCertificatePageState extends State<IssueCertificatePage> {
  bool _bulkMode = false;

  final _uidCtrl   = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _dateCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();

  Uint8List? _fileBytes;
  String?    _fileName;
  bool       _loading = false;
  String?    _successMsg;
  String?    _errorMsg;
  String?    _issuedFileUrl;

  List<Map<String, dynamic>> _employees   = [];
  bool                       _loadingEmps = false;
  Set<String>                _selected    = {};

  @override
  void dispose() {
    _uidCtrl.dispose(); _titleCtrl.dispose();
    _dateCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
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

  Future<void> _openFile(String url) async {
    final isPdf = url.toLowerCase().contains('.pdf') || url.contains('/raw/upload/');
    final openUrl = isPdf
        ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}'
        : url;
    final uri = Uri.parse(openUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dateCtrl.text = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmps = true);
    final list = await ApiService.getCompanyEmployees();
    if (mounted) setState(() { _employees = list; _loadingEmps = false; });
  }

  void _switchMode(bool bulk) {
    setState(() {
      _bulkMode   = bulk;
      _errorMsg   = null;
      _successMsg = null;
      _selected   = {};
      if (bulk && _employees.isEmpty) _loadEmployees();
    });
  }

  Future<void> _submitSingle() async {
    final uid   = _uidCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final date  = _dateCtrl.text.trim();
    if (uid.isEmpty || title.isEmpty || date.isEmpty) {
      setState(() { _errorMsg = 'يرجى تعبئة الرقم التعريفي واسم الشهادة والتاريخ.'; _successMsg = null; });
      return;
    }
    setState(() { _loading = true; _errorMsg = null; _successMsg = null; _issuedFileUrl = null; });
    final result = await ApiService.issueCertificate(
      uniqueId: uid, title: title, issueDate: date,
      description: _descCtrl.text.trim(), fileBytes: _fileBytes, fileName: _fileName,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _loading = false;
        _successMsg  = 'تم إصدار الشهادة بنجاح وتوثيقها رقمياً ✓';
        _issuedFileUrl = result['file_url'];
        _errorMsg = null;
        _fileBytes = null; _fileName = null;
      });
      _uidCtrl.clear(); _titleCtrl.clear(); _dateCtrl.clear(); _descCtrl.clear();
    } else {
      setState(() { _loading = false; _errorMsg = result['error'] ?? 'حدث خطأ أثناء الإصدار.'; _successMsg = null; });
    }
  }

  Future<void> _submitBulk() async {
    final title = _titleCtrl.text.trim();
    final date  = _dateCtrl.text.trim();
    if (_selected.isEmpty) {
      setState(() => _errorMsg = 'يرجى تحديد موظف واحد على الأقل.');
      return;
    }
    if (title.isEmpty || date.isEmpty) {
      setState(() => _errorMsg = 'يرجى تعبئة اسم الشهادة والتاريخ.');
      return;
    }
    setState(() { _loading = true; _errorMsg = null; _successMsg = null; });
    final result = await ApiService.bulkIssueCertificate(
      uniqueIds: _selected.toList(),
      title: title, issueDate: date,
      description: _descCtrl.text.trim(),
      fileBytes: _fileBytes, fileName: _fileName,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      final errors = (result['errors'] as List?)?.cast<String>() ?? [];
      setState(() {
        _loading    = false;
        _successMsg = result['message'] ?? 'تم الإصدار بنجاح';
        if (errors.isNotEmpty) _successMsg = '$_successMsg\n${errors.join('\n')}';
        _errorMsg   = null;
        _selected   = {};
        _fileBytes  = null; _fileName = null;
      });
      _titleCtrl.clear(); _dateCtrl.clear(); _descCtrl.clear();
    } else {
      setState(() { _loading = false; _errorMsg = result['error'] ?? 'حدث خطأ.'; _successMsg = null; });
    }
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('إصدار شهادة لموظف',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 10),
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4563).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, size: 46, color: Color(0xFF1B4563)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        _modeTab('من قائمة موظفيك', true),
                        _modeTab('بالرقم التعريفي', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _bulkMode ? 'اختر الموظفين وبيانات الشهادة' : 'بيانات الموظف والشهادة',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                        ),
                        const SizedBox(height: 18),
                        if (!_bulkMode) _field('الرقم التعريفي للموظف *', 'AW-XXXXXXXX', _uidCtrl)
                        else _buildEmployeeList(),
                        _field('اسم الشهادة *', 'مثال: شهادة خبرة', _titleCtrl),
                        _datePicker(),
                        _field('الوصف أو التخصص (اختياري)', 'مثال: مهندس برمجيات', _descCtrl),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('صورة أو ملف الشهادة (اختياري)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _fileBytes != null ? const Color(0xFF1B4563) : Colors.grey.shade300,
                                width: _fileBytes != null ? 1.5 : 1,
                              ),
                            ),
                            child: _fileBytes != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _fileName!.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image_outlined,
                                        color: const Color(0xFF1B4563), size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(child: Text(_fileName!,
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF1B4563)),
                                          overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(() { _fileBytes = null; _fileName = null; }),
                                        child: const Icon(Icons.close, color: Colors.red, size: 18),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file_outlined, color: Color(0xFF7FA8E6), size: 20),
                                      SizedBox(width: 8),
                                      Text('اضغط لرفع صورة أو PDF',
                                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                            ]),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_successMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Row(children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_successMsg!, style: const TextStyle(color: Colors.green, fontSize: 13))),
                                ]),
                                if (_issuedFileUrl != null && _issuedFileUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _openFile(_issuedFileUrl!),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.open_in_new, color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text('فتح الشهادة', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        GestureDetector(
                          onTap: _loading ? null : (_bulkMode ? _submitBulk : _submitSingle),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.verified, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          _bulkMode
                                              ? 'إصدار الشهادة للمحددين (${_selected.length})'
                                              : 'إصدار الشهادة',
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FA8E6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'الشهادات الصادرة من شركتك تُوثَّق فوراً وتظهر في ملف الموظف.',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12, color: Color(0xFF1B4563)),
                          ),
                        ),
                        Icon(Icons.info_outline, color: Color(0xFF7FA8E6), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeTab(String label, bool isBulk) {
    final active = _bulkMode == isBulk;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(isBulk),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1B4563) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                  color: active ? Colors.white : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_loadingEmps) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF1B4563))),
      );
    }
    if (_employees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
          child: const Column(
            children: [
              Icon(Icons.group_off_outlined, color: Colors.grey, size: 36),
              SizedBox(height: 8),
              Text('لا توجد موظفون مسجلون', style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 4),
              Text('أضف موظفين من قسم "موظفو الشركة" أولاً',
                  style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selected.length == _employees.length) {
                      _selected = {};
                    } else {
                      _selected = _employees.map((e) => e['unique_id'] as String).toSet();
                    }
                  });
                },
                child: Text(
                  _selected.length == _employees.length ? 'إلغاء الكل' : 'تحديد الكل',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1B4563), fontWeight: FontWeight.bold),
                ),
              ),
              Text('اختر الموظفين (${_selected.length}/${_employees.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(height: 8),
          ...(_employees.map((emp) {
            final uid     = emp['unique_id'] as String? ?? '';
            final name    = emp['name']      as String? ?? '-';
            final photo   = emp['profile_photo'] as String?;
            final checked = _selected.contains(uid);
            return GestureDetector(
              onTap: () => setState(() { checked ? _selected.remove(uid) : _selected.add(uid); }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: checked ? const Color(0xFF1B4563).withValues(alpha: 0.07) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: checked ? const Color(0xFF1B4563) : Colors.transparent, width: 1.5),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: checked,
                      onChanged: (_) => setState(() { checked ? _selected.remove(uid) : _selected.add(uid); }),
                      activeColor: const Color(0xFF1B4563),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4563))),
                          Text(uid, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFF0F7FF),
                      backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
                      child: (photo == null || photo.isEmpty)
                          ? const Icon(Icons.person, color: Color(0xFF1B4563), size: 18)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('تاريخ الإصدار *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B4563))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF7FA8E6)),
                  const Spacer(),
                  Text(
                    _dateCtrl.text.isEmpty ? 'اختر التاريخ' : _dateCtrl.text,
                    style: TextStyle(fontSize: 13, color: _dateCtrl.text.isEmpty ? Colors.grey : const Color(0xFF1B4563)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

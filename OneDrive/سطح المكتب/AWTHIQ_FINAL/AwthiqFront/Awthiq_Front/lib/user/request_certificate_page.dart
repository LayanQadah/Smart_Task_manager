import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class RequestCertificatePage extends StatefulWidget {
  const RequestCertificatePage({super.key});

  @override
  State<RequestCertificatePage> createState() => _RequestCertificatePageState();
}

class _RequestCertificatePageState extends State<RequestCertificatePage> {
  final _titleController   = TextEditingController();
  final _issuerController  = TextEditingController();
  final _dateController    = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isLoading = false;

  Uint8List? _fileBytes;
  String?    _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() {
      _fileBytes = file.bytes!;
      _fileName  = file.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1B4563)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _issuerController.text.trim().isEmpty ||
        _dateController.text.trim().isEmpty) {
      _snack('يرجى تعبئة جميع الحقول', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final data = <String, String>{
      'title':       _titleController.text.trim(),
      'issuer_name': _issuerController.text.trim(),
      'issue_date':  _dateController.text.trim(),
      if (_websiteController.text.trim().isNotEmpty)
        'issuer_url': _websiteController.text.trim(),
    };
    final result = await ApiService.requestCertificate(
      data,
      fileBytes: _fileBytes,
      fileName:  _fileName,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      _snack('تم إرسال طلب التوثيق بنجاح', Colors.green);
      Navigator.pop(context);
    } else {
      _snack(result['error'] ?? 'خطأ في إرسال الطلب', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('طلب توثيق شهادة',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 15),
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
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'أدخل معلومات الشهادة بدقة ليتم مراجعتها وتوثيقها من قبل فريقنا.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14, color: Color(0xFF1B4563), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),
                  _field('اسم الشهادة / الدورة', _titleController, Icons.description),
                  _field('الجهة المصدرة للشهادة', _issuerController, Icons.business),
                  _field('الموقع الإلكتروني للجهة (اختياري)', _websiteController, Icons.language,
                      hint: 'https://example.com'),

                  // حقل التاريخ مع date picker
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('تاريخ الحصول',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'اضغط لاختيار التاريخ',
                          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF7FA8E6), size: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // حقل رفع الملف
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('صورة أو ملف الشهادة (اختياري)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _fileBytes != null ? const Color(0xFF7FA8E6) : Colors.grey.shade300,
                            width: _fileBytes != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                _fileName ?? 'اضغط لرفع صورة أو PDF',
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _fileBytes != null ? const Color(0xFF1B4563) : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              _fileBytes != null ? Icons.check_circle : Icons.upload_file,
                              color: _fileBytes != null ? Colors.green : const Color(0xFF7FA8E6),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_fileBytes != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() { _fileBytes = null; _fileName = null; }),
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        label: const Text('إزالة الملف', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ),

                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _submit,
                      child: Container(
                        width: 200, height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(height: 22, width: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('إرسال الطلب',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
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

  Widget _field(String label, TextEditingController c, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: Icon(icon, color: const Color(0xFF7FA8E6), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final _skillController = TextEditingController();
  bool _loading = false;

  Uint8List? _certBytes;
  String?    _certName;

  int?              _quizId;
  List<dynamic>     _questions = [];
  final Map<String, String> _answers = {};
  final Map<String, TextEditingController> _answerControllers = {};
  bool              _submitted = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _skillController.dispose();
    for (final c in _answerControllers.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    if (mounted) setState(() { _certBytes = bytes; _certName = xFile.name; });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    if (mounted) setState(() { _certBytes = file.bytes!; _certName = file.name; });
  }

  Future<void> _startTest() async {
    final name = _skillController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة اسم المهارة'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() { _loading = true; _questions = []; _quizId = null; _answers.clear(); _submitted = false; _result = null; });
    final res = await ApiService.startSkillTest(name, certBytes: _certBytes, certName: _certName);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      if (_certBytes != null) {
        if (res['skill_image'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ تم رفع الشهادة بنجاح'), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
          );
        } else {
          final err = res['upload_error'] ?? 'خطأ غير معروف';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✗ فشل رفع الشهادة: $err'), backgroundColor: Colors.red, duration: Duration(seconds: 6)),
          );
        }
      }
      setState(() {
        _quizId    = res['quiz_id'];
        _questions = res['questions'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في توليد الاختبار'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitAnswers() async {
    if (_quizId == null) return;
    setState(() => _loading = true);
    final res = await ApiService.submitSkillAnswers(_quizId!, _answers);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() { _submitted = true; _result = res['skill']; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في التقييم'), backgroundColor: Colors.red),
      );
    }
  }

  void _reset() {
    for (final c in _answerControllers.values) { c.dispose(); }
    _answerControllers.clear();
    setState(() {
      _quizId = null; _questions = []; _answers.clear();
      _submitted = false; _result = null;
      _skillController.clear(); _certBytes = null; _certName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted && _result != null) return _buildResult();
    if (_questions.isNotEmpty)         return _buildQuiz();
    return _buildStartScreen();
  }

  // ── شاشة البداية ─────────────────────────────────────────────────────────────
  Widget _buildStartScreen() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('إضافة مهارة مكتسبة:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              ),
              const SizedBox(height: 30),

              // ── اسم المهارة ──
              const Align(
                alignment: Alignment.centerRight,
                child: Text('اسم المهارة:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _skillController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'مثل: Python، إدارة المشاريع، التسويق...',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                ),
              ),
              const SizedBox(height: 24),

              // ── رفع شهادة (اختياري) ──
              const Align(
                alignment: Alignment.centerRight,
                child: Text('إرفاق شهادة داعمة (اختياري):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openCamera,
                      icon: const Icon(Icons.camera_alt, color: Color(0xFF1B4563)),
                      label: const Text('الكاميرا', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF0F5FF),
                        side: const BorderSide(color: Color(0xFF7FA8E6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open, color: Color(0xFF1B4563)),
                      label: const Text('من الجهاز', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF0F5FF),
                        side: const BorderSide(color: Color(0xFF7FA8E6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_certBytes != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() { _certBytes = null; _certName = null; }),
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_certName ?? '', overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),

              // ── زر بدء التقييم ──
              Container(
                width: 220, height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تقييم الذكاء الاصطناعي',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),

              // ── شرح الميداليات ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('سيتم تصنيف مستوى المهارة حسب الميدالية:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _medal(Icons.military_tech, 'خبير\n(ذهبي ≥85%)', Colors.amber),
                        _medal(Icons.military_tech, 'متقدم\n(فضي 60-84%)', Colors.grey),
                        _medal(Icons.military_tech, 'مبتدئ\n(برونزي <60%)', const Color(0xFF8B6914)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _medal(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 50, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)), textAlign: TextAlign.center),
      ],
    );
  }

  // ── شاشة الاختبار ─────────────────────────────────────────────────────────────
  Widget _buildQuiz() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _reset, child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
              Text('اختبار: ${_skillController.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length + 1,
            itemBuilder: (_, i) {
              if (i == _questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4563),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إرسال الإجابات', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                );
              }
              final q    = _questions[i];
              final qId  = '${q['id']}';
              final isChoice = q['type'] == 'multiple_choice';
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${i + 1}. ${q['question']}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                      const SizedBox(height: 12),
                      if (isChoice)
                        ...List<Widget>.from((q['options'] as List).map((opt) {
                          final optStr = opt.toString();
                          final letter = optStr.isNotEmpty ? optStr[0] : optStr;
                          return RadioListTile<String>(
                            value: letter,
                            groupValue: _answers[qId],
                            title: Text(optStr, textAlign: TextAlign.right),
                            onChanged: (v) => setState(() => _answers[qId] = v!),
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFF1B4563),
                          );
                        }))
                      else
                        TextField(
                          controller: _answerControllers.putIfAbsent(qId, () => TextEditingController()),
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          onChanged: (v) => _answers[qId] = v,
                          decoration: InputDecoration(
                            hintText: 'اكتب إجابتك هنا...',
                            filled: true, fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── شاشة النتيجة ──────────────────────────────────────────────────────────────
  Widget _buildResult() {
    final score    = _result?['score']       ?? 0;
    final medal    = _result?['medal_type']  ?? 'bronze';
    final feedback = _result?['ai_feedback'] ?? '';
    final hasCert  = (_result?['skill_image'] ?? '').toString().isNotEmpty;
    final color    = medal == 'gold' ? Colors.amber : medal == 'silver' ? Colors.grey : const Color(0xFF8B6914);
    final label    = medal == 'gold' ? 'ذهبي' : medal == 'silver' ? 'فضي' : 'برونزي';

    return Scrollbar(
      thumbVisibility: true,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(Icons.military_tech, size: 90, color: color),
                const SizedBox(height: 10),
                Text('ميدالية $label!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 10),
                Text('نتيجتك: $score%',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                if (hasCert) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 16),
                        SizedBox(width: 6),
                        Text('مهارة موثقة بشهادة', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (feedback.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('تقييم الذكاء الاصطناعي',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                            SizedBox(width: 6),
                            Icon(Icons.auto_awesome, color: Color(0xFF1B4563), size: 16),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(feedback, textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.7)),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4563),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('إضافة مهارة أخرى', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

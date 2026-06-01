import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class SkillsDashboardPage extends StatefulWidget {
  const SkillsDashboardPage({super.key});

  @override
  State<SkillsDashboardPage> createState() => _SkillsDashboardPageState();
}

class _SkillsDashboardPageState extends State<SkillsDashboardPage> {
  List<SkillModel> _skills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final skills = await ApiService.getSkills();
    if (mounted) setState(() { _skills = skills; _loading = false; });
  }

  Color _medalColor(String medal) {
    switch (medal) {
      case 'gold':   return Colors.amber;
      case 'silver': return Colors.grey.shade400;
      default:       return const Color(0xFF8B6914);
    }
  }

  String _medalLabel(String medal) {
    switch (medal) {
      case 'gold':   return 'ذهبي';
      case 'silver': return 'فضي';
      default:       return 'برونزي';
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'expert':       return 'خبير';
      case 'advanced':     return 'متقدم';
      case 'intermediate': return 'متوسط';
      default:             return 'مبتدئ';
    }
  }

  Future<void> _viewCertificate(String url) async {
    final isPdf = url.toLowerCase().contains('.pdf') || url.contains('/raw/upload/');
    final openUrl = isPdf
        ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}'
        : url;
    final uri = Uri.parse(openUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDetail(SkillModel skill) {
    final color = _medalColor(skill.medalType);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // رأس النافذة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                Navigator.pop(context);
                                final ok = await ApiService.deleteSkill(skill.id);
                                if (ok) _load();
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(skill.skillName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                            const SizedBox(width: 8),
                            Icon(Icons.military_tech, color: color, size: 28),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // النتيجة والشريط
                    Row(
                      children: [
                        Text('${skill.score}%',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: skill.score / 100,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // الميدالية والمستوى
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _chip(_levelLabel(skill.progressLevel), const Color(0xFF1B4563), const Color(0xFFE8F0FB)),
                        const SizedBox(width: 8),
                        _chip(_medalLabel(skill.medalType), color, color.withValues(alpha: 0.12)),
                        if (skill.skillImage != null && skill.skillImage!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _chip('موثق', Colors.blue, Colors.blue.shade50),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // عرض الشهادة إن وُجدت
                    if (skill.skillImage != null && skill.skillImage!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _viewCertificate(skill.skillImage!),
                          icon: const Icon(Icons.verified, color: Colors.blue),
                          label: const Text('عرض الشهادة الداعمة',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(color: Colors.blue.shade300),
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // فيدباك الذكاء الاصطناعي
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('تقييم الذكاء الاصطناعي',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                              SizedBox(width: 6),
                              Icon(Icons.auto_awesome, color: Color(0xFF1B4563), size: 18),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            skill.aiFeedback?.isNotEmpty == true
                                ? skill.aiFeedback!
                                : 'لا يوجد تقييم مفصّل لهذه المهارة.',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            const Text('لوحة المهارات المكتسبة:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
            const SizedBox(height: 30),

            if (_loading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)))
            else if (_skills.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Text('لم تضف أي مهارات بعد.\nاذهب لتبويب المهارات لإضافة مهارتك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: _skills.map((s) => _skillRow(s)).toList(),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _skillRow(SkillModel skill) {
    final color = _medalColor(skill.medalType);
    return InkWell(
      onTap: () => _showDetail(skill),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // النتيجة على اليسار
            Text('${skill.score}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 12),
            // شريط التقدم في المنتصف
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: skill.score / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // الاسم والميدالية على اليمين
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (skill.skillImage != null && skill.skillImage!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 12),
                            SizedBox(width: 3),
                            Text('موثق', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(Icons.military_tech, color: color, size: 22),
                    const SizedBox(width: 4),
                    Text(skill.skillName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  ],
                ),
                Text(_medalLabel(skill.medalType),
                    style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class SearchByIdPage extends StatefulWidget {
  final String? initialUid;
  const SearchByIdPage({super.key, this.initialUid});

  @override
  State<SearchByIdPage> createState() => _SearchByIdPageState();
}

class _SearchByIdPageState extends State<SearchByIdPage> {
  final TextEditingController idController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? _employee;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialUid != null) {
      idController.text = widget.initialUid!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSearch());
    }
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    if (idController.text.trim().isEmpty) return;
    setState(() { isLoading = true; _employee = null; _error = null; });
    final res = await ApiService.searchEmployeeById(idController.text.trim());
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() { _employee = res['employee']; isLoading = false; });
    } else {
      setState(() { _error = res['error']; isLoading = false; });
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('بحث بالرقم التعريفي',
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSearchInput(),
                if (isLoading)
                  const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF1B4563))),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                  ),
                if (_employee != null) _buildEmployeeProfileCard(),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text('الرقم التعريفي للموظف:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: idController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "AW-XXXXXXX",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              width: 120, height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
              ),
              child: const Center(child: Text('بحث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobStatusBadge(String? status) {
    if (status == null) return const SizedBox.shrink();
    final isSeeking = status == 'seeking';
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isSeeking
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isSeeking ? 'باحث عن عمل' : 'موظف',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSeeking ? Colors.orange.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildEmployeeProfileCard() {
    final emp = _employee!;
    final name = emp['full_name'] ?? '${emp['first_name'] ?? ''} ${emp['last_name'] ?? ''}'.trim();
    final uid = emp['unique_id'] ?? '';
    final nationalId = emp['national_id'] ?? '-';
    final phone = emp['phone_number'] ?? '-';
    final email = emp['email'] ?? '-';
    final String? jobStatus = emp['job_status'];
    final List skills    = emp['skills']        ?? [];
    final List certs     = emp['certificates']  ?? [];
    final List career = (emp['career_history'] as List? ?? [])
      ..sort((a, b) {
        final aEnd = (a as Map)['end_date'];
        final bEnd = (b as Map)['end_date'];
        if (aEnd == null && bEnd != null) return -1;
        if (aEnd != null && bEnd == null) return 1;
        return ((b['start_date'] ?? '') as String).compareTo((a['start_date'] ?? '') as String);
      });
    final List education = emp['education']      ?? [];

    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4563).withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                        Text("ID: $uid", style: const TextStyle(color: Color(0xFF7FA8E6), fontWeight: FontWeight.bold)),
                        _jobStatusBadge(jobStatus),
                      ],
                    ),
                    const SizedBox(width: 15),
                    const CircleAvatar(radius: 35, backgroundColor: Color(0xFFADCBE3), child: Icon(Icons.person, color: Colors.white, size: 40)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFADCBE3).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _infoRow('الهوية الوطنية:', nationalId),
                      _infoRow('رقم الجوال:', phone),
                      _infoRow('البريد الإلكتروني:', email),
                    ],
                  ),
                ),
              ),
              if (skills.isNotEmpty) ...[
                _buildSectionTitle('المهارات المكتسبة:'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Wrap(
                    spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
                    children: skills.map<Widget>((skill) {
                      final medal = skill['medal_type'] ?? '';
                      final Color medalColor = medal == 'gold'
                          ? Colors.amber
                          : medal == 'silver'
                              ? Colors.grey[400]!
                              : Colors.orange[800]!;
                      final score = skill['score'] ?? 0;
                      final level = skill['progress_level'] ?? '';
                      return Container(
                        width: 90,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: medalColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: medalColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, size: 36, color: medalColor),
                            const SizedBox(height: 5),
                            Text(skill['skill_name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)), textAlign: TextAlign.center),
                            if (level.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(level, style: TextStyle(fontSize: 10, color: medalColor, fontWeight: FontWeight.bold)),
                            ],
                            if (score > 0) ...[
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: score / 100,
                                backgroundColor: Colors.grey[200],
                                color: medalColor,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 2),
                              Text('$score%', style: TextStyle(fontSize: 9, color: medalColor)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              if (certs.isNotEmpty) ...[
                _buildSectionTitle('الشهادات الموثقة:'),
                ...certs.map<Widget>((cert) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Image.asset("assets/awlogo1.png", height: 40),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 12, color: Colors.green),
                                SizedBox(width: 4),
                                Text('موثقة', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(cert['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4563))),
                            const SizedBox(height: 4),
                            Text(cert['major'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(cert['issue_date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              if (career.isNotEmpty) ...[
                _buildSectionTitle('تاريخ التوظيف:'),
                ...career.map<Widget>((job) {
                  final isCurrent = job['end_date'] == null;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isCurrent ? Colors.green.withValues(alpha: 0.5) : Colors.grey[200]!,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(job['job_title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.green : const Color(0xFF1B4563))),
                            Text(job['company_name'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '${job['start_date'] ?? ''} – ${job['end_date'] ?? 'حتى الآن'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isCurrent ? Colors.green : Colors.grey,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.business_center, color: Color(0xFFADCBE3)),
                      ],
                    ),
                  );
                }),
              ],
              if (education.isNotEmpty) ...[
                _buildSectionTitle('التعليم:'),
                ...education.map<Widget>((edu) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(edu['degree'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                          if ((edu['field_of_study'] ?? '').isNotEmpty)
                            Text(edu['field_of_study'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if ((edu['institution'] ?? '').isNotEmpty)
                            Text(edu['institution'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if ((edu['graduation_year'] ?? '').isNotEmpty)
                            Text('${edu['graduation_year']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 15),
                      const Icon(Icons.school, color: Color(0xFFADCBE3)),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(label, style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
      ),
    );
  }
}

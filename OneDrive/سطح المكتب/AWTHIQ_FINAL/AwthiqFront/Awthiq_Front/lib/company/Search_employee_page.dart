import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class AwthiqApp extends StatelessWidget {
  const AwthiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'ScheherazadeNew'),
      home: const SearchByIdPage(),
    );
  }
}

class SearchByIdPage extends StatefulWidget {
  const SearchByIdPage({super.key});

  @override
  State<SearchByIdPage> createState() => _SearchByIdPageState();
}

class _SearchByIdPageState extends State<SearchByIdPage> {
  static const String baseUrl = "https://your-api.com";

  final TextEditingController idController = TextEditingController();

  bool showResult = false;
  bool isLoading = false;

  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> certificates = [];
  List<Map<String, dynamic>> jobs = [];

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parseSkills(dynamic raw) {
    final result = <Map<String, dynamic>>[];

    if (raw is List) {
      for (int i = 0; i < raw.length; i++) {
        final item = raw[i];

        if (item is Map) {
          result.add({
            "name": item["name"]?.toString() ?? "",
            "level": item["level"]?.toString() ?? _defaultSkillLevel(i),
          });
        } else {
          result.add({
            "name": item.toString(),
            "level": _defaultSkillLevel(i),
          });
        }
      }
    }

    return result;
  }

  List<Map<String, dynamic>> _parseCertificates(dynamic raw) {
    final result = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          result.add({
            "title": item["title"]?.toString() ?? "",
            "date": item["date"]?.toString() ?? "",
          });
        }
      }
    }

    return result;
  }

  List<Map<String, dynamic>> _parseJobs(dynamic raw) {
    final result = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          result.add({
            "title": item["title"]?.toString() ?? "",
            "company": item["company"]?.toString() ?? "",
            "date": item["date"]?.toString() ?? "",
          });
        }
      }
    }

    return result;
  }

  String _defaultSkillLevel(int index) {
    const levels = ["gold", "silver", "bronze"];
    return levels[index % levels.length];
  }

  void _resetState() {
    userData = null;
    skills = [];
    certificates = [];
    jobs = [];
  }

  Future<void> search() async {
    final enteredId = idController.text.trim();
    if (enteredId.isEmpty) return;

    setState(() {
      isLoading = true;
      showResult = false;
      _resetState();
    });

    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/user/$enteredId"),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final Map<String, dynamic> data = decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};

        final dynamic userRaw = data["user"];
        final Map<String, dynamic>? parsedUser = userRaw is Map
            ? Map<String, dynamic>.from(userRaw)
            : null;

        setState(() {
          userData = parsedUser;
          skills = _parseSkills(data["skills"]);
          certificates = _parseCertificates(data["certificates"]);
          jobs = _parseJobs(data["jobs"]);
          isLoading = false;
          showResult = true;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          userData = null;
          skills = [];
          certificates = [];
          jobs = [];
          isLoading = false;
          showResult = true;
        });
      } else {
        setState(() {
          userData = null;
          skills = [];
          certificates = [];
          jobs = [];
          isLoading = false;
          showResult = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في الخادم: ${response.statusCode}"),
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        showResult = true;
        _resetState();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("انتهت مهلة الاتصال")),
      );
    } on SocketException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        showResult = true;
        _resetState();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يوجد اتصال بالإنترنت")),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        showResult = true;
        _resetState();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFEAF8FB), Color(0xFFBFE3E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {},
                    ),
                    const Text(
                      "توثيق سريع، ثقة دائمة.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Image.asset("assets/awlogo1.png", width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "البحث عن موظف بالرقم التعريفي:",
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: idController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "AW-12345",
                                filled: true,
                                fillColor: const Color(0xFFF4F7FB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: search,
                              child: Container(
                                width: 250,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "بحث",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isLoading) const CircularProgressIndicator(),
                      if (showResult && userData == null)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "لا توجد بيانات",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (showResult && userData != null) ...[
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userData!["name"]?.toString() ?? ""),
                                  Text(
                                    "ID: ${userData!["id"]?.toString() ?? ""}",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildIdCard(),
                        const SizedBox(height: 15),
                        _buildSkillsCard(),
                        const SizedBox(height: 15),
                        _buildCertificatesButton(),
                        const SizedBox(height: 15),
                        _buildJobHistoryButton(),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 70,
                child: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    setState(() {
                      showResult = false;
                      _resetState();
                      idController.clear();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificatesButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CertificatesPage(
              certificates: certificates,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF0D3B50)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_forward_ios),
            Text("الشهادات الموثقة"),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D3B50)),
      ),
      child: Column(
        children: [
          _infoField(userData!["nationalId"]?.toString() ?? "", "الهوية الوطنية"),
          _infoField(userData!["phone"]?.toString() ?? "", "رقم الجوال"),
          _infoField(userData!["email"]?.toString() ?? "", "البريد الإلكتروني"),
          _infoField(userData!["education"]?.toString() ?? "", "المستوى التعليمي"),
          _infoField(userData!["job"]?.toString() ?? "", "الوظيفة"),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D3B50)),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "المهارات المكتسبة:",
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: skills.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد بيانات",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: skills.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final Map<String, dynamic> skill = entry.value;

                        final String level = skill["level"]?.toString() ??
                            _defaultSkillLevel(index);

                        Color color;
                        switch (level) {
                          case "gold":
                            color = Colors.amber;
                            break;
                          case "silver":
                            color = Colors.grey;
                            break;
                          case "bronze":
                            color = const Color(0xFFCD7F32);
                            break;
                          default:
                            color = Colors.orange;
                        }

                        return Column(
                          children: [
                            Icon(Icons.workspace_premium, color: color),
                            Text(skill["name"]?.toString() ?? ""),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHistoryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobHistoryPage(jobs: jobs),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0D3B50)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_forward_ios),
            Text("تاريخ التوظيف"),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String value, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value.isEmpty ? "لا توجد بيانات" : value),
          Text(": $label"),
        ],
      ),
    );
  }
}

class CertificatesPage extends StatelessWidget {
  final List<Map<String, dynamic>> certificates;

  const CertificatesPage({
    super.key,
    required this.certificates,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FDFF),
      appBar: AppBar(
        title: const Text("الشهادات الموثقة"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF073B55),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFBFD8FF),
                      Color(0xFF9DBBEF),
                      Color(0xFF7FA8E6),
                    ],
                    radius: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "الشهادات الموثقة:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF073B55),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCertificatesContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificatesContent() {
    if (certificates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "لا توجد بيانات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (certificates.length == 1) {
      final cert = certificates.first;
      return _certCard(
        cert["title"]?.toString() ?? "",
        cert["date"]?.toString() ?? "",
      );
    }

    final first = certificates[0];
    final second = certificates[1];
    final third = certificates.length > 2 ? certificates[2] : null;
    final extra = certificates.length > 3 ? certificates.sublist(3) : [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _certCard(
              first["title"]?.toString() ?? "",
              first["date"]?.toString() ?? "",
            ),
            _certCard(
              second["title"]?.toString() ?? "",
              second["date"]?.toString() ?? "",
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (third != null)
          _certCard(
            third["title"]?.toString() ?? "",
            third["date"]?.toString() ?? "",
          ),
        if (extra.isNotEmpty) ...[
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: extra.map((cert) {
              return _certCard(
                cert["title"]?.toString() ?? "",
                cert["date"]?.toString() ?? "",
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _certCard(String title, String date) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber),
            const SizedBox(height: 6),
            Text(
              title.isEmpty ? "لا توجد بيانات" : title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Text(
                  date.isEmpty ? "لا توجد بيانات" : date,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;

  const JobHistoryPage({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FDFF),
      appBar: AppBar(
        title: const Text("تاريخ التوظيف"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF073B55),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFEAF8FB),
              Color(0xFFBFE3E8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFBFD8FF),
                    Color(0xFF9DBBEF),
                    Color(0xFF7FA8E6),
                  ],
                  radius: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "تاريخ التوظيف:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF073B55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildJobsContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsContent() {
    if (jobs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "لا توجد بيانات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (jobs.length == 1) {
      final job = jobs.first;
      return _jobCard(
        job["title"]?.toString() ?? "",
        job["company"]?.toString() ?? "",
        job["date"]?.toString() ?? "",
      );
    }

    final first = jobs[0];
    final second = jobs[1];
    final third = jobs.length > 2 ? jobs[2] : null;
    final extra = jobs.length > 3 ? jobs.sublist(3) : [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _jobCard(
              first["title"]?.toString() ?? "",
              first["company"]?.toString() ?? "",
              first["date"]?.toString() ?? "",
            ),
            _jobCard(
              second["title"]?.toString() ?? "",
              second["company"]?.toString() ?? "",
              second["date"]?.toString() ?? "",
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (third != null)
          _jobCard(
            third["title"]?.toString() ?? "",
            third["company"]?.toString() ?? "",
            third["date"]?.toString() ?? "",
          ),
        if (extra.isNotEmpty) ...[
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: extra.map((job) {
              return _jobCard(
                job["title"]?.toString() ?? "",
                job["company"]?.toString() ?? "",
                job["date"]?.toString() ?? "",
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _jobCard(String title, String company, String date) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(Icons.work, color: Color(0xFF2F8BE8)),
            const SizedBox(height: 6),
            Text(
              title.isEmpty ? "لا توجد بيانات" : title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              company.isEmpty ? "لا توجد بيانات" : company,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Text(
                  date.isEmpty ? "لا توجد بيانات" : date,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
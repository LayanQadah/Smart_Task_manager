import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserModel.dart';

class ApiService {
  // لو بتشغلين على إيميولتر Android استخدمي 10.0.2.2 بدل 127.0.0.1
  // لو جهاز حقيقي استبدلي بـ IP جهازك مثل 192.168.1.5
  static const String baseUrl = "https://web-production-fd6c6.up.railway.app/api";

  // ── حفظ واسترجاع التوكن ──────────────────────────────────────────────────────

  static Future<void> saveSession(String token, String userType, String uniqueId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token',     token);
    await prefs.setString('user_type', userType);
    await prefs.setString('unique_id', uniqueId);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  static Future<String?> getUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('unique_id');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Headers المساعدة ─────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Token $token',
    };
  }

  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  // ── تسجيل الدخول ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login/"),
        headers: _jsonHeaders,
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        await saveSession(data['token'], data['user_type'], data['unique_id']);
        return {'success': true, 'user_type': data['user_type']};
      }
      return {'success': false, 'error': data['error'] ?? 'خطأ في تسجيل الدخول'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── إنشاء حساب ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register(String userType, Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register/$userType/"),
        headers: _jsonHeaders,
        body: jsonEncode(data),
      );
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201) {
        await saveSession(resData['token'], resData['user_type'], resData['unique_id']);
        return {'success': true, 'user_type': resData['user_type']};
      }
      // جمع أول خطأ من الـ response
      String errorMsg = 'خطأ في إنشاء الحساب';
      if (resData is Map) {
        final firstVal = resData.values.first;
        errorMsg = (firstVal is List) ? firstVal.first.toString() : firstVal.toString();
      }
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── نسيت كلمة المرور ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> checkUserForReset(String identifier) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/check-user/"),
        headers: _jsonHeaders,
        body: jsonEncode({'identifier': identifier}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'حدث خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> sendResetLink(String identifier, String method) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password/"),
        headers: _jsonHeaders,
        body: jsonEncode({'identifier': identifier, 'method': method}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'error': data['error'] ?? 'حدث خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordByToken(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password/"),
        headers: _jsonHeaders,
        body: jsonEncode({'token': token, 'new_password': newPassword}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'error': data['error'] ?? 'حدث خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String identifier, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password/"),
        headers: _jsonHeaders,
        body: jsonEncode({'identifier': identifier, 'code': code, 'new_password': newPassword}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'error': data['error'] ?? 'حدث خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تسجيل الخروج ─────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    try {
      final headers = await _authHeaders();
      await http.post(Uri.parse("$baseUrl/auth/logout/"), headers: headers);
    } catch (_) {}
    await clearSession();
  }

  // ── الملف الشخصي ─────────────────────────────────────────────────────────────

  static Future<ProfileModel?> getProfile() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/profile/"), headers: headers);
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, String> data, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('PATCH', Uri.parse("$baseUrl/profile/"));
      request.headers['Authorization'] = 'Token $token';
      data.forEach((key, value) => request.fields[key] = value);
      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes('profile_photo', imageBytes, filename: imageName));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) return {'success': true};
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      String errorMsg = 'خطأ في التعديل';
      if (resData is Map && resData.isNotEmpty) {
        final firstVal = resData.values.first;
        errorMsg = (firstVal is List) ? firstVal.first.toString() : firstVal.toString();
      }
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── السجل الوظيفي ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> addCareer(Map<String, String> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/profile/career/"),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) return {'success': true};
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': resData.toString()};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> editCareer(int id, Map<String, String> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl/profile/career/$id/"),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) return {'success': true};
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': resData.toString()};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<bool> deleteCareer(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/profile/career/$id/"),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ── التعليم ───────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> addEducation(Map<String, String> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/profile/education/"),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) return {'success': true};
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': resData.toString()};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<bool> deleteEducation(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/profile/education/$id/"),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ── الشهادات ─────────────────────────────────────────────────────────────────

  static Future<List<CertificateModel>> getCertificates() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/certificates/"), headers: headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => CertificateModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> requestCertificate(
    Map<String, String> data, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/certificates/requests/"));
      request.headers['Authorization'] = 'Token $token';
      data.forEach((key, value) => request.fields[key] = value);
      if (fileBytes != null && fileName != null) {
        final field = fileName.toLowerCase().endsWith('.pdf') ? 'file' : 'image';
        request.files.add(http.MultipartFile.fromBytes(field, fileBytes, filename: fileName));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) return {'success': true};
      return {'success': false, 'error': 'خطأ في إرسال الطلب'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── المهارات والاختبارات ──────────────────────────────────────────────────────

  static Future<bool> deleteSkill(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/skills/$id/"),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  static Future<List<SkillModel>> getSkills() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/skills/"), headers: headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => SkillModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> startSkillTest(
    String skillName, {
    Uint8List? certBytes,
    String?    certName,
  }) async {
    try {
      final token = await getToken();
      final req = http.MultipartRequest('POST', Uri.parse("$baseUrl/skills/"));
      req.headers['Authorization'] = 'Token $token';
      req.fields['skill_name'] = skillName;
      if (certBytes != null && certName != null) {
        req.files.add(http.MultipartFile.fromBytes('skill_image', certBytes, filename: certName));
      }
      final streamed = await req.send();
      final body     = await http.Response.fromStream(streamed);
      if (body.statusCode == 201) {
        final data = jsonDecode(utf8.decode(body.bodyBytes));
        return {
          'success':      true,
          'quiz_id':      data['quiz_id'],
          'questions':    data['questions'],
          'skill_image':  data['skill_image'],
          'upload_error': data['upload_error'],
        };
      }
      final err = jsonDecode(utf8.decode(body.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'خطأ في توليد الاختبار'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> submitSkillAnswers(int quizId, Map<String, String> answers) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/skills/$quizId/answer/"),
        headers: headers,
        body: jsonEncode({'answers': answers}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'skill': data['skill'], 'message': data['message']};
      }
      return {'success': false, 'error': 'خطأ في التقييم'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── التنبيهات ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/certificates/notifications/"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List notifs = data['notifications'] ?? [];
        return {
          'success': true,
          'unread_count': data['unread_count'] ?? 0,
          'notifications': notifs.map((e) => NotificationModel.fromJson(e)).toList(),
        };
      }
    } catch (_) {}
    return {'success': false, 'notifications': [], 'unread_count': 0};
  }

  static Future<void> markNotificationRead(int id) async {
    try {
      final headers = await _authHeaders();
      await http.post(Uri.parse("$baseUrl/certificates/notifications/$id/read/"), headers: headers);
    } catch (_) {}
  }

  // ── خدمات الشركة ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> searchEmployeeById(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/company/search/?uid=$uid"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'employee': jsonDecode(utf8.decode(response.bodyBytes))};
      }
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'لم يتم العثور على المستخدم'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> issueCertificate({
    required String uniqueId,
    required String title,
    required String issueDate,
    String description = '',
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/certificates/company/issue/"));
      request.headers['Authorization'] = 'Token $token';
      request.fields['unique_id']   = uniqueId;
      request.fields['title']       = title;
      request.fields['issue_date']  = issueDate;
      if (description.isNotEmpty) request.fields['description'] = description;
      if (fileBytes != null && fileName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', fileBytes, filename: fileName));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final fileUrl = data['certificate']?['image'] ?? '';
        return {'success': true, 'file_url': fileUrl};
      }
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final err  = data['error'] ?? data.values.first.toString();
        return {'success': false, 'error': err};
      } catch (_) {
        return {'success': false, 'error': 'خطأ من السيرفر (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'error': 'خطأ: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> searchEmployeesByAI(String requirements) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/company/search/ai/"),
        headers: headers,
        body: jsonEncode({'requirements': requirements}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'results': data['results'], 'count': data['count']};
      }
      return {'success': false, 'error': 'خطأ في البحث'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> updateEmployeeCareer(String uid, String jobTitle) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/company/career/$uid/update/"),
        headers: headers,
        body: jsonEncode({'job_title': jobTitle}),
      );
      if (response.statusCode == 200) return {'success': true};
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── الدورات التدريبية (للمؤسسات) ────────────────────────────────────────────

  static Future<List<CourseModel>> getCourses() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/certificates/company/courses/"), headers: headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => CourseModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> createCourse(Map<String, String> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/certificates/company/courses/"),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'course_id': res['course_id']};
      }
      return {'success': false, 'error': 'خطأ في إنشاء الدورة'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> enrollParticipant(int courseId, String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/certificates/company/courses/$courseId/enroll/"),
        headers: headers,
        body: jsonEncode({'unique_id': uid}),
      );
      if (response.statusCode == 201) return {'success': true};
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> issueAllCertificates(int courseId) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/certificates/company/courses/$courseId/issue-all/"),
      );
      request.headers['Authorization'] = 'Token $token';
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'message': data['message']};
      }
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'خطأ'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> issueCertificateToEmployee(Map<String, String> data) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/certificates/company/issue/"));
      request.headers['Authorization'] = 'Token $token';
      data.forEach((key, value) => request.fields[key] = value);
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) return {'success': true};
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      return {'success': false, 'error': err['error'] ?? 'خطأ في الإصدار'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تصدير CV ─────────────────────────────────────────────────────────────────

  static Future<String> getExportCVUrl({String lang = 'ar'}) async {
    final token = await getToken();
    return "$baseUrl/profile/export-cv/?token=$token&lang=$lang";
  }

  // ── لوحة تحكم الأدمن ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin-panel/login/"),
        headers: _jsonHeaders,
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        await saveSession(data['token'], 'admin', '');
        return {'success': true};
      }
      return {'success': false, 'error': data['error'] ?? 'خطأ في تسجيل الدخول'};
    } catch (e) {
      return {'success': false, 'error': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/admin-panel/stats/"), headers: headers);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return {};
  }

  static Future<List<dynamic>> getAdminRequests() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/admin-panel/requests/"), headers: headers);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return [];
  }

  static Future<bool> adminApproveRequest(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/admin-panel/requests/$id/approve/"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> adminRejectRequest(int id, String reason) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/admin-panel/requests/$id/reject/"),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> getAdminUsers() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/admin-panel/users/"), headers: headers);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return [];
  }

  static Future<bool> adminApproveUser(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/admin-panel/users/$id/approve/"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getAdminUserDetail(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/admin-panel/users/$id/detail/"), headers: headers);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getAdminCertificates() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse("$baseUrl/admin-panel/certificates/"), headers: headers);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return [];
  }

  static Future<bool> adminDeleteCertificate(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/admin-panel/certificates/$id/delete/"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

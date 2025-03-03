import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> getBookRecommendation(String userInput) async {
    if (apiKey.isEmpty) {
      return "❌ ไม่พบ API Key! กรุณาตรวจสอบไฟล์ .env";
    }

    const String model = "gemini-2.0-flash";  // ใช้โมเดลจาก Quickstart Guide
    final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent";

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": "ฉันต้องการคำแนะนำเกี่ยวกับหนังสือที่เกี่ยวข้องกับ: $userInput"}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('candidates') &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0].containsKey('content') &&
            data['candidates'][0]['content'].containsKey('parts') &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] ?? "ไม่สามารถแนะนำหนังสือได้";
        } else {
          return "❌ รูปแบบข้อมูลผิดพลาด: $data";
        }
      } else {
        return "❌ API Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "❌ มีข้อผิดพลาดในการเชื่อมต่อ API: $e";
    }
  }
}

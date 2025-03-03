import 'package:flutter/material.dart';
import '../services/chatbotService.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false; // เพิ่มตัวแปรสถานะโหลด

  void _getBookRecommendation() async {
    String userInput = _controller.text;
    if (userInput.isEmpty) return;

    setState(() {
      _isLoading = true; // เริ่มโหลด
      _response = ""; // ล้างข้อความเก่า
    });

    ChatbotService chatbotService = ChatbotService();
    String result = await chatbotService.getBookRecommendation(userInput);

    setState(() {
      _isLoading = false; // หยุดโหลด
      _response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📚 AI Chatbot แนะนำหนังสือ")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "พิมพ์คำถามเกี่ยวกับหนังสือ...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getBookRecommendation,
              child: Text("แนะนำหนังสือ 📖"),
            ),
            SizedBox(height: 20),

            // 🔥 แสดง Loading Indicator ขณะกำลังค้นหาข้อมูล
            if (_isLoading)
              Column(
                children: [
                  CircularProgressIndicator(), // แสดง Animation โหลด
                  SizedBox(height: 10),
                  Text(
                    "กำลังหาข้อมูล...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

            // 🔥 แสดงข้อความตอบกลับเมื่อ AI ตอบแล้ว
            if (!_isLoading && _response.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

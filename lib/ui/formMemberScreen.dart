import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/libraryProvider.dart';
import '../model/memberItem.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class FormMemberScreen extends StatefulWidget {
  const FormMemberScreen({super.key});

  @override
  State<FormMemberScreen> createState() => _FormMemberScreenState();
}

class _FormMemberScreenState extends State<FormMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController(); // ✅ เพิ่มช่องวันเกิด
  final phoneFormatter = FilteringTextInputFormatter.digitsOnly;
  String? selectedCategory;
  File? _imageFile; // ✅ ตัวแปรเก็บรูปภาพ

  final List<String> bookCategories = [
    "นิยายแฟนตาซี", "นิยายรัก", "วิทยาศาสตร์", "ประวัติศาสตร์", "การเงินและการลงทุน",
    "การพัฒนาตนเอง", "สุขภาพและโภชนาการ", "เทคโนโลยีและโปรแกรมมิ่ง", "ศิลปะและการออกแบบ", "ปรัชญาและศาสนา"
  ];

  // ✅ ฟังก์ชันเลือกวันเกิด
  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text = "${picked.day}/${picked.month}/${picked.year + 543}"; // แสดงปี พ.ศ.
      });
    }
  }

  // ✅ ฟังก์ชันเลือกไฟล์รูปภาพ
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสมาชิก')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ อัปโหลดรูปภาพโปรไฟล์
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("เลือกรูปภาพ"),
                ),
                const SizedBox(height: 20),

                // ✅ ช่องกรอกชื่อ
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "ชื่อ"),
                  validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
                ),
                const SizedBox(height: 10),


                // ✅ ช่องกรอกนามสกุล
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "นามสกุล"),
                  validator: (value) => value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
                ),
                const SizedBox(height: 10),

                // ✅ ช่องกรอกอีเมล + Validation
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "อีเมล"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "กรุณากรอกอีเมล";
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "รูปแบบอีเมลไม่ถูกต้อง";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // ✅ ช่องกรอกเบอร์โทร + Validation
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "เบอร์โทรศัพท์"),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    phoneFormatter,
                    LengthLimitingTextInputFormatter(10),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      String text = newValue.text.replaceAll(RegExp(r'\D'), ''); // ลบทุกอย่างที่ไม่ใช่ตัวเลข
                      if (text.length > 3 && text.length <= 6) {
                        text = '${text.substring(0, 3)}-${text.substring(3)}';
                      } else if (text.length > 6) {
                        text = '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}';
                      }
                      return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
                    }),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) return "กรุณากรอกเบอร์โทรศัพท์";
                    if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(value)) {
                      return "รูปแบบเบอร์โทรไม่ถูกต้อง (000-000-0000)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // ✅ ช่องกรอกวันเกิด
                TextFormField(
                  controller: birthDateController,
                  decoration: InputDecoration(
                    labelText: "วันเกิด (วัน/เดือน/ปี พ.ศ.)",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectBirthDate(context),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) => value!.isEmpty ? "กรุณาเลือกวันเกิด" : null,
                ),
                const SizedBox(height: 10),

                // ✅ Dropdown เลือกหมวดหมู่หนังสือที่สนใจ
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: bookCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: "หมวดหมู่หนังสือที่สนใจ"),
                  validator: (value) => value == null ? "กรุณาเลือกหมวดหมู่" : null,
                ),
                const SizedBox(height: 20),

                // ✅ ปุ่มบันทึกข้อมูล
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white, // ✅ ทำให้ฟอนต์เป็นสีขาว (อ่านง่ายขึ้น)
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // ✅ ทำให้ปุ่มดูพรีเมียม
                    shadowColor: Colors.black.withOpacity(0.2), // ✅ เพิ่มเงาให้ปุ่ม
                    elevation: 5,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var provider = Provider.of<LibraryProvider>(context, listen: false);
                      
                      MemberItem newMember = MemberItem(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: emailController.text,
                        phoneNumber: phoneController.text,
                        profilePic: _imageFile?.path,
                        birthDate: birthDateController.text, // ✅ บันทึกวันเกิด
                        favoriteCategory: selectedCategory, // ✅ บันทึกหมวดหมู่ที่สนใจ
                      );

                      await provider.addMember(newMember);
                      await provider.getLibraryCards();

                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: const Text("เพิ่มสมาชิก", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontFamily: 'Prompt',
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, // ✅ กำหนดสีฟอนต์เป็นสีขาว
                    )),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

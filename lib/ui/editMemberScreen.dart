import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/libraryProvider.dart';
import '../model/memberItem.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class EditMemberScreen extends StatefulWidget {
  final MemberItem member;

  const EditMemberScreen({super.key, required this.member});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final phoneFormatter = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.member.firstName;
    lastNameController.text = widget.member.lastName;
    emailController.text = widget.member.email;
    phoneController.text = widget.member.phoneNumber;
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  // ✅ ฟังก์ชันบันทึกข้อมูลสมาชิกที่แก้ไข
  Future<void> saveMember() async {
    if (_formKey.currentState!.validate()) {
      var provider = Provider.of<LibraryProvider>(context, listen: false);

      MemberItem updatedMember = MemberItem(
        id: widget.member.id,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        profilePic: _imageFile?.path ?? widget.member.profilePic,
      );

      await provider.updateMember(updatedMember); // ✅ ใช้ฟังก์ชันที่แก้ไขแล้ว
      await provider.getLibraryCards(); // ✅ โหลดข้อมูลใหม่ให้ UI อัปเดต

      if (context.mounted) {
        Navigator.pop(context, true); // ✅ ส่งค่ากลับให้ MainScreen อัปเดต UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขข้อมูลสมาชิก")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ✅ อัปโหลดรูปภาพ
              GestureDetector(
                onTap: _pickImage,
                child: Hero(
                  tag: "avatar_${widget.member.id}",
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : widget.member.profilePic != null
                            ? FileImage(File(widget.member.profilePic!))
                            : null,
                    child: _imageFile == null && widget.member.profilePic == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("เปลี่ยนรูปภาพ"),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "ชื่อ"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "นามสกุล"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "อีเมล"),
                validator: (value) {
                  if (value!.isEmpty) return "กรุณากรอกอีเมล";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "อีเมลไม่ถูกต้อง";
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "เบอร์โทรศัพท์"),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  phoneFormatter,
                  LengthLimitingTextInputFormatter(10),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text.replaceAll(RegExp(r'\D'), ''); 
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
                    return "รูปแบบเบอร์โทรไม่ถูกต้อง (XXX-XXX-XXXX)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white, // ✅ ทำให้ฟอนต์เป็นสีขาว (อ่านง่ายขึ้น)
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // ✅ ทำให้ปุ่มดูพรีเมียม
                    shadowColor: Colors.black.withOpacity(0.2), // ✅ เพิ่มเงาให้ปุ่ม
                    elevation: 5,
                  ),
                onPressed: saveMember, // ✅ เรียกฟังก์ชันบันทึกข้อมูล
                child: const Text("บันทึกข้อมูล",style: TextStyle(
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
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../provider/libraryProvider.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  
  /// ✅ ขอ Permission ก่อน Export
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  /// ✅ หาพาธที่ใช้บันทึกไฟล์ (Downloads)
  Future<String?> _getDownloadPath() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return "/storage/emulated/0/Download";
      }
    }
    Directory? directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  /// ✅ ฟังก์ชัน Export CSV
  Future<void> _exportToCSV() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ กรุณาอนุญาตให้แอปเข้าถึงที่เก็บไฟล์")),
      );
      return;
    }

    var provider = Provider.of<LibraryProvider>(context, listen: false);
    List<List<dynamic>> rows = [];

    // ✅ เพิ่ม Header
    rows.add(["ชื่อ", "นามสกุล", "อีเมล", "เบอร์โทร", "วันเกิด", "หมวดหมู่หนังสือ"]);

    // ✅ ดึงข้อมูลสมาชิก
    for (var member in provider.members) {
      rows.add([
        member.firstName,
        member.lastName,
        member.email,
        member.phoneNumber,
        member.birthDate,
        member.favoriteCategory ?? "ไม่มีข้อมูล",
      ]);
    }

    // ✅ สร้างไฟล์ CSV
    String csvData = const ListToCsvConverter().convert(rows);
    String? path = await _getDownloadPath();
    if (path != null) {
      final file = File("$path/members.csv");
      await file.writeAsString(csvData);

      // ✅ แจ้งเตือนผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ไฟล์ CSV ถูกบันทึกที่: $path/members.csv")),
      );
    }
  }

  /// ✅ ฟังก์ชัน Export Excel
  Future<void> _exportToExcel() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ กรุณาอนุญาตให้แอปเข้าถึงที่เก็บไฟล์")),
      );
      return;
    }

    var provider = Provider.of<LibraryProvider>(context, listen: false);
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['สมาชิก'];

    // ✅ เพิ่ม Header
    sheetObject.appendRow(["ชื่อ", "นามสกุล", "อีเมล", "เบอร์โทร", "วันเกิด", "หมวดหมู่หนังสือ"]);

    // ✅ ดึงข้อมูลสมาชิก
    for (var member in provider.members) {
      sheetObject.appendRow([
        member.firstName,
        member.lastName,
        member.email,
        member.phoneNumber,
        member.birthDate,
        member.favoriteCategory ?? "ไม่มีข้อมูล",
      ]);
    }

    // ✅ บันทึกไฟล์ Excel
    String? path = await _getDownloadPath();
    if (path != null) {
      final file = File("$path/members.xlsx");
      await file.writeAsBytes(excel.encode()!);

      // ✅ แจ้งเตือนผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ไฟล์ Excel ถูกบันทึกที่: $path/members.xlsx")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export ข้อมูลสมาชิก")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                bool hasPermission = await _requestStoragePermission();
                if (hasPermission) {
                  _exportToCSV();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ กรุณาอนุญาตให้แอปเข้าถึงที่เก็บไฟล์")),
                  );
                }
              },
              icon: const Icon(Icons.file_download),
              label: const Text("Export เป็น CSV"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                bool hasPermission = await _requestStoragePermission();
                if (hasPermission) {
                  _exportToExcel();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ กรุณาอนุญาตให้แอปเข้าถึงที่เก็บไฟล์")),
                  );
                }
              },
              icon: const Icon(Icons.file_download),
              label: const Text("Export เป็น Excel"),
            ),
          ],
        ),
      ),
    );
  }
}

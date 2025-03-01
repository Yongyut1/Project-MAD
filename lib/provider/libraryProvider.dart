import 'package:flutter/foundation.dart';
import '../database/libraryDB.dart';
import '../model/memberItem.dart';
import '../model/libraryCardItem.dart';

class LibraryProvider with ChangeNotifier {
  List<LibraryCardItem> libraryCards = [];
  List<MemberItem> members = [];

  Future<void> addMember(MemberItem member) async {
    var db = LibraryDB(dbName: 'library.db');
    int keyID = await db.insertMember(member);

    if (keyID != -1) {
      members.add(member);
      print("✅ สมาชิกถูกเพิ่มลงฐานข้อมูล: ${member.firstName} ${member.lastName}, ID: $keyID");

      // ✅ สร้างบัตรสมาชิกให้ผู้ใช้ใหม่
      DateTime issuedDate = DateTime.now();  // วันออกบัตร
      DateTime expiryDate = issuedDate.add(Duration(days: 365));  // เพิ่มวันหมดอายุ 1 ปี

      LibraryCardItem newCard = LibraryCardItem(
        cardNumber: "CARD-${DateTime.now().millisecondsSinceEpoch}",
        memberId: keyID.toString(),
        issuedDate: issuedDate,
        expiryDate: expiryDate,  
        status: "Active",
      );

      await db.insertLibraryCard(newCard); // ✅ เพิ่มบัตรลง Database
      print("✅ บัตรสมาชิกถูกสร้าง: ${newCard.cardNumber}");

      notifyListeners();
      await getLibraryCards(); // ✅ โหลดข้อมูลใหม่
    } else {
      print("❌ ไม่สามารถเพิ่มสมาชิกได้");
    }
  }




  Future<void> updateMember(MemberItem updatedMember) async {
    var db = LibraryDB(dbName: 'library.db');

    // ✅ อัปเดตฐานข้อมูล
    await db.updateMember(updatedMember);

    // ✅ โหลดข้อมูลสมาชิกใหม่
    await getLibraryCards();

    // 🔥 บังคับให้ UI รีเฟรช
    notifyListeners();
    print("🔄 กำลังอัปเดตสมาชิก: ${updatedMember.id}");

  }




  Future<void> getLibraryCards() async {
    var db = LibraryDB(dbName: 'library.db');
    
    libraryCards = await db.loadAllLibraryCards(); // ✅ โหลดบัตรสมาชิกใหม่
    members = await db.loadAllMembers(); // ✅ โหลดสมาชิกใหม่

    print("📜 มีสมาชิกทั้งหมด: ${members.length} คน");
    print("📜 มีบัตรสมาชิกทั้งหมด: ${libraryCards.length} ใบ");

    notifyListeners(); // 🔥 รีเฟรช UI ให้แน่ใจว่าค่าที่แสดงเป็นค่าล่าสุด
  }



   // ฟังก์ชันค้นหาบัตรสมาชิก
  void searchLibraryCards(String query) {
    if (query.isEmpty) {
      // ถ้าค้นหาเป็นค่าว่าง ให้แสดงข้อมูลทั้งหมด
      getLibraryCards();
    } else {
      // ค้นหาจากชื่อและนามสกุลของสมาชิก
      libraryCards = libraryCards.where((card) {
        final member = members.firstWhere((m) => m.id == card.memberId);
        final fullName = '${member.firstName} ${member.lastName}';
        return fullName.contains(query);  // ค้นหาคำในชื่อและนามสกุล
      }).toList();
      notifyListeners();  // รีเฟรชข้อมูล
    }
  }

  Future<void> filterLibraryCards({bool latest = true}) async {
    var db = LibraryDB(dbName: 'library.db');
    libraryCards = await db.loadAllLibraryCards();

    libraryCards.sort((a, b) =>
        latest ? b.issuedDate.compareTo(a.issuedDate) : a.issuedDate.compareTo(b.issuedDate));

    notifyListeners();
  }

  Future<void> deleteMember(String memberId) async {
    var db = LibraryDB(dbName: 'library.db');
    
    // ✅ ลบบัตรสมาชิกที่เกี่ยวข้องก่อน
    await db.deleteLibraryCardByMemberId(memberId);

    // ✅ ลบสมาชิก
    await db.deleteMemberById(memberId);

    // ✅ โหลดข้อมูลสมาชิกใหม่ (เพิ่มบรรทัดนี้)
    members = await db.loadAllMembers();

    // ✅ โหลดข้อมูลบัตรสมาชิกใหม่
    await getLibraryCards();

    // ✅ อัปเดต UI
    notifyListeners();
  }




}

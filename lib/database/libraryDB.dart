import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../model/libraryCardItem.dart';
import '../model/memberItem.dart';

class LibraryDB {
  String dbName;

  LibraryDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<void> insertLibraryCard(LibraryCardItem card) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('library_cards');

    int keyID = await store.add(db, {
      'cardNumber': card.cardNumber,
      'memberId': card.memberId,
      'issuedDate': card.issuedDate.toIso8601String(),
      'expiryDate': card.expiryDate.toIso8601String(),
      'status': card.status,
      'barcode': card.barcode,
      'qrCode': card.qrCode,
    });

    print("✅ บัตรสมาชิกถูกเพิ่มลงฐานข้อมูล: ${card.cardNumber}, ID: $keyID");
    db.close();
  }


  Future<int> insertMember(MemberItem member) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('members');

    int keyID = await store.add(db, {
      'firstName': member.firstName,
      'lastName': member.lastName,
      'email': member.email,
      'phoneNumber': member.phoneNumber, // ✅ เปลี่ยนจาก phone → phoneNumber
      'address': member.address,
      'profilePic': member.profilePic,
      'birthDate': member.birthDate, // ✅ เพิ่มวันเกิด
      'favoriteCategory': member.favoriteCategory, // ✅ เพิ่มหมวดหมู่ที่สนใจ
    });

    print("✅ เพิ่มสมาชิกสำเร็จ: ${member.firstName} ${member.lastName}, ID: $keyID");
    db.close();
    return keyID;
  }




  Future<void> updateMember(MemberItem member) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('members');

    await store.update(
      db,
      {
        'firstName': member.firstName,
        'lastName': member.lastName,
        'email': member.email,
        'phoneNumber': member.phoneNumber,
        'profilePic': member.profilePic,
        'birthDate': member.birthDate, // ✅ เพิ่มฟิลด์วันเกิด
        'favoriteCategory': member.favoriteCategory, // ✅ เพิ่มฟิลด์หมวดหมู่หนังสือ
      },
      finder: Finder(filter: Filter.equals(Field.key, int.parse(member.id))),
    );

    db.close();
  }



  Future<List<MemberItem>> loadAllMembers() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('members');

    var snapshot = await store.find(db,
        finder: Finder(sortOrders: [SortOrder('firstName', true)]));

    List<MemberItem> members = [];

    for (var record in snapshot) {
      MemberItem member = MemberItem(
        id: record.key.toString(),
        firstName: record['firstName'].toString(),
        lastName: record['lastName'].toString(),
        email: record['email'].toString(),
        phoneNumber: record['phoneNumber'].toString(),
        address: record['address'].toString(),
        profilePic: record['profilePic']?.toString(),
      );
      members.add(member);
    }
    db.close();
    return members;
  }

  Future<List<LibraryCardItem>> loadAllLibraryCards() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('library_cards');

    var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('issuedDate', false)]));

    List<LibraryCardItem> cards = [];

    for (var record in snapshot) {
      LibraryCardItem card = LibraryCardItem(
        id: record.key.toString(),
        cardNumber: record['cardNumber'].toString(),
        memberId: record['memberId'].toString(),
        issuedDate: DateTime.parse(record['issuedDate'].toString()),
        expiryDate: DateTime.parse(record['expiryDate'].toString()),
        status: record['status'].toString(),
        barcode: record['barcode']?.toString(),
        qrCode: record['qrCode']?.toString(),
      );
      cards.add(card);
    }
    db.close();
    return cards;
  }

  Future<List<LibraryCardItem>> searchLibraryCards({String? keyword}) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('library_cards');

    var finder = Finder(
      filter: keyword != null && keyword.isNotEmpty
          ? Filter.or([
              Filter.equals('cardNumber', keyword),  // ค้นหาจากหมายเลขบัตร
              Filter.equals('memberId', keyword),   // ค้นหาจากรหัสสมาชิก
            ])
          : null,
    );

    var snapshot = await store.find(db, finder: finder);
    List<LibraryCardItem> cards = snapshot.map((record) {
      return LibraryCardItem(
        id: record.key.toString(),
        cardNumber: record['cardNumber'].toString(),
        memberId: record['memberId'].toString(),
        issuedDate: DateTime.parse(record['issuedDate'].toString()),
        expiryDate: DateTime.parse(record['expiryDate'].toString()),
        status: record['status'].toString(),
        barcode: record['barcode']?.toString(),
        qrCode: record['qrCode']?.toString(),
      );
    }).toList();

    db.close();
    return cards;
  }

  Future<void> updateLibraryCardStatus(String cardId, String newStatus) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('library_cards');

    await store.update(
      db,
      {'status': newStatus},
      finder: Finder(filter: Filter.equals(Field.key, cardId)),
    );

    db.close();
  }

  Future<void> deleteLibraryCardByMemberId(String memberId) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('library_cards');

    await store.delete(
      db,
      finder: Finder(filter: Filter.equals('memberId', memberId)),
    );

    db.close();
  }

  Future<void> deleteMemberById(String memberId) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('members');

    await store.delete(
      db,
      finder: Finder(filter: Filter.equals(Field.key, memberId)),
    );

    db.close();
  }




}

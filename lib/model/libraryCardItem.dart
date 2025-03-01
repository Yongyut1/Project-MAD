import 'package:uuid/uuid.dart';

class LibraryCardItem {
  String id;
  String cardNumber;
  String memberId;
  DateTime issuedDate;
  DateTime expiryDate;
  String status;
  String? barcode;
  String? qrCode;

  LibraryCardItem({
    String? id,
    required this.cardNumber,
    required this.memberId,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    this.barcode,
    this.qrCode,
  }) : id = id ?? const Uuid().v4();
}

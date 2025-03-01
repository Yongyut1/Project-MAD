import 'package:uuid/uuid.dart';

class LibraryBranchItem {
  String id;
  String branchName;
  String location;
  String phone;

  LibraryBranchItem({
    String? id,
    required this.branchName,
    required this.location,
    required this.phone,
  }) : id = id ?? const Uuid().v4();
}

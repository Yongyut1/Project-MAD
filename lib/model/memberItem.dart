import 'package:uuid/uuid.dart';

class MemberItem {
  String id;
  String firstName;
  String lastName;
  String email;
  String phoneNumber; 
  String? address;
  String? profilePic;
  String? birthDate; 
  String? favoriteCategory; 

  MemberItem({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.profilePic,
    this.birthDate, 
    this.favoriteCategory, 
  }) : id = id ?? const Uuid().v4();
}

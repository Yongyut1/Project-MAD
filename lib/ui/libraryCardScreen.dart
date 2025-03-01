import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import '../model/libraryCardItem.dart';
import '../model/memberItem.dart';

class LibraryCardScreen extends StatefulWidget {
  final LibraryCardItem card;
  final MemberItem member;

  const LibraryCardScreen({super.key, required this.card, required this.member});

  @override
  State<LibraryCardScreen> createState() => _LibraryCardScreenState();
}

class _LibraryCardScreenState extends State<LibraryCardScreen> {
  bool _isFlipped = false; // ควบคุมสถานะบัตร

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บัตรสมาชิก')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isFlipped = !_isFlipped;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                builder: (context, child) {
                  final isUnder = (ValueKey(_isFlipped) != child!.key);
                  final value = isUnder ? pi * rotate.value : pi * (1 - rotate.value);
                  return Transform(
                    transform: Matrix4.rotationY(value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: child,
              );
            },
            child: _isFlipped ? _buildBackCard() : _buildFrontCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return _buildCardContent(
      key: const ValueKey(true),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: widget.member.profilePic != null
                    ? Image.file(File(widget.member.profilePic!), height: 60, width: 60, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.member.firstName} ${widget.member.lastName}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text("หมายเลขบัตร:",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(widget.card.cardNumber,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("📅 วันที่ออกบัตร:", _formatDate(widget.card.issuedDate)),
          _buildInfoRow("⏳ วันหมดอายุ:", _formatDate(widget.card.expiryDate)),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return _buildCardContent(
      key: const ValueKey(false),
      child: Center(
        child: QrImageView(data: widget.card.cardNumber, version: QrVersions.auto, size: 150.0),
      ),
    );
  }

  Widget _buildCardContent({required Widget child, required Key key}) {
    return Container(
      key: key,
      width: 320,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, spreadRadius: 2),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFB5EAEA), Color(0xFFFFD6E0)], // ✅ ฟ้าพาสเทล + ชมพูพาสเทล
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // ✅ ลด Blur ให้สีไม่เพี้ยน
          child: Container(
            color: Colors.white.withOpacity(0.3), // ✅ แก้ไขให้ตัวอักษรสีดำมองเห็นชัด
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // ✅ ลดช่องว่างให้ติดกันมากขึ้น
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd MMM yyyy', 'th').format(date); // ✅ ใช้ locale 'th' อย่างถูกต้อง
  }
}

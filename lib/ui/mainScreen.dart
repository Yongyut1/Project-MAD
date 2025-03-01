import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/libraryProvider.dart';
import '../ui/formMemberScreen.dart';
import '../ui/libraryCardScreen.dart';
import '../ui/editMemberScreen.dart';
import '../model/memberItem.dart';
import '../provider/themeProvider.dart';
import '../ui/statisticsScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<LibraryProvider>(context, listen: false).getLibraryCards());
  }

  TextEditingController searchController = TextEditingController();
  String filterOption = "ล่าสุด";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Member Card"),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).colorScheme.primary, // ใช้สีจาก Theme
        actions: [
          Switch(
            value:
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value);
            },
          ),
          PopupMenuButton<Color>(
            icon: const Icon(Icons.color_lens, color: Colors.white),
            onSelected: (color) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .updatePrimaryColor(color);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Color(0xFFFF85A2), // ชมพูพาสเทลเข้ม
                child: _buildColorCircle(const Color(0xFFFF85A2)),
              ),
              PopupMenuItem(
                value: const Color(0xFF53CDE2), // ฟ้าพาสเทลเข้ม
                child: _buildColorCircle(const Color(0xFF53CDE2)),
              ),
              PopupMenuItem(
                value: const Color(0xFFFFC056), // เหลืองพาสเทลเข้ม
                child: _buildColorCircle(const Color(0xFFFFC056)),
              ),
              PopupMenuItem(
                value: const Color(0xFFA585FF), // ม่วงพาสเทลเข้ม
                child: _buildColorCircle(const Color(0xFFA585FF)),
              ),
              PopupMenuItem(
                value: const Color(0xFF53E2AE), // เขียวพาสเทลเข้ม
                child: _buildColorCircle(const Color(0xFF53E2AE)),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onTap: () {
                Provider.of<LibraryProvider>(context, listen: false)
                    .searchLibraryCards(searchController.text);
              }, // ✅ ทำให้สามารถโฟกัสและกดได้
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.8),
                hintText: "ค้นหาชื่อสมาชิก...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ จัดให้อยู่คนละฝั่ง
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filterOption,
                      items: ["ล่าสุด", "เก่าสุด"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          filterOption = newValue!;
                          bool latest = (filterOption == "ล่าสุด");
                          Provider.of<LibraryProvider>(context, listen: false)
                              .filterLibraryCards(latest: latest);
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10), // ✅ เพิ่มระยะห่างระหว่างตัวกรองกับปุ่มสถิติ

              IconButton(
                icon: const Icon(Icons.bar_chart, size: 28), // ✅ ปรับขนาดปุ่ม
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
              ),
            ],
          ),const SizedBox(height: 10),
          Expanded(
            child: Consumer<LibraryProvider>(
              builder: (context, provider, child) {
                print(
                    "📜 จำนวนบัตรสมาชิกที่จะแสดง: ${provider.libraryCards.length}");

                return ListView.builder(
                  itemCount: provider.libraryCards.length,
                  itemBuilder: (context, index) {
                    final card = provider.libraryCards[index];
                    final member = provider.members
                        .firstWhere((m) => m.id == card.memberId);

                    return Card(
                      color: Theme.of(context).cardColor,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          "${member.firstName} ${member.lastName}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "หมายเลขบัตร: ${card.cardNumber}",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ ปุ่มแก้ไขข้อมูลสมาชิก
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditMemberScreen(member: member),
                                  ),
                                );

                                if (result == true) {
                                  // ✅ โหลดข้อมูลใหม่เมื่อมีการแก้ไขแน่นอน
                                  await Provider.of<LibraryProvider>(context,
                                          listen: false)
                                      .getLibraryCards();
                                  setState(() {}); // ✅ บังคับให้ UI อัปเดต
                                }
                              },
                            ),

                            // ✅ ปุ่มลบสมาชิก
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, provider, member);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LibraryCardScreen(
                                card: card,
                                member: member,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormMemberScreen(),
            ),
          );

          if (result == true) {
            print("🔄 กำลังโหลดข้อมูลใหม่...");
            await Provider.of<LibraryProvider>(context, listen: false)
                .getLibraryCards();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary, // ใช้สีตามธีม
      ),
    );
  }
  /// ฟังก์ชันช่วยสร้างวงกลมสี
Widget _buildColorCircle(Color color) {
  return Container(
    height: 24,
    width: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1), // ✅ ขอบสีขาวบางๆ ให้ดูน่ารักขึ้น
    ),
  );
}

  // ฟังก์ชันแสดงป๊อปอัพยืนยันการลบ
  void _showDeleteConfirmationDialog(
      BuildContext context, LibraryProvider provider, MemberItem member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการลบสมาชิก"),
          content: Text(
              "คุณต้องการลบสมาชิก ${member.firstName} ${member.lastName} หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดป๊อปอัพ
              },
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                provider.deleteMember(member.id); // ลบสมาชิก
                Navigator.of(context).pop(); // ปิดป๊อปอัพ
              },
              child: const Text("ยืนยัน"),
            ),
          ],
        );
      },
    );
  }
}

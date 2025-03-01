import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/libraryProvider.dart';
import 'exportImportScreen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<LibraryProvider>(context);

    // ✅ ใช้ Set เก็บ ID ของสมาชิกที่มีบัตร เพื่อป้องกันการนับผิด
    Set<String> membersWithCards = provider.libraryCards.map((c) => c.memberId).toSet();
    int totalMembers = membersWithCards.length; // ✅ นับเฉพาะสมาชิกที่มีบัตรจริงๆ
    int activeCards = provider.libraryCards.where((c) => c.status == "Active").length;
    int expiredCards = provider.libraryCards.where((c) => c.status == "Expired").length;

    // ✅ Debugging: ตรวจสอบจำนวนสมาชิก
    print("🔍 สมาชิกทั้งหมดที่มีบัตร: $totalMembers");
    print("✅ Active: $activeCards");
    print("❌ Expired: $expiredCards");

    return Scaffold(
      appBar: AppBar(title: const Text("📊 สถิติสมาชิก")),
      body: SingleChildScrollView(  // ✅ ทำให้สามารถเลื่อนขึ้น-ลงได้
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("สถิติสมาชิก", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // ✅ ใช้ ConstrainedBox จำกัดขนาดกราฟให้สมดุล
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 300, // ✅ กำหนดความสูงขั้นต่ำ
                  maxHeight: 500, // ✅ ป้องกันการกินพื้นที่มากเกินไป
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: totalMembers.toDouble(),
                            color: Colors.blue,
                            width: 25, 
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: activeCards.toDouble(),
                            color: Colors.green,
                            width: 25,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: expiredCards.toDouble(),
                            color: Colors.red,
                            width: 25,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text("ทั้งหมด"),
                                );
                              case 1:
                                return const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text("Active"),
                                );
                              case 2:
                                return const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text("Expired"),
                                );
                              default:
                                return Container();
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
                      },
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            "${rod.toY.toStringAsFixed(0)} คน",
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80), // ✅ 
              // ✅ ปุ่มไปยังหน้าส่งออกข้อมูล
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExportImportScreen()),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Export ข้อมูลสมาชิก"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

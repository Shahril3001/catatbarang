import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/note.dart';
import '../models/item.dart';
import '../providers/note_provider.dart';

class StatisticPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final List<Note> notes = noteProvider.notes;

    // Count items by type (ensure lowercase for consistency)
    Map<String, int> itemCountByType = {
      'buah': 0,
      'sayur': 0,
      'ikan': 0,
      'lain-lain': 0,
    };

    // Track sales for top 10 best-selling items
    Map<String, int> itemSales = {};
    Map<String, double> itemTotalValue = {};

    // Track total overall sales
    double totalSales = 0.0;

    // Track monthly sales
    Map<String, double> monthlySales = {};

    // Track daily sales
    Map<String, double> dailySales = {};

    for (var note in notes) {
      for (var item in note.items) {
        String typeKey = item.type.toLowerCase(); // Convert to lowercase

        itemCountByType[typeKey] =
            (itemCountByType[typeKey] ?? 0) + item.quantity;
        itemSales[item.name] = (itemSales[item.name] ?? 0) + item.quantity;
        itemTotalValue[item.name] =
            (itemTotalValue[item.name] ?? 0) + item.totalPrice;
        totalSales += item.totalPrice;

        // Extract month-year as key (e.g., "2025-02")
        String monthKey =
            DateFormat('yyyy-MM').format(DateTime.parse(note.notetitle));
        monthlySales[monthKey] =
            (monthlySales[monthKey] ?? 0) + item.totalPrice;

        // Extract day as key (e.g., "2025-02-15")
        String dayKey =
            DateFormat('yyyy-MM-dd').format(DateTime.parse(note.notetitle));
        dailySales[dayKey] = (dailySales[dayKey] ?? 0) + item.totalPrice;
      }
    }

    // Calculate average sales per day
    double averageSalesPerDay = totalSales / dailySales.length;
    double averageItemsPerDay =
        itemSales.values.reduce((a, b) => a + b) / dailySales.length;

    // Sort and get the top 10 best-selling items
    List<MapEntry<String, int>> topSellingItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topSellingItems = topSellingItems.take(10).toList();

    // Sort and get the top 10 items by total value
    List<MapEntry<String, double>> topValueItems = itemTotalValue.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topValueItems = topValueItems.take(10).toList();

    // Hitung penjualan minggu ini dan minggu lalu
    Map<String, double> thisWeekSales = calculateWeeklySales(notes, 0);
    Map<String, double> lastWeekSales = calculateWeeklySales(notes, -1);

    double totalThisWeekSales = thisWeekSales.values.fold(0, (a, b) => a + b);
    double totalLastWeekSales = lastWeekSales.values.fold(0, (a, b) => a + b);

    // Hitung penjualan bulan ini dan bulan lalu
    Map<String, double> thisMonthSales = calculateMonthlySales(notes, 0);
    Map<String, double> lastMonthSales = calculateMonthlySales(notes, -1);

    double totalThisMonthSales = thisMonthSales.values.fold(0, (a, b) => a + b);
    double totalLastMonthSales = lastMonthSales.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Statistik Penjualan",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalSalesCard(totalSales),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            _buildWeeklyComparisonCard(totalThisWeekSales, totalLastWeekSales),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            _buildMonthlyComparisonCard(
                totalThisMonthSales, totalLastMonthSales),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            _buildAverageSalesCard(averageSalesPerDay, averageItemsPerDay),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            Text("Jumlah Barang Mengikut Jenis", style: _sectionTitleStyle),
            _buildItemTypePieChart(itemCountByType),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            _buildItemTypeTable(
                itemCountByType, notes), // Tambahkan parameter notes
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            Text("10 Barang Paling Laris", style: _sectionTitleStyle),
            _buildTopSellingBarChart(topSellingItems),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            Text("10 Barang dengan Nilai Tertinggi", style: _sectionTitleStyle),
            _buildTopValueTable(topValueItems),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            Text("Jualan Bulanan", style: _sectionTitleStyle),
            _buildMonthlySalesChart(monthlySales),
            SizedBox(height: 12),
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 12),
            Text("Senarai Jualan", style: _sectionTitleStyle),
            _buildSalesDataTable(topSellingItems),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menghitung total penjualan mingguan
  Map<String, double> calculateWeeklySales(List<Note> notes, int weekOffset) {
    Map<String, double> weeklySales = {};

    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1 + weekOffset * 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (var note in notes) {
      DateTime noteDate = DateTime.parse(note.notetitle);
      if (noteDate.isAfter(startOfWeek) && noteDate.isBefore(endOfWeek)) {
        for (var item in note.items) {
          weeklySales[item.name] =
              (weeklySales[item.name] ?? 0) + item.totalPrice;
        }
      }
    }

    return weeklySales;
  }

  // Fungsi untuk menghitung total penjualan bulanan
  Map<String, double> calculateMonthlySales(List<Note> notes, int monthOffset) {
    Map<String, double> monthlySales = {};

    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month + monthOffset, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + monthOffset + 1, 0);

    for (var note in notes) {
      DateTime noteDate = DateTime.parse(note.notetitle);
      if (noteDate.isAfter(startOfMonth) && noteDate.isBefore(endOfMonth)) {
        for (var item in note.items) {
          monthlySales[item.name] =
              (monthlySales[item.name] ?? 0) + item.totalPrice;
        }
      }
    }

    return monthlySales;
  }

  // Widget untuk menampilkan perbandingan penjualan mingguan
  Widget _buildWeeklyComparisonCard(
      double thisWeekSales, double lastWeekSales) {
    double difference = thisWeekSales - lastWeekSales;
    String differenceText = difference >= 0
        ? "+BND\$${difference.toStringAsFixed(2)}"
        : "-BND\$${(-difference).toStringAsFixed(2)}";
    Color differenceColor = difference >= 0 ? Colors.green : Colors.red;

    return Center(
      child: Card(
        elevation: 1,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Perbandingan Penjualan Mingguan",
                  style: _sectionTitleStyle),
              SizedBox(height: 8),
              Text(
                "Minggu Ini: BND\$${thisWeekSales.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.purple),
              ),
              SizedBox(height: 8),
              Text(
                "Minggu Lalu: BND\$${lastWeekSales.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.purple),
              ),
              SizedBox(height: 8),
              Text(
                "Perbezaan: $differenceText",
                style: TextStyle(fontSize: 18, color: differenceColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan perbandingan penjualan bulanan
  Widget _buildMonthlyComparisonCard(
      double thisMonthSales, double lastMonthSales) {
    double difference = thisMonthSales - lastMonthSales;
    String differenceText = difference >= 0
        ? "+BND\$${difference.toStringAsFixed(2)}"
        : "-BND\$${(-difference).toStringAsFixed(2)}";
    Color differenceColor = difference >= 0 ? Colors.green : Colors.red;

    return Center(
      child: Card(
        elevation: 1,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Perbandingan Penjualan Bulanan", style: _sectionTitleStyle),
              SizedBox(height: 8),
              Text(
                "Bulan Ini: BND\$${thisMonthSales.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                "Bulan Lalu: BND\$${lastMonthSales.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                "Perbezaan: $differenceText",
                style: TextStyle(fontSize: 18, color: differenceColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAverageSalesCard(
      double averageSalesPerDay, double averageItemsPerDay) {
    return Center(
      child: Card(
        elevation: 1,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Purata Jualan Harian", style: _sectionTitleStyle),
              SizedBox(height: 8),
              Text(
                "BND\$${averageSalesPerDay.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 8),
              Text(
                "Purata Barang Terjual: ${averageItemsPerDay.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemTypeTable(
      Map<String, int> itemCountByType, List<Note> notes) {
    // Buat map untuk menyimpan total nilai harga per jenis barang
    Map<String, double> itemTypeTotalValue = {};

    for (var note in notes) {
      for (var item in note.items) {
        String typeKey =
            item.type.toLowerCase(); // Konversi ke lowercase untuk konsistensi
        itemTypeTotalValue[typeKey] =
            (itemTypeTotalValue[typeKey] ?? 0) + item.totalPrice;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Jenis Barang")),
          DataColumn(label: Text("Jumlah")),
          DataColumn(label: Text("Nilai (BND)")), // Kolom baru
        ],
        rows: itemCountByType.entries.map((entry) {
          return DataRow(cells: [
            DataCell(Text(entry.key.toUpperCase())), // Jenis barang
            DataCell(Text(entry.value.toString())), // Jumlah barang
            DataCell(Text(
                "\$${itemTypeTotalValue[entry.key]?.toStringAsFixed(2) ?? '0.00'}")), // Total nilai harga
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTopValueTable(List<MapEntry<String, double>> topValueItems) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Barang")),
          DataColumn(label: Text("Harga")),
        ],
        rows: topValueItems.map((entry) {
          return DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(Text("\$${entry.value.toStringAsFixed(2)}")),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildSalesDataTable(List<MapEntry<String, int>> topSellingItems) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Barang")),
          DataColumn(label: Text("Jumlah Terjual")),
        ],
        rows: topSellingItems.map((entry) {
          return DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(Text(entry.value.toString())),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSalesCard(double totalSales) {
    return Center(
      child: Card(
        elevation: 1,
        color: Colors.green.shade100,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Jumlah Keseluruhan Jualan", style: _sectionTitleStyle),
              SizedBox(height: 8),
              Text(
                "BND\$${totalSales.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemTypePieChart(Map<String, int> itemCountByType) {
    List<PieChartSectionData> sections = itemCountByType.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.key,
        color: _getCategoryColor(entry.key),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 50)),
    );
  }

  Widget _buildTopSellingBarChart(List<MapEntry<String, int>> topSellingItems) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: topSellingItems.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      topSellingItems[value.toInt()].key,
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySalesChart(Map<String, double> monthlySales) {
    List<BarChartGroupData> barGroups = monthlySales.entries.map((entry) {
      return BarChartGroupData(
        x: int.parse(entry.key.split('-')[1]),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.orange,
            width: 16,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String monthLabel = DateFormat.MMM().format(
                    DateTime(2025, value.toInt()),
                  );
                  return Text(monthLabel, style: TextStyle(fontSize: 12));
                },
                reservedSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'buah':
        return Colors.orangeAccent;
      case 'sayur':
        return Colors.green;
      case 'ikan':
        return Colors.blue;
      case 'lain-lain':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}

final _sectionTitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

import 'dart:io';
import 'package:catatbarang/db/hive_db.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'developer.dart';
import 'statistic_page.dart';
import 'user_guide.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_detail_page.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';
import '../utils/file_helper.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _sortOrder = "asc"; // "asc" for ascending, "desc" for descending
  bool _isExpanded = false;

  late AnimationController _sortAnimationController;

  // Pemetaan bulan ke bahasa Melayu
  final Map<int, String> _malayMonths = {
    1: "Januari",
    2: "Februari",
    3: "Mac",
    4: "April",
    5: "Mei",
    6: "Jun",
    7: "Julai",
    8: "Ogos",
    9: "September",
    10: "Oktober",
    11: "November",
    12: "Disember",
  };

  @override
  void initState() {
    super.initState();
    _sortAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
  }

  @override
  void dispose() {
    _sortAnimationController.dispose();
    super.dispose();
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == "asc" ? "desc" : "asc";
      _sortAnimationController.forward(from: 0);
    });
  }

  // Fungsi untuk mengelompokkan catatan berdasarkan tahun dan bulan
  Map<String, List<Note>> _groupNotesByYearMonth(List<Note> notes) {
    Map<String, List<Note>> groupedNotes = {};

    for (var note in notes) {
      try {
        // Ambil tanggal dari notetitle (asumsi notetitle adalah tanggal dalam format tertentu)
        DateTime date = DateFormat("yyyy-MM-dd").parse(note.notetitle);

        // Ambil tahun dan bulan
        int year = date.year;
        int month = date.month;

        // Dapatkan nama bulan dalam bahasa Melayu
        String monthName = _malayMonths[month] ?? "Bulan Tidak Diketahui";

        // Format grup sebagai "Tahun Bulan" (contoh: "2023 Oktober")
        String yearMonth = "$monthName $year";

        if (!groupedNotes.containsKey(yearMonth)) {
          groupedNotes[yearMonth] = [];
        }
        groupedNotes[yearMonth]!.add(note);
      } catch (e) {
        // Jika parsing gagal, abaikan catatan ini
        print("Error parsing date: ${note.notetitle}");
      }
    }

    return groupedNotes;
  }

  int countNotesInMonth(String yearMonth, List<Note> notes) {
    List<String> parts = yearMonth.split(" ");
    if (parts.length != 2) return 0;

    // Karena yearMonth diformat sebagai "NamaBulan Tahun"
    String monthName = parts[0];
    int year = int.tryParse(parts[1]) ?? DateTime.now().year;

    Map<String, int> monthMap = {
      "Januari": 1,
      "Februari": 2,
      "Mac": 3,
      "April": 4,
      "Mei": 5,
      "Jun": 6,
      "Julai": 7,
      "Ogos": 8,
      "September": 9,
      "Oktober": 10,
      "November": 11,
      "Disember": 12,
    };

    int month = monthMap[monthName] ?? DateTime.now().month;

    // Hitung jumlah catatan dalam bulan & tahun ini
    return notes.where((note) {
      DateTime date = DateTime.parse(note.notetitle); // Asumsi: "YYYY-MM-DD"
      return date.year == year && date.month == month;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    // Filter notes based on search query
    List<Note> filteredNotes = noteProvider.notes
        .where((note) =>
            note.notetitle.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort notes based on title
    filteredNotes.sort((a, b) => _sortOrder == "asc"
        ? a.notetitle.compareTo(b.notetitle)
        : b.notetitle.compareTo(a.notetitle));

    // Kelompokkan catatan berdasarkan tahun dan bulan
    Map<String, List<Note>> groupedNotes =
        _groupNotesByYearMonth(filteredNotes);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Senarai Nota",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: RotationTransition(
              turns:
                  Tween(begin: 0.0, end: 0.5).animate(_sortAnimationController),
              child: Icon(
                _sortOrder == "asc" ? Icons.sort_by_alpha : Icons.sort,
                size: 28,
              ),
            ),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF123456), // Extracted from the image background
              ),
              child: Center(
                // Center everything
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/logo.png", // Make sure this is the correct path
                      height: 100, // Adjust as needed
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Catat Barang 1.0.0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.amber[700]),
              title: Text("Beranda"),
              onTap: () => Navigator.pop(context), // Close drawer
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.teal),
              title: Text("Tatacara Guna"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserGuidePage()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.query_stats_sharp, color: Colors.green.shade400),
              title: Text("Statistik"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatisticPage()),
                );
              },
            ),
            ExpansionTile(
              backgroundColor:
                  Colors.transparent, // Tidak ada background saat diperluas
              collapsedBackgroundColor: Colors.transparent,
              leading:
                  Icon(Icons.storage, color: Colors.blueGrey), // Ikon kategori
              title: Text("Kelola Data"),
              children: [
                ListTile(
                  leading: Icon(Icons.file_upload, color: Colors.blue),
                  title: Text("Impor Data"),
                  onTap: () {
                    Navigator.pop(context);
                    FileHelper.importNotes(context); // Panggil fungsi import
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_download, color: Colors.orange),
                  title: Text("Ekspor Data"),
                  onTap: () {
                    Navigator.pop(context);
                    FileHelper.exportNotes(context); // Panggil fungsi export
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text("Padam Semua Data"),
                  onTap: () async {
                    bool confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Pengesahan"),
                          content: Text(
                              "Adakah anda pasti mahu memadam semua data? Tindakan ini tidak boleh dibuat asal."),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false), // Batal
                              child: Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true), // Padam
                              child: Text("Padam",
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      await HiveDB
                          .clearAllNotes(); // Panggil fungsi untuk hapus semua catatan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Semua data telah dipadam.")),
                      );
                    }
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.purple),
              title: Text("Pengembang"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeveloperPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: Text("Keluar"),
              onTap: () async {
                bool? confirmExit = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Sahkan Keluar"),
                    content:
                        Text("Adakah anda pasti mahu keluar dari aplikasi?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: Text("Keluar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirmExit == true) {
                  Navigator.pop(context); // Close drawer
                  Future.delayed(Duration(milliseconds: 300), () {
                    SystemNavigator.pop();
                    exit(0); // Exit the app properly
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar with Rounded Borders
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Tarikh...",
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                      color: Colors.grey[300]!), // Border line grey[100]
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                      color: Colors.blueAccent), // Slightly darker when focused
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Note List with Expansion Tiles
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              children: groupedNotes.entries.map((entry) {
                String yearMonth = entry.key;
                List<Note> notes = entry.value;

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1, // Soft shadow effect
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor:
                          Colors.transparent, // Remove default divider
                    ),
                    child: ExpansionTile(
                      tilePadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      collapsedBackgroundColor: Colors.white10,
                      backgroundColor: Color(0xFFF5F5F5),
                      collapsedIconColor: Color(0xFF123456),
                      iconColor: Color(0xFF123456),
                      collapsedTextColor: Colors.grey[900],
                      textColor: Color(0xFF123456),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), // Warna teks saat tertutup
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, // Light red background
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month,
                            color: Color(0xFF123456)),
                      ),
                      title: Text(
                        yearMonth, // Format: "2023 Oktober"
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        "Jumlah nota: ${countNotesInMonth(yearMonth, notes)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      children: notes.map((note) {
                        return Column(
                          children: [
                            Slidable(
                              key: Key(note.id),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  // Edit Button
                                  SlidableAction(
                                    onPressed: (context) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditNotePage(note: note),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Kemaskini',
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  // Delete Button
                                  SlidableAction(
                                    onPressed: (context) async {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Sahkan Hapus?"),
                                          content: Text(
                                              "Apakah anda yakin ingin menghapus nota ini?"),
                                          actions: [
                                            TextButton(
                                              child: Text("Batal"),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                              child: Text("Hapus",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete) {
                                        noteProvider.deleteNote(note.id);
                                      }
                                    },
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Hapus',
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ],
                              ),
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 1), // Proper spacing
                                elevation: 1, // Softer shadow
                                color:
                                    Colors.white, // Ensure a clear background
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  tileColor: Colors.white54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber.withOpacity(
                                          0.2), // Light background for icon
                                    ),
                                    padding: EdgeInsets.all(
                                        10), // Padding for circular effect
                                    child: Icon(
                                      Icons.shopping_basket,
                                      color: Colors.amber,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    note.notetitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        "Harga: BND\$${note.totalPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green.shade400,
                                        ),
                                      ),
                                      Text(
                                        "${note.items.length} Barang", // Display total items
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NoteDetailPage(note: note),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Divider(indent: 16, endIndent: 16, thickness: 0.1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: 30, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNotePage()),
          );
        },
      ),
    );
  }
}

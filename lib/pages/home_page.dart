// Mengimpor pustaka dart:io untuk mengelola file lokal (misalnya gambar catatan)
import 'dart:io';

// Mengimpor paket Flutter Material untuk membangun antarmuka pengguna Material Design
import 'package:flutter/material.dart';

// Mengimpor model catatan
import '../models/note.dart';

// Mengimpor layanan penyimpanan lokal untuk memuat dan menyimpan catatan
import '../services/storage_service.dart';

// Mengimpor widget tampilan kartu catatan
import '../widgets/note_card.dart';

// Mengimpor halaman untuk menambah atau mengedit catatan
import 'add_edit_note_page.dart';

// Mengimpor halaman galeri yang menampilkan daftar gambar dari catatan
import 'gallery_page.dart';


/// Halaman utama aplikasi (Home Page) untuk menampilkan daftar catatan pengguna.
///
/// Halaman ini memiliki beberapa fitur:
/// - Menampilkan daftar catatan yang disimpan secara lokal.
/// - Menambah, mengedit, dan menghapus catatan.
/// - Menampilkan gambar dari catatan.
/// - Menyediakan tab navigasi untuk berpindah antara Home, Tambah, dan Galeri.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State dari [HomePage] yang menangani logika utama seperti
/// pemuatan data, penyimpanan, penghapusan, dan navigasi antar-tab.
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  /// Daftar catatan yang dimuat dari penyimpanan lokal.
  List<Note> _notes = [];

  /// Indeks tab saat ini di BottomNavigationBar.
  int _currentIndex = 0;

  /// Indikator apakah data sedang dimuat.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(); // Memuat data catatan saat halaman pertama kali dibuka
  }

  /// Memuat semua catatan dari [StorageService] dan memperbarui tampilan.
  Future<void> _load() async {
    final loaded = await StorageService.loadNotes();
    setState(() {
      // Mengurutkan catatan berdasarkan tanggal terbaru
      _notes = loaded..sort((a, b) => b.datetime.compareTo(a.datetime));
      _loading = false;
    });
  }

  /// Menyimpan daftar catatan saat ini ke penyimpanan lokal.
  Future<void> _persist() async {
    await StorageService.saveNotes(_notes);
  }

  /// Menambah atau mengedit catatan menggunakan halaman [AddEditNotePage].
  ///
  /// Jika parameter [edit] diberikan, maka fungsi akan membuka halaman edit.
  /// Jika tidak, maka membuka halaman tambah catatan baru.
  Future<void> _addOrEdit({Note? edit}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditNotePage(initial: edit)),
    );

    // Jika ada hasil dari halaman edit/tambah
    if (result != null && result is Note) {
      setState(() {
        if (edit != null) {
          // Mengganti catatan lama dengan versi baru
          final idx = _notes.indexWhere((n) => n.id == edit.id);
          if (idx != -1) _notes[idx] = result;
        } else {
          // Menambahkan catatan baru ke daftar
          _notes.insert(0, result);
        }
      });
      await _persist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tersimpan')),
      );
    }
  }

  /// Menghapus satu catatan [n] dari daftar setelah konfirmasi pengguna.
  Future<void> _delete(Note n) async {
    // Menampilkan dialog konfirmasi hapus
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus?'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok != true) return;

    // Menghapus catatan dari daftar
    setState(() => _notes.removeWhere((e) => e.id == n.id));

    // Jika catatan memiliki gambar, hapus juga file gambar dari penyimpanan
    if (n.imagePath != null) await StorageService.deleteImage(n.imagePath!);

    await _persist();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data dihapus')),
    );
  }

  /// Membangun tampilan utama halaman Home yang menampilkan daftar catatan.
  Widget _buildHome() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _notes.isEmpty
                    ? const Center(
                        key: ValueKey('empty'),
                        child: Text('Belum ada catatan. Tekan + untuk menambah.'),
                      )
                    : ListView.builder(
                        key: const ValueKey('list'),
                        itemCount: _notes.length,
                        itemBuilder: (context, idx) {
                          final n = _notes[idx];
                          return NoteCard(
                            note: n,
                            // Menampilkan dialog detail catatan saat kartu ditekan
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(n.title),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (n.imagePath != null && File(n.imagePath!).existsSync())
                                        Image.file(File(n.imagePath!))
                                      else if (n.imagePath != null)
                                        Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(n.description),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onEdit: () => _addOrEdit(edit: n),
                            onDelete: () => _delete(n),
                          );
                        },
                      ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman untuk navigasi bawah (BottomNavigationBar)
    final pages = [
      _buildHome(), // Tab Home
      // Tab placeholder untuk Tambah Catatan
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_box, size: 64),
            SizedBox(height: 8),
            Text('Tab Tambah Catatan - Gunakan tombol +'),
          ],
        ),
      ),
      // Tab Galeri untuk menampilkan gambar-gambar catatan
      GalleryPage(notes: _notes),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Journal'),
        actions: [
          // Tombol untuk memuat ulang data
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),

          // Menu tambahan (popup)
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                // Konfirmasi hapus semua catatan
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hapus semua?'),
                    content: const Text('Semua catatan akan dihapus.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                    ],
                  ),
                );

                // Hapus semua catatan dan gambar
                if (ok == true) {
                  for (var n in _notes) {
                    if (n.imagePath != null) await StorageService.deleteImage(n.imagePath!);
                  }
                  setState(() => _notes.clear());
                  await _persist();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua catatan dihapus')),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Hapus semua')),
            ],
          ),
        ],
      ),

      // Menampilkan halaman sesuai tab yang aktif
      body: pages[_currentIndex],

      // Navigasi bawah untuk berpindah antar-tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galeri'),
        ],
      ),

      // Tombol mengambang untuk menambah catatan baru
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

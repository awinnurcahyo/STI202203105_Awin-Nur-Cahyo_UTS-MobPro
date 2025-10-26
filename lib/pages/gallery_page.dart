// Mengimpor pustaka dart:io untuk mengakses file lokal (misalnya gambar)
import 'dart:io';

// Mengimpor paket Flutter Material untuk membuat antarmuka pengguna
import 'package:flutter/material.dart';

// Mengimpor model Note yang berisi data catatan termasuk path gambar
import '../models/note.dart';


/// Halaman galeri yang menampilkan semua gambar dari catatan.
///
/// [GalleryPage] menampilkan kumpulan gambar yang tersimpan di setiap catatan
/// dalam bentuk **grid 3 kolom**. Jika catatan tidak memiliki gambar,
/// halaman akan menampilkan teks “Tidak ada foto”.
///
/// Fitur:
/// - Menampilkan seluruh gambar dari daftar catatan.
/// - Menampilkan dialog berisi gambar dan judul saat gambar diklik.
class GalleryPage extends StatelessWidget {
  /// Daftar catatan yang akan ditampilkan (digunakan untuk mengambil gambar dari masing-masing catatan)
  final List<Note> notes;

  /// Konstruktor [GalleryPage] dengan parameter wajib [notes].
  const GalleryPage({Key? key, required this.notes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter daftar catatan yang memiliki gambar (imagePath tidak null)
    final imgs = notes.where((n) => n.imagePath != null).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: imgs.isEmpty
            // Jika tidak ada gambar, tampilkan teks penanda
            ? const Center(child: Text('Tidak ada foto'))

            // Jika ada gambar, tampilkan dalam bentuk grid
            : GridView.builder(
                // Grid dengan 3 kolom, jarak antar gambar 8 piksel
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: imgs.length,
                itemBuilder: (context, idx) {
                  final n = imgs[idx];
                  return GestureDetector(
                    // Saat gambar ditekan, tampilkan dialog dengan gambar dan judul
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Menampilkan gambar catatan
                            Image.file(File(n.imagePath!)),

                            // Menampilkan judul catatan di bawah gambar
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(n.title),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Menampilkan gambar dalam grid dengan sudut melengkung
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(n.imagePath!),
                        fit: BoxFit.cover, // Gambar memenuhi kotak tampilan
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

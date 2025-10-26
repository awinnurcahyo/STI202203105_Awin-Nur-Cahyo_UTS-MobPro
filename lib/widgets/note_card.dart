// Mengimpor paket Flutter Material untuk membangun antarmuka pengguna berbasis Material Design
import 'package:flutter/material.dart';

// Mengimpor model Note yang berisi struktur data untuk catatan
import '../models/note.dart';

// Mengimpor pustaka dart:io untuk membaca file gambar dari penyimpanan lokal
import 'dart:io';


/// Widget stateless yang merepresentasikan tampilan satu kartu catatan (Note)
/// 
/// [NoteCard] menampilkan judul, deskripsi singkat, tanggal, serta gambar (jika ada).
/// Juga menyediakan menu popup untuk mengedit atau menghapus catatan.
///
/// Parameter:
/// - [note]: objek `Note` yang berisi data catatan.
/// - [onTap]: fungsi callback saat kartu ditekan.
/// - [onEdit]: fungsi callback saat menu "Edit" dipilih.
/// - [onDelete]: fungsi callback saat menu "Delete" dipilih.
class NoteCard extends StatelessWidget {
  /// Objek catatan yang akan ditampilkan
  final Note note;

  /// Callback ketika kartu ditekan
  final VoidCallback onTap;

  /// Callback ketika opsi edit dipilih
  final VoidCallback onEdit;

  /// Callback ketika opsi delete dipilih
  final VoidCallback onDelete;

  /// Konstruktor NoteCard dengan parameter wajib [note], [onTap], [onEdit], dan [onDelete].
  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan bentuk dan efek bayangan pada kartu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        // Menangani aksi tap pada seluruh area kartu
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Jika catatan memiliki gambar, tampilkan gambar tersebut
              if (note.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(note.imagePath!), // Membaca gambar dari path lokal
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                )
              // Jika tidak ada gambar, tampilkan ikon placeholder
              else
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.note, size: 36),
                ),

              const SizedBox(width: 12),

              // Bagian teks: judul, deskripsi, dan tanggal catatan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul catatan
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Deskripsi singkat, maksimal 2 baris
                    Text(
                      note.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Waktu dan tanggal catatan dalam format dd/mm/yyyy hh:mm
                    Text(
                      '${note.datetime.day}/${note.datetime.month}/${note.datetime.year} '
                      '${note.datetime.hour.toString().padLeft(2, '0')}:'
                      '${note.datetime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol menu (3 titik) untuk Edit dan Delete
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();   // Panggil callback edit
                  if (v == 'delete') onDelete(); // Panggil callback delete
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mengimpor library 'dart:convert' untuk mendukung proses konversi JSON
import 'dart:convert';

/// Kelas `Note` merepresentasikan satu entitas catatan (note)
/// berisi informasi seperti judul, deskripsi, waktu pembuatan, dan path gambar.
///
/// Model ini juga menyediakan fungsi untuk konversi ke/dari `Map` dan `JSON`,
/// sehingga dapat disimpan atau dibaca dari penyimpanan lokal.
class Note {
  /// ID unik untuk setiap catatan
  String id;

  /// Judul catatan
  String title;

  /// Deskripsi atau isi catatan
  String description;

  /// Tanggal dan waktu catatan dibuat atau diedit
  DateTime datetime;

  /// Path lokasi gambar yang terkait dengan catatan (opsional)
  String? imagePath;

  /// Konstruktor utama untuk membuat objek `Note`
  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.datetime,
    this.imagePath,
  });

  /// Mengubah objek `Note` menjadi `Map<String, dynamic>`
  /// Berguna untuk penyimpanan lokal atau serialisasi data.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        // Konversi objek DateTime menjadi format ISO-8601 agar bisa disimpan dalam teks
        'datetime': datetime.toIso8601String(),
        'imagePath': imagePath,
      };

  /// Factory constructor untuk membuat objek `Note` dari `Map`
  /// Biasanya digunakan saat membaca data dari file, database, atau API.
  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        // Mengubah string ISO-8601 kembali menjadi objek DateTime
        datetime: DateTime.parse(map['datetime']),
        imagePath: map['imagePath'],
      );

  /// Mengubah objek `Note` menjadi string JSON
  /// Contoh hasil: `{"id":"1","title":"Catatan A","description":"Isi..."}`
  String toJson() => json.encode(toMap());

  /// Factory constructor untuk membuat objek `Note` dari string JSON
  /// Biasanya digunakan saat membaca data yang tersimpan dalam format teks JSON.
  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}

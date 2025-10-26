// Import pustaka Flutter Material yang berisi widget dan tema bawaan Material Design
import 'package:flutter/material.dart';

// Import file 'home_page.dart' dari folder 'pages' yang berisi tampilan utama aplikasi
import 'pages/home_page.dart';

// Fungsi utama (main) yang pertama kali dijalankan saat aplikasi dimulai
void main() async {
  // Memastikan bahwa binding Flutter sudah diinisialisasi sebelum menjalankan aplikasi
  // (diperlukan jika ada pemanggilan async di main)
  WidgetsFlutterBinding.ensureInitialized();

  // Menjalankan aplikasi Flutter dengan memanggil widget root 'PersonalJournalApp'
  runApp(const PersonalJournalApp());
}

// Kelas utama aplikasi yang bersifat Stateless (tidak memiliki state yang berubah)
class PersonalJournalApp extends StatelessWidget {
  const PersonalJournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp merupakan widget utama yang menyediakan struktur aplikasi Material Design
    return MaterialApp(
      // Judul aplikasi (muncul di task manager)
      title: 'Personal Journal',

      // Tema aplikasi, di sini menggunakan warna utama (primarySwatch) teal
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity, // Menyesuaikan kepadatan tampilan dengan platform
      ),

      // Halaman awal aplikasi, diarahkan ke HomePage (berisi tampilan utama aplikasi)
      home: const HomePage(),

      // Menghilangkan label "debug" di pojok kanan atas saat mode debug
      debugShowCheckedModeBanner: false,
    );
  }
}

// Mengimpor library yang dibutuhkan
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

/// Halaman untuk menambah atau mengedit catatan (Note)
/// Menyediakan form input untuk judul, deskripsi, tanggal/waktu, dan gambar.
class AddEditNotePage extends StatefulWidget {
  /// Jika [initial] tidak null, maka halaman ini akan menampilkan data note yang ingin diedit.
  final Note? initial;

  const AddEditNotePage({Key? key, this.initial}) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  // Controller untuk input judul dan deskripsi
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Variabel untuk menyimpan tanggal dan waktu yang dipilih
  DateTime _selected = DateTime.now();

  // Variabel untuk menyimpan gambar yang dipilih
  File? _pickedImage;

  @override
  void initState() {
    super.initState();

    // Jika mode edit, isi form dengan data awal dari note yang dipilih
    if (widget.initial != null) {
      _titleCtrl.text = widget.initial!.title;
      _descCtrl.text = widget.initial!.description;
      _selected = widget.initial!.datetime;

      // Jika ada gambar sebelumnya, tampilkan
      if (widget.initial!.imagePath != null) {
        _pickedImage = File(widget.initial!.imagePath!);
      }
    }
  }

  /// Fungsi untuk memilih gambar dari galeri menggunakan `image_picker`
  Future<void> _pickImage() async {
    final XFile? xf = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, // Mengatur lebar maksimum gambar agar tidak terlalu besar
    );
    if (xf == null) return; // Jika tidak memilih gambar, hentikan proses
    setState(() => _pickedImage = File(xf.path));
  }

  /// Fungsi untuk memilih tanggal dan waktu catatan
  Future<void> _pickDateTime() async {
    // Memunculkan dialog pemilih tanggal
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return;

    // Memunculkan dialog pemilih waktu
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selected),
    );
    if (t == null) return;

    // Menyimpan hasil pemilihan tanggal dan waktu
    setState(() => _selected = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  /// Fungsi untuk menyimpan catatan baru atau hasil edit
  Future<void> _save() async {
    // Validasi agar judul tidak kosong
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    // Jika note baru → buat id baru menggunakan UUID
    // Jika edit → gunakan id lama
    String id = widget.initial?.id ?? const Uuid().v4();
    String? imagePath = widget.initial?.imagePath;

    // Jika pengguna memilih gambar baru
    if (_pickedImage != null && (_pickedImage!.path != widget.initial?.imagePath)) {
      // Simpan gambar ke direktori aplikasi
      imagePath = await StorageService.saveImageFile(_pickedImage!);

      // Jika mengedit dan ada gambar lama, hapus gambar lama
      if (widget.initial?.imagePath != null && widget.initial!.imagePath != imagePath) {
        await StorageService.deleteImage(widget.initial!.imagePath!);
      }
    }

    // Membuat objek note baru dengan data dari input pengguna
    final note = Note(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      datetime: _selected,
      imagePath: imagePath,
    );

    // Mengembalikan note ke halaman sebelumnya (HomePage)
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null; // Menentukan apakah mode edit atau tambah
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Input Judul
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 8),

              // Input Deskripsi
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 8),

              // Pilihan waktu dan tanggal catatan
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Waktu: ${_selected.day}/${_selected.month}/${_selected.year} '
                      '${_selected.hour.toString().padLeft(2, '0')}:${_selected.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Pilih Waktu'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Area untuk menampilkan atau memilih gambar
              Row(
                children: [
                  if (_pickedImage != null)
                    // Jika ada gambar baru yang dipilih
                    Image.file(_pickedImage!, width: 96, height: 96, fit: BoxFit.cover)
                  else if (widget.initial?.imagePath != null)
                    // Jika sedang edit dan ada gambar lama
                    Image.file(File(widget.initial!.imagePath!), width: 96, height: 96, fit: BoxFit.cover)
                  else
                    // Jika tidak ada gambar
                    Container(
                      width: 96,
                      height: 96,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Pilih Foto'),
                  ),
                ],
              ),

              const Spacer(),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/item_model.dart';

class AddItemScreen extends StatefulWidget {
  final UserAccount user;

  const AddItemScreen({
    super.key,
    required this.user,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Task';
  String _selectedStatus = 'Pending';
  bool _isSaving = false;

  // Hanya admin utama yang dapat menentukan status
  bool get _isMainAdmin =>
      widget.user.username.toLowerCase() == 'admin1';

  final List<String> _categories = [
    'Task',
    'Inventaris',
  ];

  final List<String> _statuses = [
    'Pending',
    'Proses',
    'Selesai',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // SIMPAN ENTRY
  Future<void> _submitForm() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final newItem = ItemModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      status: _isMainAdmin ? _selectedStatus : 'Pending',
      createdBy: widget.user.username,
      description: _descController.text.trim(),
    );

    setState(() {
      _isSaving = true;
    });

    globalItemList.insert(0, newItem);

    try {
      await LocalStorage.saveData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      globalItemList.removeWhere(
        (item) => item.id == newItem.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Tambah Entry'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Data Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isMainAdmin
                    ? 'Tambahkan Task atau Inventaris ke sistem.'
                    : 'Buat Task atau data Inventaris baru.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 25),

              // JUDUL
              TextFormField(
                controller: _titleController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Nama Item',
                  hintText: 'Masukkan nama item',
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama item wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // KATEGORI
              const Text(
                'Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 20),

              // STATUS KHUSUS ADMIN UTAMA
              if (_isMainAdmin) ...[
                const Text(
                  'Status Item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.flag),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                ),

                const SizedBox(height: 20),
              ],

              // DESKRIPSI
              TextFormField(
                controller: _descController,
                enabled: !_isSaving,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Masukkan keterangan item',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),

                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : 'Simpan Entry',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2410C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
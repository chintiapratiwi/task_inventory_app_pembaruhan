import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'All';


  static const Color backgroundColor = Color(0xFFF5F7F7);

 bool get _isMainAdmin =>
    widget.user.username.toLowerCase() == 'admin1';

bool get _isAdmin =>
    widget.user.role.toLowerCase() == 'admin';

  List<ItemModel> get _filteredItems {
    if (_selectedFilter == 'All') {
      return globalItemList;
    }

    if (_selectedFilter == 'Approve') {
      return [];
    }

    return globalItemList
        .where((item) => item.status == _selectedFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFEF4444);
      case 'Proses':
        return const Color(0xFFF59E0B);
      case 'Selesai':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // LOGOUT
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // TAMBAH DATA
  Future<void> _addEntry() async {
    if (!_isAdmin) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(user: widget.user),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {});
    }
  }

  // UBAH STATUS
  Future<void> _changeStatus(ItemModel item) async {
    String selectedStatus = item.status;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title),
                  const SizedBox(height: 20),
                  RadioGroup<String>(
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        _buildStatusOption('Pending'),
                        _buildStatusOption('Proses'),
                        _buildStatusOption('Selesai'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final oldStatus = item.status;

                        Navigator.pop(sheetContext);

                        setState(() {
                          item.status = selectedStatus;
                        });

                        try {
                          await LocalStorage.saveData();
                          _showMessage('Status berhasil diperbarui');
                        } catch (e) {
                          item.status = oldStatus;

                          if (!mounted) return;

                          setState(() {});
                          _showMessage('Gagal menyimpan status: $e');
                        }
                      },
                      child: const Text('Simpan Status'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusOption(String status) {
    return RadioListTile<String>(
      title: Text(status),
      value: status,
      activeColor: _getStatusColor(status),
    );
  }

  // EDIT BARANG
  Future<void> _editItem(ItemModel item) async {
    if (!_isMainAdmin) return;

    final titleController = TextEditingController(text: item.title);
    final descriptionController =
        TextEditingController(text: item.description);

    String selectedCategory = item.category;
    String selectedStatus = item.status;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Data Barang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang / Task',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Task',
                          child: Text('Task'),
                        ),
                        DropdownMenuItem(
                          value: 'Inventaris',
                          child: Text('Inventaris'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Proses',
                          child: Text('Proses'),
                        ),
                        DropdownMenuItem(
                          value: 'Selesai',
                          child: Text('Selesai'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nama barang tidak boleh kosong',
                          ),
                        ),
                      );
                      return;
                    }

                    final oldTitle = item.title;
                    final oldCategory = item.category;
                    final oldStatus = item.status;
                    final oldDescription = item.description;

                    item.title = titleController.text.trim();
                    item.category = selectedCategory;
                    item.status = selectedStatus;
                    item.description =
                        descriptionController.text.trim();

                    Navigator.pop(dialogContext);

                    if (mounted) setState(() {});

                    try {
                      await LocalStorage.saveData();
                      _showMessage('Data berhasil diperbarui');
                    } catch (e) {
                      item.title = oldTitle;
                      item.category = oldCategory;
                      item.status = oldStatus;
                      item.description = oldDescription;

                      if (!mounted) return;

                      setState(() {});
                      _showMessage('Gagal mengedit data: $e');
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  // MENU PILIH PENGHAPUSAN
  void _showDeleteMenu() {
    if (!_isMainAdmin) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE8EEEE),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text(
            'Pilih Penghapusan',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFE99B00),
                  size: 35,
                ),
                title: const Text(
                  'Hapus Barang',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text(
                  'Hapus entry Task atau Inventaris',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showDeleteItemList();
                },
              ),
              const Divider(height: 15),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: Color(0xFFE34B55),
                  size: 35,
                ),
                title: const Text(
                  'Hapus Akun',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text(
                  'Hapus akun yang sudah terdaftar',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showDeleteAccountList();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF168477),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // PILIH BARANG UNTUK DIHAPUS
  void _showDeleteItemList() {
    if (!_isMainAdmin) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Barang'),
          content: SizedBox(
            width: double.maxFinite,
            child: globalItemList.isEmpty
                ? const Text('Belum ada barang.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: globalItemList.length,
                    itemBuilder: (_, index) {
                      final item = globalItemList[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.orange,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.createdBy),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _deleteItem(item);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // HAPUS ITEM
  void _deleteItem(ItemModel item) {
    if (!_isMainAdmin) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Item?'),
          content: Text('Yakin ingin menghapus "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final index = globalItemList.indexOf(item);
                if (index == -1) return;

                globalItemList.removeAt(index);
                Navigator.pop(dialogContext);

                setState(() {});

                try {
                  await LocalStorage.saveData();
                  _showMessage('Item berhasil dihapus');
                } catch (e) {
                  globalItemList.insert(index, item);

                  if (!mounted) return;

                  setState(() {});
                  _showMessage('Gagal menghapus item: $e');
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // PILIH AKUN UNTUK DIHAPUS
  void _showDeleteAccountList() {
    if (!_isMainAdmin) return;

    final users = registeredUsers
        .where((user) => user.username.toLowerCase() != 'admin1')
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Akun'),
          content: SizedBox(
            width: double.maxFinite,
            child: users.isEmpty
                ? const Text('Tidak ada akun yang dapat dihapus.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (_, index) {
                      final user = users[index];

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.role),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _confirmDeleteAccount(user);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // KONFIRMASI HAPUS AKUN
  void _confirmDeleteAccount(UserAccount user) {
    if (!_isMainAdmin) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Akun?'),
          content: Text(
            'Yakin ingin menghapus akun ${user.username}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final index = registeredUsers.indexOf(user);
                if (index == -1) return;

                registeredUsers.removeAt(index);
                Navigator.pop(dialogContext);

                setState(() {});

                try {
                  await LocalStorage.saveData();
                  _showMessage(
                    'Akun ${user.username} berhasil dihapus',
                  );
                } catch (e) {
                  registeredUsers.insert(index, user);

                  if (!mounted) return;

                  setState(() {});
                  _showMessage('Gagal menghapus akun: $e');
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // TERIMA AKUN
  Future<void> _approveUser(UserAccount user) async {
    if (!_isMainAdmin) return;

    final oldStatus = user.status;

    setState(() {
      user.status = 'Active';
    });

    try {
      await LocalStorage.saveData();
      _showMessage('Akun ${user.username} berhasil diterima.');
    } catch (e) {
      user.status = oldStatus;

      if (!mounted) return;

      setState(() {});
      _showMessage('Gagal menyimpan persetujuan: $e');
    }
  }

  // TOLAK AKUN
  Future<void> _rejectUser(UserAccount user) async {
    if (!_isMainAdmin) return;

    final oldStatus = user.status;

    setState(() {
      user.status = 'Rejected';
    });

    try {
      await LocalStorage.saveData();
      _showMessage('Akun ${user.username} ditolak.');
    } catch (e) {
      user.status = oldStatus;

      if (!mounted) return;

      setState(() {});
      _showMessage('Gagal menyimpan penolakan: $e');
    }
  }

  // PERSETUJUAN AKUN
  Widget _buildAccountApproval() {
    if (!_isMainAdmin) return const SizedBox.shrink();

    final pendingUsers = registeredUsers
        .where((user) => user.status == 'Pending')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Persetujuan Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (pendingUsers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 45,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Tidak ada pendaftaran akun yang perlu disetujui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ...pendingUsers.map((user) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Role: ${user.role}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectUser(user),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveUser(user),
                        child: const Text('Terima'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // KARTU STATISTIK
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // LEGENDA KATEGORI
  Widget _buildLegendDot(
    String title,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title)),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // FILTER
  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        selectedColor: const Color(0xFFD7EEEA),
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  // KONTEN DASHBOARD
  Widget _buildDashboardContent(
    BuildContext context,
    bool isWide,
  ) {
    final pendingCount = globalItemList
        .where((item) => item.status == 'Pending')
        .length;

    final processCount = globalItemList
        .where((item) => item.status == 'Proses')
        .length;

    final completedCount = globalItemList
        .where((item) => item.status == 'Selesai')
        .length;

    final taskCount = globalItemList
        .where((item) => item.category == 'Task')
        .length;

    final inventoryCount = globalItemList
        .where((item) => item.category == 'Inventaris')
        .length;

    final filteredItems = _filteredItems;

    final metrics = [
      _buildMetricCard(
        'Need Action',
        '$pendingCount',
        Icons.pending_actions,
        const Color(0xFFEF4444),
      ),
      _buildMetricCard(
        'In Progress',
        '$processCount',
        Icons.sync,
        const Color(0xFFF59E0B),
      ),
      _buildMetricCard(
        'Completed',
        '$completedCount',
        Icons.check_circle,
        const Color(0xFF10B981),
      ),
      _buildMetricCard(
        'Total Data',
        '${globalItemList.length}',
        Icons.storage,
        const Color(0xFF0284C7),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // BANNER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A3412),
                Color(0xFFC2410C),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola data Task & Inventory.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // STATISTIK RESPONSIF
        if (isWide)
          Row(
            children: [
              for (int i = 0; i < metrics.length; i++) ...[
                Expanded(child: metrics[i]),
                if (i != metrics.length - 1)
                  const SizedBox(width: 14),
              ],
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: metrics[0]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: metrics[2]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[3]),
                ],
              ),
            ],
          ),

        const SizedBox(height: 28),

        // DISTRIBUSI KATEGORI
        const Text(
          'Distribusi Kategori',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _buildLegendDot(
                'Task',
                taskCount,
                const Color(0xFF0284C7),
              ),
              const SizedBox(height: 16),
              _buildLegendDot(
                'Inventaris',
                inventoryCount,
                const Color(0xFFD97706),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // FILTER STATUS
        const Text(
          'Filter Status',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Pending'),
              _buildFilterChip('Proses'),
              _buildFilterChip('Selesai'),
              if (_isMainAdmin) _buildFilterChip('Approve'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // DATA SISTEM
        const Text(
          'Data Sistem',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (_selectedFilter == 'Approve' && _isMainAdmin)
          _buildAccountApproval(),

        if (filteredItems.isEmpty &&
            _selectedFilter != 'Approve')
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Tidak ada data.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

        ...filteredItems.map((item) {
          final statusColor = _getStatusColor(item.status);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withValues(
                  alpha: 0.1,
                ),
                child: Icon(
                  item.category == 'Task'
                      ? Icons.task_alt
                      : Icons.inventory_2_outlined,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${item.category} • ${item.createdBy}',
                ),
              ),
              trailing: Wrap(
                spacing: 0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    IconButton(
                      tooltip: 'Edit Barang',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: () => _editItem(item),
                    ),
                  IconButton(
                    tooltip: 'Ubah Status',
                    icon: const Icon(Icons.sync_alt),
                    onPressed: () => _changeStatus(item),
                  ),
                  if (_isMainAdmin)
                    IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteItem(item),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 750;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Admin Control Center'),
            centerTitle: true,
            actions: [
              if (_isMainAdmin)
                IconButton(
                  tooltip: 'Menu Hapus',
                  onPressed: _showDeleteMenu,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(Icons.logout),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // TOMBOL TAMBAH ENTRY MENGAMBANG
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  onPressed: _addEntry,
                  backgroundColor: const Color(0xFFB8E5DE),
                  foregroundColor: const Color(0xFF164E49),
                  elevation: 4,
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text(
                    'Tambah Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,

          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: _buildDashboardContent(
                context,
                isWide,
              ),
            ),
          ),
        );
      },
    );
  }
}
// features/santri/presentation/santri_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/santri_model.dart';
import 'package:sipesantren/core/repositories/santri_repository.dart';
import 'package:sipesantren/features/penilaian/presentation/input_penilaian_page.dart';
import 'package:sipesantren/features/rapor/presentation/rapor_page.dart';
import 'package:sipesantren/firebase_services.dart';
import 'package:sipesantren/features/auth/presentation/login_page.dart';

class SantriListPage extends ConsumerStatefulWidget {
  const SantriListPage({super.key});

  @override
  ConsumerState<SantriListPage> createState() => _SantriListPageState();
}

class _SantriListPageState extends ConsumerState<SantriListPage> {
  final SantriRepository _repository = SantriRepository();
  String _selectedKamar = 'Semua';
  String _selectedAngkatan = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Santri'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              _showSyncDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddSantriDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseServices().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari santri...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedKamar,
                            items: const [
                              DropdownMenuItem(value: 'Semua', child: Text('Semua Kamar')),
                              DropdownMenuItem(value: 'A3', child: Text('Kamar A3')),
                              DropdownMenuItem(value: 'B1', child: Text('Kamar B1')),
                              DropdownMenuItem(value: 'C2', child: Text('Kamar C2')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedKamar = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedAngkatan,
                            items: const [
                              DropdownMenuItem(value: 'Semua', child: Text('Semua Angkatan')),
                              DropdownMenuItem(value: '2023', child: Text('2023')),
                              DropdownMenuItem(value: '2022', child: Text('2022')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedAngkatan = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Santri List
          Expanded(
            child: StreamBuilder<List<SantriModel>>(
              stream: _repository.getSantriList(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allSantri = snapshot.data!;
                final filteredSantri = allSantri.where((santri) {
                  final matchesSearch = santri.nama.toLowerCase().contains(_searchQuery) || 
                                      santri.nis.contains(_searchQuery);
                  final matchesKamar = _selectedKamar == 'Semua' || santri.kamar == _selectedKamar;
                  final matchesAngkatan = _selectedAngkatan == 'Semua' || santri.angkatan.toString() == _selectedAngkatan;
                  return matchesSearch && matchesKamar && matchesAngkatan;
                }).toList();

                if (filteredSantri.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                return ListView.builder(
                  itemCount: filteredSantri.length,
                  itemBuilder: (context, index) {
                    final santri = filteredSantri[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(santri.nama),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NIS: ${santri.nis} | Kamar: ${santri.kamar}'),
                            // Status sinkron omitted for now as Firestore handles it automatically
                            // Or we could check metadata.hasPendingWrites if needed
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SantriDetailPage(santri: santri),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog() {
    // Firestore syncs automatically. This could be a "Force Sync" or status check.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sinkronisasi Data'),
        content: const Text('Data disinkronkan secara otomatis saat online.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddSantriDialog() {
    final nisController = TextEditingController();
    final namaController = TextEditingController();
    final kamarController = TextEditingController();
    final angkatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Santri Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nisController, decoration: const InputDecoration(labelText: 'NIS')),
              TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: kamarController, decoration: const InputDecoration(labelText: 'Kamar')),
              TextField(controller: angkatanController, decoration: const InputDecoration(labelText: 'Angkatan (Tahun)')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final santri = SantriModel(
                id: '', // Firestore auto-id
                nis: nisController.text,
                nama: namaController.text,
                kamar: kamarController.text,
                angkatan: int.tryParse(angkatanController.text) ?? DateTime.now().year,
              );
              await _repository.addSantri(santri);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Santri berhasil ditambahkan')),
                );
              }
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }
}

class SantriDetailPage extends StatelessWidget {
  final SantriModel santri;

  const SantriDetailPage({super.key, required this.santri});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(santri.nama),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Penilaian'),
              Tab(text: 'Kehadiran'),
              Tab(text: 'Grafik'),
              Tab(text: 'Rapor'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Penilaian
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // TODO: Fetch real grades
                  _buildNilaiCard('Tahfidz', '93', Colors.green, Icons.book),
                  _buildNilaiCard('Fiqh', '86', Colors.blue, Icons.balance),
                  _buildNilaiCard('Bahasa Arab', '78', Colors.orange, Icons.language),
                  _buildNilaiCard('Akhlak', '94', Colors.purple, Icons.emoji_people),
                  _buildNilaiCard('Kehadiran', '90', Colors.red, Icons.calendar_today),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputPenilaianPage(santri: santri),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Input Penilaian Baru'),
                  ),
                ],
              ),
            ),

            // Tab Kehadiran
            const Center(child: Text('Data Kehadiran akan ditampilkan di sini')),

            // Tab Grafik
            const Center(child: Text('Grafik perkembangan Tahfidz')),

            // Tab Rapor
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'RAPOR SANTRI',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildRaporItem('Nilai Akhir', '89'),
                          _buildRaporItem('Predikat', 'A'),
                          _buildRaporItem('Peringkat', '5 dari 40'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RaporPage(santri: santri),
                                ),
                              );
                            },
                            child: const Text('Lihat Rapor Lengkap'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiCard(String mataPelajaran, String nilai, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(mataPelajaran),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            nilai,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRaporItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

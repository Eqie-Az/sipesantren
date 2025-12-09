import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/weight_config_model.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sipesantren/core/providers/weight_config_provider.dart'; // New import

class WeightConfigPage extends ConsumerStatefulWidget {
  const WeightConfigPage({super.key});

  @override
  ConsumerState<WeightConfigPage> createState() => _WeightConfigPageState();
}

class _WeightConfigPageState extends ConsumerState<WeightConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'tahfidz': TextEditingController(),
    'fiqh': TextEditingController(),
    'bahasaArab': TextEditingController(),
    'akhlak': TextEditingController(),
    'kehadiran': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveWeights() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final repo = ref.read(weightConfigRepositoryProvider);

      try {
        final newConfig = WeightConfigModel(
          id: 'grading_weights', // Fixed ID as defined in repository
          tahfidz: double.parse(_controllers['tahfidz']!.text),
          fiqh: double.parse(_controllers['fiqh']!.text),
          bahasaArab: double.parse(_controllers['bahasaArab']!.text),
          akhlak: double.parse(_controllers['akhlak']!.text),
          kehadiran: double.parse(_controllers['kehadiran']!.text),
        );
        await repo.updateWeightConfig(newConfig);
        Fluttertoast.showToast(msg: "Bobot berhasil diperbarui!");
        Navigator.of(context).pop(); // Go back after saving
      } catch (e) {
        Fluttertoast.showToast(msg: "Gagal memperbarui bobot: $e");
      }
    }
  }

  String? _weightValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan bobot';
    }
    final double? weight = double.tryParse(value);
    if (weight == null || weight < 0 || weight > 1) {
      return 'Bobot harus berupa angka antara 0 dan 1 (mis. 0.30)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final weightConfigAsync = ref.watch(weightConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi Bobot Penilaian'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: weightConfigAsync.when(
        data: (config) {
          if (_controllers['tahfidz']!.text.isEmpty) {
            _controllers['tahfidz']!.text = config.tahfidz.toStringAsFixed(2);
            _controllers['fiqh']!.text = config.fiqh.toStringAsFixed(2);
            _controllers['bahasaArab']!.text = config.bahasaArab.toStringAsFixed(2);
            _controllers['akhlak']!.text = config.akhlak.toStringAsFixed(2);
            _controllers['kehadiran']!.text = config.kehadiran.toStringAsFixed(2);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildWeightInputCard('Tahfidz', _controllers['tahfidz']!),
                const SizedBox(height: 12),
                _buildWeightInputCard('Fiqh', _controllers['fiqh']!),
                const SizedBox(height: 12),
                _buildWeightInputCard('Bahasa Arab', _controllers['bahasaArab']!),
                const SizedBox(height: 12),
                _buildWeightInputCard('Akhlak', _controllers['akhlak']!),
                const SizedBox(height: 12),
                _buildWeightInputCard('Kehadiran', _controllers['kehadiran']!),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveWeights,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Bobot'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildWeightInputCard(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none, // Remove border from TextFormField itself
            contentPadding: EdgeInsets.zero, // Remove default padding
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _weightValidator,
          onSaved: (value) => controller.text = value!,
        ),
      ),
    );
  }
}

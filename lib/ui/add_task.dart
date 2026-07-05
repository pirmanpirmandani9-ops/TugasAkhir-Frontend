import 'package:flutter/material.dart';
import '../service/api.dart'; // Sesuaikan path ini

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitTask() async {
    // Validasi form kosong
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String message = await _apiService.createTask(
        _titleController.text,
        _descriptionController.text,
        _deadlineController.text,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context, true);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Task Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Judul Task",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            // const SizedBox(height: 24),
                const SizedBox(height: 16),
            
            // --- INPUT DEADLINE ---
            TextField(
              controller: _deadlineController,
              readOnly: true, // Cegah user mengetik manual
              decoration: const InputDecoration(
                labelText: "Deadline (Tenggat Waktu)",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today), // Ikon kalender di kanan
              ),
              onTap: () {
                _selectDate();
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Simpan Task", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
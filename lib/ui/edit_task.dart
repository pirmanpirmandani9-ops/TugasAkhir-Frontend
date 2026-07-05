import 'package:flutter/material.dart';
import '../service/api.dart'; 

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task; // Menerima data task dari halaman Home

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _deadlineController;
  String _status = 'pending'; // Default status
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi otomatis form dengan data task yang dipilih
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController = TextEditingController(text: widget.task['description']);
    
    // Format deadline jika ada, hilangkan bagian jam (T00:00:00.000Z)
    String deadline = widget.task['deadline'] ?? '';
    if (deadline.length > 10) deadline = deadline.substring(0, 10);
    _deadlineController = TextEditingController(text: deadline);
    
    _status = widget.task['status'] ?? 'pending';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitUpdate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String message = await _apiService.updateTask(
        widget.task['id'].toString(), // Ambil ID task
        _titleController.text,
        _descriptionController.text,
        _deadlineController.text,
        _status, // Kirim status
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Kembali dengan sinyal refresh (true)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( 
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Task", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
              controller: _deadlineController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Deadline", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            
            // --- DROPDOWN UNTUK STATUS ---
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: "Status Task", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text("Pending (Belum Selesai)")),
                DropdownMenuItem(value: 'completed', child: Text("Completed (Selesai)")),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text("Update Task", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
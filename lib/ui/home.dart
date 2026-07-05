import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/api.dart'; 
import 'login.dart';
import 'add_task.dart';
import 'edit_task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  List<dynamic> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tasks = await _apiService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> task) async {
    String newStatus = task['status'] == 'completed' ? 'pending' : 'completed';
    
    try {
      await _apiService.updateTask(
        task['id'].toString(),
        task['title'],
        task['description'] ?? '',
        task['deadline'] ?? '',
        newStatus,
      );
      _fetchTasks(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _logout() async {
    await _storage.delete(key: 'jwt_token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Daftar Tugas Mahasiswa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : _tasks.isEmpty
                  ? const Center(
                      child: Text("Belum ada task. Tambahkan sekarang!"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Checkbox(
                              value: task['status'] == 'completed',
                              onChanged: (bool? value) {
                                _toggleStatus(task);
                              },
                            ),
                            // CircleAvatar(
                            //   backgroundColor: Colors.blue[100],
                            //   child: const Icon(Icons.task, color: Colors.blue),
                            // ),
                            title: Text(
                              task['title'] ?? 'Tanpa Judul',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['description'] ?? 'Tidak ada deskripsi'),
                            if (task['deadline'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                    const SizedBox(width: 4),
                                    Text(
                                      task['deadline'],
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                            trailing: 
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTaskPage(task: task),
                                    ),
                                  );
                                  if (result == true) {
                                    // Refresh tasks
                                    _fetchTasks();
                                  }
                                }, icon: const Icon(Icons.edit)),
                                IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Hapus Task"),
                                      content: const Text("Yakin ingin menghapus task ini?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      String message = await _apiService.deleteTask(task['id'].toString());
                                      
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(message), backgroundColor: Colors.green),
                                      );
                                      
                                      _fetchTasks(); 
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          
          if (result == true) {
            _fetchTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
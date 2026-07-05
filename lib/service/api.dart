import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class ApiService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://10.152.179.137:3000/api";

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));



    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,    
      responseHeader: false,
      responseBody: true,  
      error: true,
    ));


    // --- FUNGSI TAMBAH TASK ---
   
  }
  Future<String> login(String username, String password) async {
    String cleanUsername = username.trim();
    String cleanPassword = password.trim();
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': cleanUsername,
        'password': cleanPassword,
      });
      String token = response.data['token'];
      await _storage.write(key: 'jwt_token', value: token);
      return response.data['message'] ?? 'Login berhasil';
      // print("Token: $token");
      
     } on DioException catch (e) {
      // Tangkap pesan error ASLI dari backend
      if (e.response != null && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Terjadi kesalahan pada server';
      } else {
        throw 'Gagal terhubung ke server. Cek koneksi Anda.';
      }
    } catch (e) {
      throw 'Error tidak terduga: $e';
    }
  }

  Future<String> register(String name, String nim, String password) async {
    try {
       final response = await _dio.post('/auth/register', data: {
        'nama': name,
        'username': nim,
        'password': password,
      });
      return response.data['message'] ?? 'Register berhasil, silakan login!';
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Gagal melakukan register';
      } else {
        throw 'Gagal terhubung ke server. Cek koneksi Anda.';
      }
    } catch (e) {
      throw 'Error tidak terduga: $e';
    }
  }

 // --- FUNGSI GET TASKS ---
  Future<List<dynamic>> getTasks() async {
    try {
      final response = await _dio.get('/tasks');
      
      if (response.data is List) {
        return response.data;
      } 
      else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'];
      }
      
      return []; 
      
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
           throw e.response?.data['message'];
        }
        throw 'Gagal mengambil data task';
      } else {
        throw 'Gagal terhubung ke server. Cek koneksi Anda.';
      }
    } catch (e) {
      throw 'Error tidak terduga: $e';
    }
  }

   Future<String> createTask(String title, String description, String? deadline) async {
      try {
        final response = await _dio.post('/tasks', data: {
          'title': title,
          'description': description,
          'deadline': deadline,
        });
        
        if (response.data is Map && response.data['message'] != null) {
          return response.data['message'];
        }
        return 'Task berhasil ditambahkan!';
        
      } on DioException catch (e) {
        if (e.response != null && e.response?.data != null) {
          if (e.response?.data is Map && e.response?.data['message'] != null) {
            throw e.response?.data['message'];
          }
          throw 'Gagal menambah task';
        } else {
          throw 'Gagal terhubung ke server.';
        }
      } catch (e) {
        throw 'Error tidak terduga: $e';
      }
    }

  Future<String> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete('/tasks/$taskId');
      
      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'];
      }
      return 'Task berhasil dihapus!';
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Gagal menghapus task';
      } else {
        throw 'Gagal terhubung ke server.';
      }
    } catch (e) {
      throw 'Error tidak terduga: $e';
    }
  }

  Future<String> updateTask(String id, String title, String description, String deadline, String status) async {
    try {
      final response = await _dio.put('/tasks/$id', data: {
        'title': title,
        'description': description,
        'deadline': deadline,
        'status': status, 
      });
      
      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'];
      }
      return 'Task berhasil diperbarui!';
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Gagal memperbarui task';
      } else {
        throw 'Gagal terhubung ke server.';
      }
    } catch (e) {
      throw 'Error tidak terduga: $e';
    }
  }

  Future<List<dynamic>> searchTasks(String query) async {
  try {
    final response = await _dio.get('/tasks/search', queryParameters: {'q': query});
    return response.data as List<dynamic>;
  } catch (e) {
    throw 'Gagal mencari task: $e';
  }
}
}
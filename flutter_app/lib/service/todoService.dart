import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/model/todo.dart';
import 'package:flutter_app/service/authentification.dart';

class TodoService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final AuthMethod _authMethod = AuthMethod();

  Future<String?> _getToken() async {
    return await _authMethod.getIdToken();
  }

  Future<List<Todo>> fetchTodos() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      print('Attempting to fetch todos from: $baseUrl/tasks');
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Todo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching todos: $e');
      throw Exception('Failed to load todos: $e');
    }
  }

  Future<Todo> addTodo(String title) async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'completed': false}),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${todo.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}

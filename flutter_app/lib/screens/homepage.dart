import 'package:flutter/material.dart';
import 'package:flutter_app/Componnents/addDialog.dart';
import 'package:flutter_app/Componnents/editdialog.dart';
import 'package:flutter_app/model/todo.dart';
import 'package:flutter_app/service/todoService.dart';
import 'package:flutter_app/screens/login_page.dart';
import 'package:flutter_app/service/authentification.dart';





class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    _todos = await _todoService.fetchTodos();
    setState(() => _isLoading = false);
  }

  Future<void> _addTodo() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AddTodoDialog(),
    );
    if (result != null && result.isNotEmpty) {
      final newTodo = await _todoService.addTodo(result);
      setState(() => _todos.add(newTodo));
    }
  }
Future<void> _editTodo(Todo todo) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => EditTodoDialog(initialTitle: todo.title),
  );
  if (result != null && result.isNotEmpty) {
    setState(() {
      todo.title = result;  
    });
    await _todoService.updateTodo(todo);
  }
}

  Future<void> _deleteTodo(Todo todo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _todoService.deleteTodo(todo.id);
      setState(() => _todos.removeWhere((t) => t.id == todo.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(horizontal: screenWidth * 0.05);

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List '),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthMethod().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Your Todos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: screenWidth * 0.9,
                        ),
                        child: DataTable(
                          columnSpacing: screenWidth * 0.05,
                          columns: [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _todos
                              .map((todo) => DataRow(
                                    cells: [
                                      DataCell(Text(todo.id.toString())),
                                      DataCell(
                                        Container(
                                          width: screenWidth * 0.3,
                                          child: Text(
                                            todo.title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Checkbox(
                                        value: todo.completed,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            todo.completed = value!;
                                            _todoService.updateTodo(todo);
                                          });
                                        },
                                      )),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () => _editTodo(todo),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _deleteTodo(todo),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addTodo,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  final String title;
  bool isCompleted;

  Todo({
    required this.title,
    this.isCompleted = false,
  });
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> todoList = [];
  TextEditingController taskNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? taskTitles = preferences.getStringList('tasks');

    if (taskTitles != null) {
      setState(() {
        todoList = taskTitles.map((title) => Todo(title: title)).toList();
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> taskTitles = todoList.map((todo) => todo.title).toList();

    await preferences.setStringList('tasks', taskTitles);
  }

void addTodo() {
  String taskName = taskNameController.text.trim();
  if (taskName.isNotEmpty) {
    setState(() {
      todoList.add(Todo(title: taskName));
      taskNameController.clear();
    });
    saveTasks();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please add a name for the task'),
      ),
    );
  }
}

  void removeTodoAtIndex(int index) {
    setState(() {
      todoList.removeAt(index);
    });
    saveTasks();
  }

  void markTodoAsCompleted(int index) {
    setState(() {
      todoList[index].isCompleted = true;
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          final todo = todoList[index];
          return ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Checkbox(
              value: todo.isCompleted,
              onChanged: (bool? value) {
                if (value != null && value) {
                  markTodoAsCompleted(index);
                }
              },
            ),
            onLongPress: () {
              removeTodoAtIndex(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Task'),
                content: TextField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addTodo();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TodoApp(),
  ));
}

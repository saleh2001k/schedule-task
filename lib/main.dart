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

class TodoList {
  final List<Todo> todos;

  TodoList(this.todos);

  void addTodo(Todo todo) {
    todos.add(todo);
  }

  void removeTodoAtIndex(int index) {
    if (index >= 0 && index < todos.length) {
      todos.removeAt(index);
    }
  }

  void markTodoAsCompleted(int index) {
    if (index >= 0 && index < todos.length) {
      todos[index].isCompleted = true;
    }
  }
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TodoList todoList = TodoList([]);
  bool showAddTask = false;
  TextEditingController taskNameController = TextEditingController();
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    initializePreferences();
    loadTasks();
  }

  Future<void> initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  void toggleAddTask() {
    setState(() {
      showAddTask = !showAddTask;
    });
  }

  void addTodo() {
    String taskName = taskNameController.text.trim();
    if (taskName.isNotEmpty) {
      setState(() {
        todoList.addTodo(Todo(title: taskName));
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
    if (index >= 5 && index < todoList.todos.length + 5) {
      setState(() {
        todoList.removeTodoAtIndex(index - 5);
        saveTasks();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid index'),
        ),
      );
    }
  }

  void markTodoAsCompleted(int index) {
    if (index >= 5 && index < todoList.todos.length + 5) {
      setState(() {
        todoList.markTodoAsCompleted(index - 5);
        saveTasks();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid index'),
        ),
      );
    }
  }

  Future<void> saveTasks() async {
    if (preferences != null) {
      final List<String> taskList =
          todoList.todos.map((todo) => todo.title).toList();
      await preferences!.setStringList('tasks', taskList);
    }
  }

  Future<void> loadTasks() async {
    if (preferences != null) {
      final List<String>? taskList = preferences!.getStringList('tasks');
      if (taskList != null) {
        final List<Todo> loadedTasks =
            taskList.map((task) => Todo(title: task)).toList();

        final List<Todo> predefinedTasks = [
          Todo(title: 'Fajr'),
          Todo(title: 'Dhuhr'),
          Todo(title: 'Asr'),
          Todo(title: 'Maghrib'),
          Todo(title: 'Isha'),
        ];

        final List<Todo> allTasks = [...predefinedTasks, ...loadedTasks];

        setState(() {
          todoList.todos.clear();
          todoList.todos.addAll(allTasks);
        });
      } else {
        setState(() {
          todoList.todos.clear();
          todoList.todos.addAll([
            Todo(title: 'Fajr'),
            Todo(title: 'Dhuhr'),
            Todo(title: 'Asr'),
            Todo(title: 'Maghrib'),
            Todo(title: 'Isha'),
          ]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todoList.todos.length + 5, // Add 5 for the main tasks
        itemBuilder: (BuildContext context, int index) {
          if (index < 5) {
            final todo = todoList.todos[index];
            return ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  color: Colors.red, // Color for the main tasks
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot delete predefined tasks'),
                  ),
                );
              },
            );
          } else {
            final todo = todoList.todos[index - 5];
            return ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  color: todo.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              trailing: Checkbox(
                value: todo.isCompleted,
                onChanged: (bool? value) {
                  if (value != null) {
                    markTodoAsCompleted(index - 5);
                  }
                },
              ),
              onLongPress: () {
                removeTodoAtIndex(index - 5);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleAddTask,
        child: Icon(showAddTask ? Icons.close : Icons.add),
      ),
      bottomSheet: showAddTask
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskNameController,
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addTodo,
                    child: Text('Add'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TodoApp(),
  ));
}

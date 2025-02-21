import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks.addAll(taskList.map((task) {
        final parts = task.split('|');
        return {"title": parts[0], "isDone": parts[1] == "true"};
      }));
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = _tasks.map((task) =>
'${task["title"]}|${task["isDone"]}').toList();
    prefs.setStringList('tasks', taskList);
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({"title": _taskController.text, "isDone": false});
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]["isDone"] = !_tasks[index]["isDone"];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List', style: TextStyle(fontWeight:
FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter a task...',
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(borderRadius:
BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _addTask,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.add, color: Colors.white),
                )
                    .animate()
                    .scale()
                    .fadeIn(duration: 300.ms),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text("No tasks yet!", style:
TextStyle(fontSize: 18, color: Colors.white54)),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: Key(task["title"]),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTask(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius:
BorderRadius.circular(12)),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                task["isDone"] ? Icons.check_circle :
Icons.circle_outlined,
                                color: task["isDone"] ? Colors.green :
Colors.grey,
                              ),
                              onPressed: () => _toggleTask(index),
                            ),
                            title: Text(
                              task["title"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: task["isDone"] ?
TextDecoration.lineThrough : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideX(begin: -0.2, end: 0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


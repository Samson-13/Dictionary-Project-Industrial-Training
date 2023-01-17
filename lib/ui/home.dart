import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../model/dictonary_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoModel> todos = [];

  @override
  void initState() {
    super.initState();
    listenData();
  }

  void addToFirestore(TodoModel todo) async {
    FirebaseFirestore.instance
        .collection("todos")
        .doc(todo.id)
        .set(todo.toMap());
  }

  void updateToFirestore(TodoModel todo) async {
    try {
      FirebaseFirestore.instance
          .collection("todos")
          .doc(todo.id)
          .update(todo.toMap());
    } catch (e) {
      print("Error: $e");
    }
  }

  void deleteFromFirestore(TodoModel todo) async {
    FirebaseFirestore.instance.collection("todos").doc(todo.id).delete();
  }

  final todosRef = FirebaseFirestore.instance
      .collection("todos")
      .limit(30)
      .withConverter<TodoModel>(
    fromFirestore: (data, snap) {
      return TodoModel.fromMap(data.data()!);
    },
    toFirestore: (data, snap) {
      return data.toMap();
    },
  );

  void listenData() async {
    todosRef.snapshots().listen((event) {
      todos.clear();
      for (var element in event.docs) {
        todos.add(element.data());
      }
      setState(() {});
    });
    // log("firestoreResult: ${firestoreResult.docs.length}");
  }

  void readData() async {
    final firestoreResult = await todosRef.get();
    for (var element in firestoreResult.docs) {
      todos.add(element.data());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 13,
        centerTitle: true,
        title: const Text('Dictionary'),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }
}

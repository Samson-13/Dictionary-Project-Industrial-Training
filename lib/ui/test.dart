import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dictonary/ui/new_word_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../model/dictonary_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
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

  // GOOGLE NAV
  // int _selectedIndex = 0;
  // static const TextStyle optionStyle =
  //     TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  // static const List<Widget> _widgetOptions = <Widget>[
  //   HomePage(),
  //   AddWord(todo: null),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 13,
        centerTitle: true,
        title: const Text('Dictionary'),
        backgroundColor: Colors.red.shade400,
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const AddWord(
              todo: null,
            );
          })).then((value) {
            if (value != null && value is TodoModel) {
              addToFirestore(value);
            }
          });
        },
        label: const Text('Add a content'),
        icon: const Icon(Icons.add),
        hoverColor: Colors.green.shade400,
        
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          var item = todos[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                          "Are you sure you want to delete the task?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              deleteFromFirestore(item);
                            },
                            child: const Text("Yes")),
                      ],
                    );
                  });
            },
      child: Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.description ?? "Not available"),
                leading: item.image != null
                    ? Image.network(item.image!, scale: 1.0,)
                    : const Text('N/A'),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddWord(todo: item);
                  })).then((value) {
                    if (value != null) {
                      updateToFirestore(value);
                    } else {
                      // log("returned data from new TODO page :$value");
                    }
                  });
                },
                
              ),
            ),
          );
        },
      ),
    );     
  }
}

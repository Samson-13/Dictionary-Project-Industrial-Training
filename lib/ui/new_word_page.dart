import 'dart:io';

import 'package:dictonary/model/dictonary_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

class AddWord extends StatefulWidget {
  final TodoModel? todo;
  const AddWord({super.key, required this.todo});

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool complete = false;
  bool uploading = false;

  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    checkPassedData();
  }

  void checkPassedData() {
    if (widget.todo != null) {
      titleController.text = widget.todo!.title;
      descriptionController.text = widget.todo!.description ?? "";
      imageUrl = widget.todo!.image;
    }
  }

  void pickImage() async {
    showModalBottomSheet(context: context, builder: (context){
      return Row(
        children: [
          Expanded(child: MaterialButton(
            onPressed: () async{
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if(image != null){
                uploadImage(image);
            }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  height: 15,
                ),
                Icon(Icons.camera_alt, size: 35,),
                Text('Camera'),
                SizedBox(
                  height: 15,
                )
              ],
            ),
            )),
            Expanded(child: MaterialButton(
            onPressed: () async{
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if(image != null){
                uploadImage(image);
            }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  height: 15,
                ),
                Icon(Icons.browse_gallery, size: 35,),
                Text('Camera'),
                SizedBox(
                  height: 15,
                )
              ],
            ),
            )),
        ],
      );
    });
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      uploadImage(image);
    
    }
  }

  void uploadImage(XFile file) async {
    UploadTask uploadTask;
    var newId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('$newId.jpg');
    uploadTask = ref.putFile(File(file.path));
    uploading = true;

    setState(() {
      
    });
    uploadTask.then((p0) async {
      if (p0.state == TaskState.success) {
        final url = await ref.getDownloadURL();
        imageUrl = url;
        uploading = false;
        setState(() {});
        
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 13,
        centerTitle: true,
        backgroundColor: Colors.red.shade400,
        title: Text(widget.todo == null ? "Add a word" : "Update word"),
        leading: GestureDetector(
      onTap: () { /* Write listener code here */ },
      child: Icon(
        Icons.menu,  // add custom icons also
      ),
  ),
  actions: <Widget>[
    Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: () {},
        child: Icon(
          Icons.search,
          size: 26.0,
        ),
      )
    ),
    Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: () {},
        child: Icon(
            Icons.more_vert
        ),
      )
    ),
  ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 8),
          child: Column(children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                height: 150,
              // scale: 1.0,
              )
            else
              SizedBox(
                height: 150,
                child: uploading ? const CupertinoActivityIndicator() :
                TextButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.add_a_photo),
                      Text("Add an Image")
                    ],
                  ),
                ),
              ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green.shade600, // background
                onPrimary: Colors.white, // foreground
                elevation: 5,
              ),
              onPressed: () {
                if (uploading){
                  return;
                }
                var newId = DateTime.now().millisecondsSinceEpoch.toString();
                if (widget.todo != null) {
                  newId = widget.todo!.id;
                }
                TodoModel newItem = TodoModel(
                  id: newId,
                  title: titleController.text,
                  description: descriptionController.text,
                  image: imageUrl,
                );
                titleController.text = "";
                descriptionController.text = "";
                Navigator.of(context).pop(newItem);
              },
              child: uploading? SizedBox(child: CircularProgressIndicator(), width: 20, height: 20,): Text(widget.todo == null ? "Add" : "Update"),

            ),
          ]),
        ),
      ),
    );
  }
}

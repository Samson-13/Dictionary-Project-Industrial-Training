import 'package:flutter/src/widgets/framework.dart';

class TodoModel {
  late String id;
  late String title;
  String? description;
  String? image;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.image,
  });

  TodoModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
    };
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:human_safety/utils/myutils.dart';
import 'package:human_safety/utils/parsing_helper.dart';

class UserModel {
  String id = "", name = "", image = "", mobile = "", email = "";
  Timestamp? createdTime;
  List<String> sosContacts = <String>[];

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    image = ParsingHelper.parseStringMethod(map['image']);
    mobile = ParsingHelper.parseStringMethod(map['mobile']);
    email = ParsingHelper.parseStringMethod(map['email']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    sosContacts =
        ParsingHelper.parseListMethod<dynamic, String>(map['sosContacts']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id": id,
      "name": name,
      "image": image,
      "mobile": mobile,
      "email": email,
      "createdTime": toJson ? createdTime?.toDate().toIso8601String() : createdTime,
      "sosContacts": sosContacts,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}

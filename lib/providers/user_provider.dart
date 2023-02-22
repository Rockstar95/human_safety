import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_safety/models/user_model.dart';
import 'package:human_safety/utils/my_print.dart';

class UserProvider extends ChangeNotifier {
  String userid = "";
  User? firebaseUser;
  UserModel? userModel;

  int selectedScreen = 0;

  void setScreen(int index) {
    selectedScreen = index;
    MyPrint.printOnConsole("Selected index:$index");
    notifyListeners();
  }

  String backgroundImageUrl = "";
}

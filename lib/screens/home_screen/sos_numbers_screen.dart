import 'package:human_safety/configs/constants.dart';
import 'package:human_safety/providers/user_provider.dart';
import 'package:human_safety/utils/my_print.dart';
import 'package:human_safety/utils/snakbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/SizeConfig.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';
import '../common/components/modal_progress_hud.dart';

class SOSNumbersScreen extends StatefulWidget {
  static const String routeName = "/SOSNumbersScreen";

  const SOSNumbersScreen({Key? key}) : super(key: key);

  @override
  State<SOSNumbersScreen> createState() => _SOSNumbersScreenState();
}

class _SOSNumbersScreenState extends State<SOSNumbersScreen> {
  bool isLoading = false;

  List<TextEditingController> textEditingControllers = <TextEditingController>[];

  Future<void> updateSOSNumbersInFirebase() async {
    String userId = Provider.of<UserProvider>(context, listen: false).userid;

    if(userId.isEmpty) {
      Snakbar.showErrorSnakbar(context: context, msg: "User Not Logged In");
      return;
    }

    isLoading = true;
    setState(() {});

    List<String> contacts = textEditingControllers.map((e) => e.text.trim()).toList();

    bool isSuccess = false;

    try {
      await FirebaseNodes.usersDocumentReference(userId: userId).update({
        "sosContacts" : contacts,
      });

      isSuccess = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Updating SOS Contacts:$e");
      MyPrint.printOnConsole(s);
    }

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.userModel?.sosContacts = contacts;
    userProvider.notifyListeners();

    isLoading = false;
    setState(() {});

    MyPrint.printOnConsole("isSuccess:$isSuccess");
    if(isSuccess) {
      Snakbar.showSuccessSnakbar(context: context, msg: "SOS Contacts Updated Successfully");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    List<String> contacts = Provider.of<UserProvider>(context, listen: false).userModel?.sosContacts ?? <String>[];

    for (int i = 0; i < 3; i++) {
      textEditingControllers.add(TextEditingController(text: i < contacts.length ? contacts[i] : ""));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: Styles.background,
        body: SafeArea(
          child: Column(
            children: [
              MyAppBar(
                title: "SOS Contacts",
                color: Colors.white,
                backbtnVisible: false,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(textEditingControllers.length, (index) {
                        return getTextFieldFromController(
                          controller: textEditingControllers[index],
                          index: index,
                        );
                      }),
                      getUpdateButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTextFieldFromController({required TextEditingController controller, required int index}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: textFieldDecorationWidget(
          hint: "Enter Sos Mobile Number (+91)",
        ),
        validator: (String? text) {
          if (text?.isEmpty ?? true) {
            return "Sos Contact Cannot Be Empty";
          }

          return null;
        },
      ),
    );
  }

  InputDecoration textFieldDecorationWidget({required String hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade50),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Widget getUpdateButton() {
    return ElevatedButton(
      onPressed: () {
        bool isDataAvailable = textEditingControllers.where((element) => element.text.trim().isNotEmpty).isNotEmpty;

        if(!isDataAvailable) {
          Snakbar.showErrorSnakbar(context: context, msg: "Add atleast one SOS Contact");
          return;
        }

        MyPrint.printOnConsole("Valid");
        updateSOSNumbersInFirebase();
      },
      child: const Text("Update"),
    );
  }
}

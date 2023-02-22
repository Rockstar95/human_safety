import 'package:human_safety/controllers/navigation_controller.dart';
import 'package:human_safety/providers/user_provider.dart';
import 'package:human_safety/utils/myutils.dart';
import 'package:human_safety/utils/snakbar.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

import '../utils/my_print.dart';

class ShakeController {
  static final ShakeController _instance = ShakeController._();
  factory ShakeController() => _instance;
  ShakeController._();

  ShakeDetector? detector;
  bool isPopupShown = false;

  void startListening() {
    MyPrint.printOnConsole("ShakeController().startListening called");

    stopListening();
    detector = ShakeDetector.autoStart(onPhoneShake: () async {
      MyPrint.printOnConsole("Device Shaken");

      if (isPopupShown) return;

      BuildContext? context = NavigationController.mainNavigatorKey.currentContext;
      if (context != null) {
        // Snakbar.showSuccessSnakbar(context: context, msg: "Device Shaken");

        List<String> sosContacts = Provider.of<UserProvider>(context, listen: false).userModel?.sosContacts ?? <String>[];
        if(sosContacts.isEmpty) {
          MyPrint.printOnConsole("sosContacts not found");
          // Snakbar.showErrorSnakbar(context: context, msg: "sosContacts not found");
          return;
        }

        isPopupShown = true;

        bool isSend = await showIsSendDialog(context: context);

        isPopupShown = false;

        if (isSend) {
          LocationData? locationData = await MyUtils.getLocation();
          await Future.wait(sosContacts.map((e) => MyUtils.sendMessage3(
            mobileNumber: e,
            message: "I need Help https://www.google.com/maps/search/?api=1&query=${locationData?.latitude},${locationData?.longitude}",
          )));
        }
      }
    });
  }

  void stopListening() {
    MyPrint.printOnConsole("ShakeController().stopListening called");
    detector?.stopListening();
    detector = null;
    isPopupShown = false;
  }

  Future<bool> showIsSendDialog({required BuildContext context}) async {
    dynamic value = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Shake Detected"),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Send Message?"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Send"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });

    return value == true;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:human_safety/controllers/shake_controller.dart';
import 'package:human_safety/utils/my_print.dart';
import 'package:human_safety/utils/myutils.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String bgImage = "";

  @override
  void initState() {
    super.initState();
    bgImage = Provider.of<UserProvider>(context, listen: false).backgroundImageUrl;
    ShakeController().startListening();
  }

  @override
  void dispose() {
    ShakeController().startListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: Container(
        decoration: BoxDecoration(
          image: (bgImage.isNotEmpty) ? DecorationImage(
            image: CachedNetworkImageProvider(bgImage),
            fit: BoxFit.fill,
          ) : null,
        ),
        child: Column(
          children: [
            getAppBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white, width: 2),
                        color: Styles.primaryColor,
                      ),
                      child: const Text(
                        "Shake Your mobile To Send SOS",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBar() {
    return MyAppBar(
      title: "Home",
      color: Colors.white,
      backbtnVisible: false,
    );
  }

  Widget getButton() {
    return GestureDetector(
      onTap: () async {
        LocationData? locationData = await MyUtils.getLocation();
        MyPrint.printOnConsole('locationData:$locationData');

        /*MyUtils.sendMessage(
          mobileNumber: "+919510363430",
          message: "Hii Hello",
        );*/

        /*String response = await MyUtils.sendMessage2(
          mobileNumber: "+919510363430",
          message: "Hii Hello",
        );
        MyPrint.printOnConsole('response:$response');*/

        /*String response = await MyUtils.sendMessage3(
          mobileNumber: "+919510363430",
          message: "Hii Hello",
        );
        MyPrint.printOnConsole('response:$response');*/
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white, width: 2),
          color: Styles.primaryColor,
        ),
        child: const Text(
          "Start Game",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

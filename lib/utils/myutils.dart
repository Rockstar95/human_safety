import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../controllers/firestore_controller.dart';
import '../models/new_document_data_model.dart';
import 'my_print.dart';
import 'snakbar.dart';

class MyUtils {
  static void copyToClipboard(BuildContext context, String string) {
    if (string.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: string));
      Snakbar.showSuccessSnakbar(
        context: context,
        msg: "Copied",
      );
    }
  }

  static String getCachedFirebaseImageUrlFromUrl(String url) {
    if (url.startsWith("https://storage.googleapis.com/")) {
      return url;
    } else if (url.startsWith("https://firebasestorage.googleapis.com/")) {
      String bucketName = Firebase.app().options.storageBucket ?? "my-image-editor-7eaeb.appspot.com";

      String newUrl = url;
      newUrl = newUrl.replaceAll(newUrl.substring(0, newUrl.indexOf(bucketName)), "https://storage.googleapis.com/");
      newUrl = newUrl.replaceAll("%2F", "/");
      newUrl = newUrl.replaceAll("/o/", "/");
      newUrl = newUrl.substring(0, newUrl.indexOf("?"));
      //MyPrint.printOnConsole("newUrl:${newUrl}");

      return newUrl;
    } else {
      return url;
    }
  }

  static String getUniqueId() {
    return FirestoreController.documentReference(
      collectionName: "collectionName",
    ).id;
    // return FirestoreController().firestore.collection("df").doc().id;
    // return const Uuid().v1().replaceAll("-", "");
  }

  static Future<NewDocumentDataModel> getNewDocIdAndTimeStamp({bool isGetTimeStamp = true}) async {
    String docId = FirestoreController.documentReference(
      collectionName: "collectionName",
    ).id;
    Timestamp timestamp = Timestamp.now();

    if (isGetTimeStamp) {
      await FirestoreController.collectionReference(
        collectionName: "timestamp_collection",
      ).add({"temp_timestamp": FieldValue.serverTimestamp()}).then((DocumentReference<Map<String, dynamic>> reference) async {
        docId = reference.id;

        if (isGetTimeStamp) {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get();
          timestamp = documentSnapshot.data()?['temp_timestamp'];
        }

        reference.delete();
      }).catchError((e, s) {
        // reportErrorToCrashlytics(e, s, reason: "Error in DataController.getNewDocId()");
      });

      if (docId.isEmpty) {
        docId = FirestoreController.documentReference(
          collectionName: "collectionName",
        ).id;
      }
    }

    return NewDocumentDataModel(docid: docId, timestamp: timestamp);
  }

  static String encodeJson(Object? object) {
    try {
      return jsonEncode(object);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.encodeJson():$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }

  static dynamic decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.decodeJson():$e");
      MyPrint.printOnConsole(s);
      return null;
    }
  }

  static bool isValidMobileNumber(String mobileNumber) {
    RegExp exp = RegExp(r"^\s*(?:\+?(\d{1,3}))?([-. (]*(\d{3})[-. )]*)?((\d{3})[-. ]*(\d{2,4})(?:[-.x ]*(\d+))?)\s*$");

    return exp.hasMatch(mobileNumber);
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String url = Platform.isIOS
        ? "https://maps.apple.com/?q=$latitude,$longitude"
        : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    Uri uri = Uri.parse(url);
    bool canLaunch = await url_launcher.canLaunchUrl(uri);
    if (canLaunch) {
      await url_launcher.launchUrl(uri);
      // await url_launcher.launch(url);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<LocationData?> getLocation() async {
    LocationData? locationData;

    try {
      Location location = Location();

      bool serviceEnabled = false;
      PermissionStatus? permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return locationData;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return locationData;
        }
      }

      locationData = await location.getLocation();
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Fetching Location:$e");
      MyPrint.printOnConsole(s);
    }

    return locationData;
  }

  static Future<void> sendMessage({required String mobileNumber, required String message}) async {
    String url = "sms:$mobileNumber?&body=$message";

    Uri uri = Uri.parse(url);
    bool canLaunch = await url_launcher.canLaunchUrl(uri);
    if (canLaunch) {
      await url_launcher.launchUrl(uri);
      // await url_launcher.launch(url);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<String> sendMessage2({required String mobileNumber, required String message}) async {
    String result = await sendSMS(message: message, recipients: [mobileNumber]).catchError((onError) {
      MyPrint.printOnConsole(onError);
    });

    return result;
  }

  static Future<String> sendMessage3({required String mobileNumber, required String message}) async {
    permission_handler.Permission permission = permission_handler.Permission.sms;

    bool isPermissionGranted = await permission.isGranted;
    if (!isPermissionGranted) {
      permission_handler.PermissionStatus permissionStatus = await permission.request();

      if (permissionStatus == (permission_handler.PermissionStatus.granted)) {
        isPermissionGranted = true;
      }
    }

    if (!isPermissionGranted) {
      return "Permission Not Granted";
    }

    const platform = MethodChannel('sendSms');

    String result = "Failed to send";

    try {
      result = await platform.invokeMethod('send', <String, dynamic>{"phone": mobileNumber, "msg": message});
      MyPrint.printOnConsole(result);
    } on PlatformException catch (e, s) {
      MyPrint.printOnConsole("PlatformException in Sending Message:$e");
      MyPrint.printOnConsole(s);
    } on Exception catch (e, s) {
      MyPrint.printOnConsole("Error in Sending Message:$e");
      MyPrint.printOnConsole(s);
    }

    return result;
  }

  /*static Future<void> launchWhatsAppChat({required String mobileNumber, String message = ""}) async {
    MyPrint.printOnConsole("launchWhatsAppChat called with mobileNumber:$mobileNumber");

    if(mobileNumber.isEmpty || !isValidMobileNumber(mobileNumber)) {
      MyPrint.printOnConsole("Mobile Number is Empty or Invalid");
      return;
    }

    String urlString = "https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}";
    MyPrint.printOnConsole("urlString:$urlString");

    await launchUrlString(url: urlString);
  }

  static Future<void> launchCallMobileNumber({required String mobileNumber}) async {
    MyPrint.printOnConsole("launchCallMobileNumber called with mobileNumber:$mobileNumber");

    if(mobileNumber.isEmpty || !isValidMobileNumber(mobileNumber)) {
      MyPrint.printOnConsole("Mobile Number is Empty or Invalid");
      return;
    }

    String urlString = "tel://$mobileNumber";
    MyPrint.printOnConsole("urlString:$urlString");

    await launchUrlString(url: urlString);
  }*/

  /*static Future<void> launchUrlString({required String url, LaunchMode launchMode = LaunchMode.externalApplication}) async {
    MyPrint.printOnConsole("launchUrlString called with:$url");

    Uri? uri = Uri.tryParse(url);

    if(uri != null) {
      try {
        await launchUrl(uri, mode:launchMode);
      }
      catch(e, s) {
        MyPrint.printOnConsole("Error in launching url $url in launchUrlString():$e");
        MyPrint.printOnConsole(s);
      }
    }
    else {
      MyPrint.printOnConsole("Uri is Null");
    }
  }*/

  static String formatAmountInString(double amount) {
    NumberFormat formatter = NumberFormat('##,##,##,##,##,###');
    return formatter.format(amount);
  }
}

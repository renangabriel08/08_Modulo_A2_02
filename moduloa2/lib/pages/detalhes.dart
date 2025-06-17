import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:moduloa2/styles/cores.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:photo_manager/photo_manager.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  TextEditingController coment = TextEditingController();
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
    await App.getComments();
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
      appBar: AppBar(title: Text('Detalhes da Escola')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: width,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      App.escola['nome'],
                      style: TextStyle(
                        color: Cores.azulClaro,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          base64Decode(
                            App.escola['image'].toString().split(',').last,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (
                          int i = 0;
                          i < App.escola['avaliacao'].round();
                          i++
                        )
                          Icon(Icons.star, color: Colors.amber, size: 40),
                        if (App.escola['avaliacao'].round() < 5)
                          for (
                            int e = App.escola['avaliacao'].round();
                            e < 5;
                            e++
                          )
                            Icon(
                              Icons.star_border,
                              color: Colors.grey,
                              size: 40,
                            ),
                      ],
                    ),
                    Container(height: 16),
                    Column(
                      children: [
                        for (var comentario in App.comentarios)
                          if (comentario['id_escola'].toString() ==
                              App.escola['id'].toString())
                            ListTile(
                              title: Text(comentario['comentario']),
                              subtitle: Text(comentario['data_hora']),
                            ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/mapa'),
                          child: Text('Mapa'),
                        ),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: TextFormField(
                                  controller: coment,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancelar'),
                                ),

                                TextButton(
                                  onPressed: () async {
                                    await App.postComments(
                                      App.escola['id'],
                                      coment.text,
                                    );
                                    await App.getComments();
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  child: Text('Adicionar comentário'),
                                ),
                              ],
                            ),
                          ),
                          child: Text('Fazer comentário'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

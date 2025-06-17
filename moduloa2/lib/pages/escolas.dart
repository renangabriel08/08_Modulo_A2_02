import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  bool loading = true;

  startApp() async {
    await App.getEscolas();
    await App.validarToken(context);

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
      appBar: AppBar(title: Text('Lista de escolas')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: width,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var escola in App.escolas)
                      ListTile(
                        title: Text(escola['nome']),
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

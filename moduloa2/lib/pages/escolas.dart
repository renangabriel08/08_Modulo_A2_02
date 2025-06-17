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

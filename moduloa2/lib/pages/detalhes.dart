import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Escola')),
      body: Container(
        width: width,
        height: height,
        child: Column(children: [

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:moduloa2/styles/cores.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('Bem-vindo, ${App.user['name']}')),
      drawer: Drawer(
        child: Column(
          children: [
            Row(children: [Image.asset('assets/logo.png'), Text('SafeEdu')]),
            Divider(),
            ListTile(
              title: Text('Lista de escolas'),
              onTap: () => Navigator.pushNamed(context, '/escolas'),
            ),
            ListTile(
              title: Text('Mapa'),
              onTap: () => Navigator.pushNamed(context, '/mapa'),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            Center(
              child: Text(
                App.motdString,
                style: TextStyle(
                  color: Cores.azulClaro,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

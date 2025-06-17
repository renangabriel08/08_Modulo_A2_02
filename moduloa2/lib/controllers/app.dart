import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:moduloa2/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static String base = 'https://workspace.dinizeotecnologia.com.br/worldskills';
  static String token = '';
  static String motdString = '';
  static Map user = {};
  static List comentarios = [];
  static List escolas = [];
  static Map escola = {};
  static bool manter = false;

  static salvarDadosLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    await prefs.setBool('manter', manter);
  }

  static getDados() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    manter = prefs.getBool('manter') ?? false;
  }

  static getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = jsonDecode(prefs.getString('user') ?? '');
  }

  static apagarDados() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('manter');
    prefs.remove('user');
  }

  static logar(String email, String senha, BuildContext context) async {
    try {
      final url = Uri.parse('$base/jwt/generate_token');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": senha}),
      );

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
        token = res['token'];
        user = JwtDecoder.decode(token);
        user['senha'] = senha;

        await salvarDadosLogin();
        await getMotd();

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        MyToast.get('Login realizado com sucesso');
      } else {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
        MyToast.get(res['error']);
      }
    } catch (e) {
      MyToast.get('Erro ao realizar login');
    }
  }

  static validarToken(BuildContext context) async {
    try {
      final url = Uri.parse('$base/jwt/validate_token');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      if (req.statusCode == 200) {
        MyToast.get('Token válido');
      } else {
        MyToast.get('Token inválido');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      MyToast.get('Erro ao validar token');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  static getMotd() async {
    try {
      final url = Uri.parse('$base/A2/motd');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
        motdString = res['MOTD'];
      } else {
        MyToast.get('Erro ao buscar dados');
      }
    } catch (e) {
      MyToast.get('Erro ao buscar dados');
    }
  }

  static getEscolas() async {
    try {
      final url = Uri.parse('$base/A2/school_list');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
        escolas = res['escolas'];
      } else {
        MyToast.get('Erro ao buscar escolas');
      }
    } catch (e) {
      MyToast.get('Erro ao buscar escolas');
    }
  }

  static getComments() async {
    try {
      final url = Uri.parse('$base/A2/comments');
      final req = await http.get(url);

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
        comentarios = res['comentarios'];
        MyToast.get('Comentários buscados com sucesso');
      } else {
        MyToast.get('Erro ao buscar comentários');
      }
    } catch (e) {
      MyToast.get('Erro ao buscar comentários');
    }
  }

  static postComments(id, comentario) async {
    try {
      final url = Uri.parse('$base/A2/comments');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_escola": id, "comentario": comentario}),
      );

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
      }
    } catch (e) {
      MyToast.get('Erro ao realizar login');
    }
  }

  static postPrints(File print) async {
    try {
      final url = Uri.parse('$base/A2/prints');
      final req = http.MultipartRequest('POST', url);
      final img = http.MultipartFile(
        'imagem',
        print.openRead(),
        print.lengthSync(),
        filename: print.path.substring(print.path.lastIndexOf('/')),
      );

      req.fields['id_user'] = App.user['id']?.toString() ?? '1';
      req.files.add(img);

      final res = await req.send();

      if (res.statusCode == 200) {
        MyToast.get('Print enviado para nossa base de dados');
      } else {
        MyToast.get('Erro ${res.statusCode} ');
      }
    } catch (e) {
      MyToast.get('Erro ao enviar print');
    }
  }
}

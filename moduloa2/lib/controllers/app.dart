import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:moduloa2/widgets/toast.dart';

class App {
  static String base = 'https://workspace.dinizeotecnologia.com.br/worldskills';
  static String token = '';
  static String motdString = '';
  static Map user = {};
  static List comentarios = [];
  static List escolas = [];
  static Map escola = {};

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

  static postPrints() async {
    try {
      final url = Uri.parse('$base/A2/prints');
      final req = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (req.statusCode == 200) {
        final res = jsonDecode(utf8.decode(req.bodyBytes));
      }
    } catch (e) {
      MyToast.get('Erro ao realizar login');
    }
  }
}

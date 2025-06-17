import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moduloa2/styles/cores.dart';

class MyToast {
  static get(String txt) {
    Fluttertoast.showToast(
      msg: txt,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Cores.azulEscuro,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
/*
* Essa classe contém os estilos de texto usados ao longo das telas
* */
class ControllerCommon {
  static TextStyle estiloTexto(String tipo, Color color) {
    switch (tipo) {
      case "normal":
        return TextStyle(fontSize: 15, fontFamily: "BalooTamma2", color: color);
        break;

      case "titulo 2 negrito":
        return TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            fontFamily: "BalooTamma2",
            color: color);
        break;

      case "normal negrito":
        return TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: "BalooTamma2",
            color: color);
        break;

      case "com cor":
        return TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: "BalooTamma2",
            color: color);
        break;

      case "titulo":
        return TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "BalooTamma2",
            color: color);
        break;

      case "titulo principal":
        return TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            fontFamily: "BalooTamma2",
            color: color);
        break;

      default:
        return TextStyle(fontSize: 15, fontFamily: "BalooTamma2");
        break;
    }
  }

  static estiloTextoNegrito(double tamanhoFonte) {
    return TextStyle(
        fontSize: tamanhoFonte,
        fontWeight: FontWeight.w700,
        fontFamily: "BalooTamma2");
  }

  static estiloTextoNormal(double tamanhoFonte) {
    return TextStyle(fontSize: tamanhoFonte, fontFamily: "BalooTamma2");
  }

  Future<String> uploadFile(File _image, String username, String pasta) async {
    print("uploadFile");
    var now = DateTime.now();
    String dataAgora =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year.toString()}-${now.hour.toString()}h${now.minute.toString()}";

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('${pasta}/${Path.basename(username + "_" + dataAgora)}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);
    String url = "none";

    try {
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      print('Uploaded ${snapshot.bytesTransferred} bytes.');

      print('File Uploaded');
      url = await storageReference.getDownloadURL();
      while (url == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
    } on firebase_core.FirebaseException catch (e) {
      // print(uploadTask.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }
    return url;
    // await uploadTask.onComplete;
  }
}

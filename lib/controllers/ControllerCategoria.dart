import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/FirebaseDB.dart';
import 'package:verde_vegetal_app/model/Categoria.dart';

class ControllerCategoria {
  //Cadastrar view.produto
  Future<String> cadastraCategoria(Categoria categoria, File _image) async {
    try {
      var lista = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('categoria')
          .where("nome", isEqualTo: categoria.nome)
          .get();
      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
        // print(element.data());
      });

      if (lista.length > 0) {
        return "Já cadastrado";
      }

      ControllerCommon _ctrCommon = ControllerCommon();
      String url = "none";
      url = await _ctrCommon.uploadFile(
          _image, categoria.nome + "_1", "categorias");
      while (url == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
      print(url);
      categoria.imagePath = url;

      CollectionReference cat =
          FirebaseFirestore.instance.collection('categoria');
      await cat.add(categoria.getProdutoJson());
      print("inserido");

      return "Inserido";
    } catch (err) {
      print(err);
      return "Erro";
    }
  }

  Future<List> recuperaCategoria() async {
    try {
      var lista = [];

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categoria').get();

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });
      lista.sort((a, b) => a["nome"].compareTo(b["nome"]));

      // print(lista.toString());

      if (lista.length == 0) return null;

      return lista;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<List> recuperaCategoriaComboBox() async {
    try {
      var lista = [];

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categoria').get();

      querySnapshot.docs.forEach((element) {
        lista.add(element.data()["nome"]);
      });

      if (lista.length == 0) return [];
      lista.sort((a, b) => a.compareTo(b));

      return lista;
    } catch (err) {
      print(err);
      return [];
    }
  }

  static Future<dynamic> produtosCategoria(String categoria) async {
    try {
      var lista = [];
      QuerySnapshot querySnapshot;

      if (categoria.contains("Cesta")) {
        querySnapshot = await FirebaseDB.findQuery("cesta", "status", "ativo");

        querySnapshot.docs.forEach((element) {
          lista.add(element.data());
        });
      } else {

        querySnapshot = await FirebaseDB.findQuery2Where("produto", "categoria", categoria, "status", "ativo");

        querySnapshot.docs.forEach((element) {
          lista.add(element.data());
        });
      }

      if (querySnapshot.docs.length == 0) return new List();

      return lista;
    } catch (err) {
      print(err);
      return new List();
    }
  }

}

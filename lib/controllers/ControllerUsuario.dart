import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/model/DadosVendedor.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';

import 'FirebaseDB.dart';

class ControllerUsuario {
  recuperarDadosVisualizacaoPerfil() async {
    var usuario = null;
    ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
    usuario = await ctrAutenticacao.recuperaLoginSalvo();

    while (usuario == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    var dadosVendedor = null;
    dadosVendedor =
        await this.recuperaDadosVendedorPorUsername(usuario.username);

    Map freteVendedor = {};
    freteVendedor = await recuperaFreteVendedorPorUsername(usuario.username);

    while (dadosVendedor == null && freteVendedor == {}) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    Map<String, dynamic> retorno = {
      "message": "Sucesso",
      "usuario": usuario,
      "dadosVendedor": dadosVendedor,
      "freteVendedor": freteVendedor
    };

    return retorno;
  }

  recuperarDadosVisualizacaoPerfilPublico(String username) async {
    print("recuperarDadosVisualizacaoPerfilPublico");

    var usuario = null;
    usuario = await this.recuperaUsuarioPorUsername(username);

    while (usuario == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    var dadosVendedor = null;
    dadosVendedor = await this.recuperaDadosVendedorPorUsername(username);

    Map freteVendedor = {};
    freteVendedor = await recuperaFreteVendedorPorUsername(usuario.username);

    while (dadosVendedor == null && freteVendedor == {}) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    Map<String, dynamic> retorno = {
      "message": "Sucesso",
      "usuario": usuario,
      "dadosVendedor": dadosVendedor,
      "freteVendedor": freteVendedor
    };

    return retorno;
  }

  Future<dynamic> recuperaUsuarioPorEmail(String email) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("users", "email", email);

      if (querySnapshot.docs.length == 0) {
        return {"message": "Vazio", "erro": "nada"};
      }
      Usuario usuario = Usuario(
          querySnapshot.docs[0].data()["bairro"],
          querySnapshot.docs[0].data()["cep"],
          querySnapshot.docs[0].data()["cidade"],
          querySnapshot.docs[0].data()["cnpj"],
          querySnapshot.docs[0].data()["complemento"],
          querySnapshot.docs[0].data()["cpf"],
          querySnapshot.docs[0].data()["dataCadastro"] == null
              ? Timestamp.fromDate(DateTime.parse("2021-03-07"))
              : querySnapshot.docs[0].data()["dataCadastro"],
          querySnapshot.docs[0].data()["email"],
          querySnapshot.docs[0].data()["estado"],
          querySnapshot.docs[0].data()["imagePath"],
          querySnapshot.docs[0].data()["logradouro"],
          querySnapshot.docs[0].data()["nome"],
          querySnapshot.docs[0].data()["num"],
          "",
          querySnapshot.docs[0].data()["statusConta"],
          querySnapshot.docs[0].data()["telefone"],
          querySnapshot.docs[0].data()["tipoConta"],
          querySnapshot.docs[0].data()["username"]);

      return {"message": "Sucesso", "usuario": usuario};
    } catch (err) {
      print(err);
      return {"message": "vazio", "erro": err.toString()};
    }
  }

  Future<dynamic> recuperaUsuarioPorUsername(String username) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("users", "username", username);

      if (querySnapshot.docs.length == 0) {
        return {"erro": "nada"};
      }
      Usuario usuario = Usuario(
          querySnapshot.docs[0].data()["bairro"],
          querySnapshot.docs[0].data()["cep"],
          querySnapshot.docs[0].data()["cidade"],
          querySnapshot.docs[0].data()["cnpj"],
          querySnapshot.docs[0].data()["complemento"],
          querySnapshot.docs[0].data()["cpf"],
          querySnapshot.docs[0].data()["dataCadastro"] == null
              ? Timestamp.fromDate(DateTime.parse("2021-03-07"))
              : querySnapshot.docs[0].data()["dataCadastro"],
          querySnapshot.docs[0].data()["email"],
          querySnapshot.docs[0].data()["estado"],
          querySnapshot.docs[0].data()["imagePath"],
          querySnapshot.docs[0].data()["logradouro"],
          querySnapshot.docs[0].data()["nome"],
          querySnapshot.docs[0].data()["num"],
          "",
          querySnapshot.docs[0].data()["statusConta"],
          querySnapshot.docs[0].data()["telefone"],
          querySnapshot.docs[0].data()["tipoConta"],
          querySnapshot.docs[0].data()["username"]);

      return usuario;
    } catch (err) {
      print(err);
      return {"erro": "nada"};
    }
  }

  Future<dynamic> recuperaDadosVendedorPorUsername(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseDB.findQuery(
          "dadosVendedor", "usernameVendedor", username);

      if (querySnapshot.docs.length == 0) {
        return {"message": "Vazio"};
      }

      DadosVendedor dadosVendedor = DadosVendedor(
          querySnapshot.docs[0].data()["usernameVendedor"],
          querySnapshot.docs[0].data()["emailYapay"],
          querySnapshot.docs[0].data()["cpfYapay"],
          querySnapshot.docs[0].data()["cnpjYapay"],
          querySnapshot.docs[0].data()["pagamentoEntregaDinheiro"],
          querySnapshot.docs[0].data()["pagamentoEntregaCartao"],
          querySnapshot.docs[0].data()["pagamentoOnline"],
          querySnapshot.docs[0].data()["frete"]);

      Map<String, dynamic> retorno = {
        "message": "sucesso",
        "data": dadosVendedor
      };

      return retorno;
    } catch (err) {
      print(err);
      return {"message": "Erro", "erro": err};
    }
  }

  static Future<Map<String, dynamic>> recuperaFreteVendedorPorUsername(
      String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseDB.findQuery(
          "freteVendedor", "usernameVendedor", username);

      if (querySnapshot.docs.length == 0) {
        return {"message": "vazio", "data": {}};
      }

      FreteVendedor freteVendedor = FreteVendedor(
          querySnapshot.docs[0].data()["usernameVendedor"],
          querySnapshot.docs[0].data()["localidades"]);

      Map<String, dynamic> retorno = {
        "message": "sucesso",
        "data": freteVendedor
      };

      return retorno;
    } catch (err) {
      print(err);
      return {"message": "Erro", "erro": err, "data": {}};
    }
  }

  //Cadastrar view.usuario
  Future<String> atualizaDadosBasicos(
      Map<String, String> dados, String username) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("users", "username", username);

      if (querySnapshot.docs.length == 1) {
        var usuario = FirebaseFirestore.instance
            .collection('users')
            .doc(querySnapshot.docs[0].id);
        await usuario.update(dados);

        salvaUsuarioCache(querySnapshot.docs[0].data());

        return "true";
      }

      return "false";
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return "false";
    }
  }

  static Future<String> atualizaFreteVendedor(
      String username, Map dados) async {
    try {
      print("atualizaFreteVendedor");

      var usuario = null;
      ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
      usuario = await ctrAutenticacao.recuperaLoginSalvo();
      //Procura no banco
      QuerySnapshot querySnapshot = await FirebaseDB.findQuery(
          "freteVendedor", "usernameVendedor", username);

      if (querySnapshot.docs.length == 1) {
        await FirebaseDB.update(
            "freteVendedor", querySnapshot.docs[0].id, {"localidades": dados});

        return "true";
      } else if (querySnapshot.docs.length == 0) {
        await FirebaseDB.save("freteVendedor", {"usernameVendedor": username, "localidades": dados});

      }
      print("false");
      return "false";
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return "false";
    }
  }

  static Future<String> salvaUsuarioCache(Map usuario) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("usuario"); //Se tiver remove para inserir novamente
    prefs.setStringList("usuario", [
      usuario["bairro"],
      usuario["cep"],
      usuario["cidade"],
      usuario["cnpj"],
      usuario["complemento"],
      usuario["cpf"],
      usuario["dataCadastro"].toDate().toString(),
      usuario["email"],
      usuario["estado"],
      usuario["imagePath"],
      usuario["logradouro"],
      usuario["nome"],
      usuario["num"],
      "esconde_senha",
      usuario["statusConta"],
      usuario["telefone"],
      usuario["tipoConta"],
      usuario["username"]
    ]);

    return "ok";
  }
}

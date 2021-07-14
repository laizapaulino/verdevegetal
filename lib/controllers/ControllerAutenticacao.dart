import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/DadosVendedor.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';

class ControllerAutenticao {
  //Cadastrar view.usuario
  Future<String> cadastraUsuario(Usuario usuario) async {
    try {
      usuario.statusConta = "ativo";
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.add(usuario.getUsuarioJson());

      await (ControllerAutenticao()).loginUsuario(usuario.email);
      return "true";
    } catch (err) {
      print(err);
      return "false";
    }
  }

  Future<String> desativaUsuario() async {
    var usuario = await this.recuperaLoginSalvo();

    if (usuario.runtimeType == Usuario) {
      //Verifica se tem compras em andamento
      QuerySnapshot comprasSnapshot = await FirebaseFirestore.instance
          .collection('compraReferencia')
          .where('usernameComprador', isEqualTo: usuario.username)
          .where('status', whereIn: [
        "Aguardando confirmação do vendedor",
        "Preparando \nentrega",
        "Preparando entrega"
      ]).get();

      //Se sim, não permite
      if (comprasSnapshot.docs.length > 0) {
        return "Você ainda tem compras pendentes.";
      } else {
        if (usuario.tipoConta == "Vendedor") {
          //Verifica se ele tem pedidos não entregues
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('compraReferencia')
              .where('usernameVendedor', isEqualTo: usuario.username)
              .where('status', whereIn: [
            "Aguardando confirmação do vendedor",
            "Preparando \nentrega",
            "Preparando entrega"
          ]).get();

          //Se sim, não permite
          if (querySnapshot.docs.length > 0) {
            print("PENDENTE");
            return "Você ainda tem vendas pendentes.";
          } else {
            //Senão inativa todos os produtos
            await FirebaseFirestore.instance
                .collection("produto")
                .where('usernameVendedor', isEqualTo: usuario.username)
                .where('status', isEqualTo: "ativo")
                .get()
                .then((snap) {
              snap.docs.forEach((doc) {
                doc.reference.update({"status": "inativo"});
              });
            });

            //Senão inativa todos os produtos
            await FirebaseFirestore.instance
                .collection("cesta")
                .where('usernameVendedor', isEqualTo: usuario.username)
                .where('status', isEqualTo: "ativo")
                .get()
                .then((snap) {
              snap.docs.forEach((doc) {
                doc.reference.update({"status": "inativo"});
              });
            });
          }
        }

        String inativa = "none";
        inativa = await ControllerUsuario()
            .atualizaDadosBasicos({"statusConta": "inativo"}, usuario.username);

        return "sucesso";
      }
    }
  }

  static Future<String> ativaUsuario() async {
    var usuario = await (ControllerAutenticao()).recuperaLoginSalvo();

    if (usuario.runtimeType == Usuario) {
      String ativa = "none";
      ativa = await ControllerUsuario()
          .atualizaDadosBasicos({"statusConta": "ativo"}, usuario.username);

      return "sucesso";
    }
  }

  Future<String> cadastraDadosVendedor(DadosVendedor dadosVendedor) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dadosVendedor')
          .where('usernameVendedor', isEqualTo: dadosVendedor.usernameVendedor)
          .get();

      if (querySnapshot.docs.length > 0) {
        var vendedor = FirebaseFirestore.instance
            .collection('dadosVendedor')
            .doc(querySnapshot.docs[0].id);
        await vendedor.update(dadosVendedor.getDadosVendedorJson());
      } else {
        CollectionReference users =
            FirebaseFirestore.instance.collection('dadosVendedor');
        await users.add(dadosVendedor.getDadosVendedorJson());
      }
      return "true";
    } catch (err) {
      print(err);
      return "false";
    }
  }

  Future<String> cadastraAtualizareteVendedor(FreteVendedor freteVendedor) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('freteVendedor')
          .where('usernameVendedor', isEqualTo: freteVendedor.usernameVendedor)
          .get();

      if (querySnapshot.docs.length > 0) {
        var vendedor = FirebaseFirestore.instance
            .collection('freteVendedor')
            .doc(querySnapshot.docs[0].id);
        await vendedor.update(freteVendedor.getFreteVendedorJson());
      } else {
        CollectionReference users =
        FirebaseFirestore.instance.collection('freteVendedor');
        await users.add(freteVendedor.getFreteVendedorJson());
      }
      return "true";
    } catch (err) {
      print(err);
      return "false";
    }
  }

  Future<Map> loginUsuario(String email) async {
    try {
      List lista = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      ControllerUsuario.salvaUsuarioCache(querySnapshot.docs[0].data());

      // print(lista[0]);
      return {"message": "Sucesso"};
    } catch (err) {
      print(err);
      return {"message": "Falha", "descricao": err.toString()};
    }
  }

  Future<dynamic> recuperaLoginSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove("usuario");
    var user = prefs.get("usuario");

    if (user != null) {
      Usuario usuario = Usuario(
          user[0],
          //bairro
          user[1],
          //cep
          user[2],
          //Cidade
          user[3],
          //cnpj
          user[4],
          // Complemento
          user[5],
          //cpf
          //cpf
          Timestamp.fromDate(DateTime.parse(user[6])),
          //Data cadastro
          user[7],
          //email
          user[8],
          //estado
          user[9],
          //imagePath
          user[10],
          user[11],
          user[12],
          user[13],
          user[14],
          user[15],
          user[16],
          user[17]);
      // print("erro: ${usuario.toString()}");

      return usuario;
    }
    return {"erro": "nada"};
  }

  Future<String> deslogar() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("usuario");
    return "pronto";
  }
}

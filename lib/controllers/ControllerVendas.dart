import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/CestaCarrinho.dart';
import 'package:verde_vegetal_app/model/CestaComprado.dart';
import 'package:verde_vegetal_app/model/Compra.dart';
import 'package:verde_vegetal_app/model/DadosVendedor.dart';
import 'package:verde_vegetal_app/model/ItemComprado.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';

import 'Email.dart';
import 'FirebaseDB.dart';

class ControllerVenda {
  //Upload imagem prod

  Future<String> cancelaItemCompra(
      String idProduto,
      String idCompra,
      String idItemComprado,
      String quemCancelou,
      String usernameVendedor) async {

    QuerySnapshot querySnapshot = await FirebaseDB.findQuery2Where(
        "compraReferencia",
        "idCompra",
        idCompra,
        "usernameVendedor",
        usernameVendedor);

    if (querySnapshot.docs.length > 0) {
      var compraReferencia = FirebaseFirestore.instance
          .collection('compraReferencia')
          .doc(querySnapshot.docs[0].id);

      Map<String, dynamic> dado = {
        "qtdProdutosCancelados":
            querySnapshot.docs[0].data()["qtdProdutosCancelados"] + 1
      };
      //Aguardando confirmação do vendedor
      if (querySnapshot.docs[0].data()["qtdProdutosCancelados"] + 1 >=
          querySnapshot.docs[0].data()["qtdProdutosComprados"]) {
        dado["status"] = "Cancelado";
      }
      //Acresce a quantia de compras canceladas
      await FirebaseDB.update(
          "compraReferencia", querySnapshot.docs[0].id, dado);

      QuerySnapshot querySnapshot2 = await FirebaseDB.findQuery(
          "itemComprado", "idItemComprado", idItemComprado);

      Map<String, String> atualiza = {
        "status": "Cancelado pelo ${quemCancelou}"
      };

      //Cancela o produto
      await FirebaseDB.update(
          "itemComprado", querySnapshot2.docs[0].id, atualiza);

      if (quemCancelou == "vendedor") {
        //Avisa comprador por email

        Email.sendRegistrationNotification(
            'Cancelamento item - Verde Vegetal',
            'Olá, ${querySnapshot2.docs[0].data()["nomeComprador"]}!<br><br>Infelizmente o item ${querySnapshot2.docs[0].data()["nome"]}, que você comprou, foi cancelado pelo vendedor.<br>Acesse o aplicativo <strong>Verde Vegetal</strong> para verificar mais detalhes.',
            querySnapshot2.docs[0].data()["usernameComprador"]);
      } else {
        // Avisa vendedor sobre o cancelamento

        DateTime now = new DateTime.fromMicrosecondsSinceEpoch(
            querySnapshot2.docs[0].data()["data"].microsecondsSinceEpoch);

        String dataCompra =
            ("${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString()} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}");

        Email.sendRegistrationNotification(
            'Cancelamento item - Verde Vegetal',
            'Olá, ${querySnapshot2.docs[0].data()["nomeVendedor"]}!<br><br>Infelizmente o item <strong>${querySnapshot2.docs[0].data()["nome"]}</strong> vendido em ${dataCompra} foi cancelado pelo comprador.<br>Acesse o aplicativo <strong>Verde Vegetal</strong> para verificar mais detalhes.',
            querySnapshot2.docs[0].data()["usernameVendedor"]);
      }

      //Devolve a qtdComprada ao produto -> qtd negativa pois essa função atualiza para menos
      if (querySnapshot2.docs[0].data().containsKey("unidadeMedida")) {
        //Produto
        await ControllerProduto().atualizaQtdProduto(
            idProduto,
            -(querySnapshot2.docs[0].data()["quantidade"]),
            "produto",
            "id_produto");
      } else {
        //Cesta
        await ControllerProduto().atualizaQtdProduto(idProduto,
            -(querySnapshot2.docs[0].data()["quantidade"]), "cesta", "idCesta");
      }
    }
    return "sucesso";

  }

  Future<String> mudaStatusCompraReferenciaVendedor(
      String idCompra, String previsaoEntrega, String status) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("compraReferencia", "idCompra", idCompra);

      if (querySnapshot.docs.length > 0) {
        if (status.contains("Preparando")) {
          await FirebaseDB.update("compraReferencia", querySnapshot.docs[0].id,
              {"previsaoEntrega": previsaoEntrega, "status": status});
        } else {
          await FirebaseDB.update(
              "compraReferencia", querySnapshot.docs[0].id, {"status": status});
        }

        QuerySnapshot querySnapshot2 =
            await FirebaseDB.findQuery("itemComprado", "idCompra", idCompra);

        if (status.contains("Preparando")) {
          //Avisa o comprador
          Email.sendRegistrationNotification(
              'Pedido - Verde Vegetal',
              'Olá, ${querySnapshot2.docs[0].data()["nomeComprador"]}!<br><br>O vendedor ${querySnapshot2.docs[0].data()["nomeVendedor"]}, confirmou seu pedido.<br><br>A entrega está prevista para ${previsaoEntrega}!<br>Acesse o aplicativo <strong>Verde Vegetal</strong> para verificar mais detalhes.',
              querySnapshot2.docs[0].data()["usernameComprador"]);
        }

        querySnapshot2.docs.forEach((element) async {
          if (element.data()["status"].toString().contains("Cancelado") ==
              false) {
            await FirebaseDB.update(
                "itemComprado", element.id, {"status": status});
          }
        });
      }
      return "sucesso";
    } catch (err) {
      return "erro";
    }
  }

  Future<Map> recuperaCompraPorData() async {

    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      List lista1 = [];
      List lista2 = [];
      Map lista3 = {};

      QuerySnapshot querySnapshot = await FirebaseDB.findQuery2WhereOrderBy(
          "compraReferencia",
          "usernameComprador",
          _usuario.username,
          "dataCompra",
          "",
          "dataCompra",
          true);

      if (querySnapshot.docs.length == 0)
        return {
          "message": "Não tem compras",
          "compras": lista1,
          "dadosVendedor": []
        };

      querySnapshot.docs.forEach((element) async {
        lista1.add(element.data());

        QuerySnapshot querySnapshot2 = await FirebaseDB.findQuery(
            "users", "username", element.data()["usernameVendedor"]);

        lista3.addAll({
          element.data()["usernameVendedor"]:
              querySnapshot2.docs[0].data()["nome"]
        });

        lista2.add(querySnapshot2.docs[0].data()["nome"]);
      });

      while (lista1.length > lista2.length) {
        await Future.delayed(Duration(seconds: 5), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      print(lista2.toString());
      return {
        "message": "Tem compras",
        "compras": lista1,
        "dadosVendedor": lista3
      };
    } catch (err) {

      return {"message": "ERRO", "compras": []};
    }
  }

  Future<Map> recuperaVendaPorData() async {
    print("recuperaVendaPorData");
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      List lista1 = [];
      List lista2 = [];
      Map lista3 = {};

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('compraReferencia')
          .where('usernameVendedor', isEqualTo: _usuario.username)
          .where("dataCompra", isNotEqualTo: "")
          .orderBy("dataCompra", descending: true)
          .get();


      if (querySnapshot.docs.length == 0)
        return {
          "message": "Não tem compras",
          "compras": lista1,
          "dadosComprador": {}
        };

      querySnapshot.docs.forEach((element) async {
        lista1.add(element.data());
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: element.data()["usernameComprador"])
            .get();

        lista3.addAll({
          element.data()["usernameComprador"]:
              querySnapshot2.docs[0].data()["nome"]
        });

        lista2.add(querySnapshot2.docs[0].data()["nome"]);
      });

      while (lista1.length > lista2.length) {
        await Future.delayed(Duration(seconds: 5), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      return {
        "message": "Tem compras",
        "compras": lista1,
        "dadosComprador": lista3
      };
    } catch (err) {

      return {"message": "ERRO", "compras": [], "dadosComprador": []};
    }
  }

  Future<Map> recuperaComprasConsumidorIdCompra(
      String idCompra, String usernameVendedor) async {
    //Separado por vendedor
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      var lista = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('itemComprado')
          .where('usernameComprador', isEqualTo: _usuario.username)
          .where('usernameVendedor', isEqualTo: usernameVendedor)
          .where("idCompra", isEqualTo: idCompra)
          .get();

      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameVendedor)
          .get();
      double valorTotal = 0.0;
      querySnapshot.docs.forEach((element) {
        if (element.data()["status"].toString().contains("Cancel") == false) {
          valorTotal += (double.parse(
                  element.data()["precoUnitario"].replaceAll(",", ".")) *
              element.data()["quantidade"]);
        }
        lista.add(element.data());
      });

      if (lista.length == 0) {
        return {
          "mensagem": "sucesso",
          "valorTotal": 0,
          "celularVendedor": "",
          "emailVendedor": "",
          "itensComprados": [],
        };
      }

      Map dados = {
        "mensagem": "sucesso",
        "valorTotal": valorTotal,
        "celularVendedor": querySnapshot2.docs[0].data()["telefone"],
        "emailVendedor": querySnapshot2.docs[0].data()["email"],
        "itensComprados": lista,
      };

      return dados;
    } catch (err) {

      return {
        "mensagem": "sucesso",
        "valorTotal": 0,
        "descricao": err.toString(),
        "celularVendedor": "",
        "emailVendedor": "",
        "itensComprados": [],
      };
    }
  }

  Future<Map> recuperaVendaVendedorIdCompra(String idCompra) async {
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      var lista = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('itemComprado')
          .where('usernameVendedor', isEqualTo: _usuario.username)
          .where("idCompra", isEqualTo: idCompra)
          .get();
      double valorTotal = 0.0;
      querySnapshot.docs.forEach((element) {
        //=====Valor total de itens não cancelados
        print("STATUS =====>" + element.data()["status"]);
        if (element.data()["status"].toString().contains("Cancel") == false) {
          valorTotal += (double.parse(
                  element.data()["precoUnitario"].replaceAll(",", ".")) *
              element.data()["quantidade"]);
        }
        //========================================
        lista.add(element.data());
      });
      if (lista.length == 0) {
        return {
          "mensagem": "sucesso",
          "valorTotal": 0,
          "celularVendedor": "",
          "emailVendedor": "",
          "itensComprados": [],
        };
      }

      String usernameComprador =
          querySnapshot.docs[0].data()["usernameComprador"];
      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameComprador)
          .get();

      Map dados = {
        "mensagem": "sucesso",
        "valorTotal": valorTotal,
        "celularComprador": querySnapshot2.docs[0].data()["telefone"],
        "emailComprador": querySnapshot2.docs[0].data()["email"],
        "itensComprados": lista,
      };

      return dados;
    } catch (err) {

      return {
        "mensagem": "sucesso",
        "valorTotal": 0,
        "descricao": err.toString(),
        "celularComprador": "",
        "emailComprador": "",
        "itensComprados": [],
      };
    }
  }

  Future<String> compraCadaItem(
      List lista,
      String tipoPagamento,
      bool apagarCarrinho,
      var now,
      String endereco,
      String nomeComprador,
      String token,
      String idCompra) async {
    CollectionReference compraItem =
        FirebaseFirestore.instance.collection('itemComprado');

    CollectionReference compraReferencia =
        FirebaseFirestore.instance.collection('compraReferencia');

    try {
      String dataAgora =
          "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.${now.hour.toString()}h${now.minute.toString()}m${now.second}s${now.millisecond}";

      int iterador = 0;
      String usernameComprador =
          lista[0]["produtos"][0].usernameComprador.toString();

      lista.forEach((item) async {
        //Registra compra de cada carrinho
        //1 Vendedor = 1 Referencia de compra
        Compra compraReferenciaObj = Compra(
          Timestamp.fromDate(now),
          idCompra,
          "${usernameComprador}",
          "${item["produtos"][0].usernameVendedor}",
          double.parse(item["frete"].toString().replaceAll(",", ".")),
          item["produtos"].length,
          0,
          "-",
          //Previsão entrega
          "Aguardando confirmação do vendedor",
        );

        await compraReferencia.add(compraReferenciaObj.getCompraJson());

        String produtosListaEmail = "";
        String vendedorAtual = "";
        String nomeVendedorAtual = "";

        item["produtos"].forEach((value) async {
          //Lista de produtos comprados de um certo vendedor
          produtosListaEmail += "• ${value.nome}<br>";
          String idItemComprado = "";
          nomeVendedorAtual = value.nomeVendedor;
          vendedorAtual = value.usernameVendedor;

          print("TIPO DO VALUE " + value.runtimeType.toString());
          if (value.runtimeType == ProdutoCarrinho) {
            idItemComprado = "${value.idProduto}__${dataAgora}";

            ItemComprado itemComprado = ItemComprado(
              Timestamp.fromDate(now),
              endereco,
              idCompra,
              idItemComprado,
              value.idProduto,
              value.imagePath,
              value.nome,
              nomeComprador,
              value.nomeVendedor,
              tipoPagamento,
              value.precoUnitario,
              "Aguardando confirmação do vendedor",
              //status
              value.quantidade,
              value.qtdPacote.runtimeType != int
                  ? int.parse(value.qtdPacote)
                  : value.qtdPacote,
              token,
              value.unidadeMedida,
              value.usernameComprador,
              value.usernameVendedor,
            );
            await compraItem.add(itemComprado.getItemJson());
            await ControllerProduto().atualizaQtdProduto(
                value.idProduto, value.quantidade, "produto", "id_produto");
            if (apagarCarrinho != true) {
              //Se ainda falta realizar o pagamento online, apaga um por um
              await ControllerProduto().atualizaCarro(
                  "apagar",
                  ProdutoCarrinho(value.idProduto, "", "", "", "", "", 0, "",
                      "", value.usernameComprador, ""));
            }
          } else {
            //value.runtimeType == CestaCarrinho
            idItemComprado = "${value.idCesta}__${dataAgora}";


            CestaComprado cestaComprado = CestaComprado(
              Timestamp.fromDate(now),
              endereco,
              idCompra,
              idItemComprado,
              value.idCesta,
              value.imagePath,
              value.nome,
              nomeComprador,
              value.nomeVendedor,
              tipoPagamento,
              value.precoUnitario,
              "Aguardando confirmação do vendedor",
              //status
              value.quantidade,
              value.produtos,
              token,
              value.usernameComprador,
              value.usernameVendedor,
            );
            await compraItem.add(cestaComprado.getItemJson());

            await ControllerProduto().atualizaQtdProduto(
                value.idCesta, value.quantidade, "cesta", "idCesta");

            if (apagarCarrinho != true) {
              //Se ainda falta realizar o pagamento online, apaga um por um
              await ControllerProduto().atualizaCarro(
                  "apagar",
                  CestaCarrinho(value.idCesta, "", "", "", "", "", "", 0, {},
                      value.usernameComprador, ""));
            }
          }
        });
        //Envia email ao vendedor

        Email.sendRegistrationNotification(
            'Você recebeu um pedido - Verde Vegetal',
            'Olá, ${nomeVendedorAtual}!<br><br>Por favor, acesse o aplicativo <strong>Verde Vegetal</strong> para confirmar ou cancelar a venda realizada.<br>Alguém acabou de comprar os seguintes itens:<br>${produtosListaEmail}',
            vendedorAtual);
        iterador++;
      });

      while (iterador < lista.length) {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      return "terminei";
    } catch (err) {
      print(err);
      return "erro";
    }
  }

//================PAGAMENTO ONLINE========================
/*
* O método abaixo foi apenas um teste utilizando uma API de pagamentos
* */
  // Future<String> cadastraCompraOnline(
  //     List produtosOnline,
  //     String endereco,
  //     double valorTotal,
  //     DateTime now,
  //     Map pagamento,
  //     var usuario,
  //     String idCompra) async {
  //   // try {
  //
  //   String dataAgora =
  //       "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.${now.hour.toString()}h${now.minute.toString()}";
  //
  //   int iterador = 0;
  //
  //   String _url =
  //       'https://api.intermediador.sandbox.yapay.com.br/api/v3/transactions/payment';
  //
  //   List affiliates = [];
  //   List produtos = [];
  //   //Calcular valor total
  //
  //   produtosOnline.forEach((element) {
  //     String porcentagem =
  //         (double.parse(element["valorTotal"].toString().replaceAll(",", ".")) /
  //                 valorTotal *
  //                 100)
  //             .toString();
  //     affiliates.add({
  //       "account_email": "emaildoafiliado@afiliado.com",
  //       //element["dadosVendedor"].emailYapay+".br",
  //       "percentage": porcentagem,
  //     });
  //
  //     element["produtos"].forEach((item) {
  //       produtos.add({
  //         "description": item.nome,
  //         "quantity": item.quantidade,
  //         "price_unit": item.precoUnitario.replaceAll(",", "."),
  //         "code": "1",
  //         "sku_code": "0001",
  //         "extra": "Nome vendedor: ${item.nomeVendedor}"
  //       });
  //     });
  //   });
  //
  //   Map enderecoMap = {
  //     "type_address": "B",
  //     "postal_code": usuario.cep,
  //     "street": usuario.logradouro,
  //     "number": usuario.num,
  //     "completion": usuario.complemento,
  //     "neighborhood": usuario.bairro,
  //     "city": usuario.cidade,
  //     "state": usuario.estado
  //   };
  //
  //   Map body = {
  //     "token_account": token.token_dev.toString(),
  //     // "finger_print":"{{finger_print}}",
  //     "affiliates": affiliates,
  //     "payment": pagamento,
  //     "customer": {
  //       "contacts": [
  //         {"type_contact": "H", "number_contact": usuario.telefone}
  //       ],
  //       "addresses": [enderecoMap],
  //       "name": usuario.nome,
  //
  //       "cpf": "XXXXX", //usuario.cpf,
  //       "email": "teste@gmail.com",
  //     },
  //     "transaction_product": produtos,
  //     "transaction": {
  //       "available_payment_methods": "2,3,4,5,6,7,14,15,16,18,19,21,22,23",
  //       "customer_ip": "127.0.0.1",
  //       "shipping_type": "Entrega",
  //       "shipping_price": "0",
  //       "price_discount": "",
  //       "url_notification": "http://www.loja.com.br/notificacao",
  //       // "free": ""
  //     }
  //   };
  //
  //   Response response = await post(_url,
  //       body: jsonEncode(body), headers: {"Content-Type": "application/json"});
  //
  //   Map retorno = json.decode(response.body);
  //
  //   String tokenTransaction = "";
  //   if (retorno["message_response"]["message"] == "success") {
  //     tokenTransaction =
  //         retorno["data_response"]["transaction"]["token_transaction"];
  //
  //     //===================================================
  //
  //     //Online
  //     // if (produtosOnline.length > 0) {
  //     String comprasOnline = "none";
  //
  //     //Salva no firebase os dados
  //     comprasOnline = await this.compraCadaItem(
  //         produtosOnline,
  //         "Pagamento online - Yapay",
  //         true,
  //         now,
  //         endereco.toString(),
  //         usuario.nome,
  //         tokenTransaction,
  //         idCompra);
  //
  //     while (comprasOnline == "none") {
  //       await Future.delayed(Duration(seconds: 2), () {
  //         //Faz função esperar um pouco para terminar de receber dados do forEach
  //         return 'Dados recebidos...';
  //       });
  //     }
  //
  //     //=================================================
  //
  //     //------------------------------------------
  //     if (comprasOnline == "terminei") {
  //       await ControllerProduto().apagaCarrinho(usuario.username);
  //     } else {
  //       return "FALHOU";
  //     }
  //
  //     return "Finalizei";
  //   }
  //   // } catch (err) {
  //   //
  //   //   return "Deu erro";
  //   // }
  // }
//=========================================================

  Future<String> cadastraCompraEntrega(
      List produtosDinheiro,
      List produtosCredito,
      String endereco,
      DateTime now,
      bool apagarCarrinho,
      String nomeComprador,
      String idCompra) async {

    print("COMPRA 3");

    String dataAgora =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.${now.hour.toString()}h${now.minute.toString()}m${now.second}s${now.millisecond}";;

    String username;

    //===================DINHEIRO=====================
    if (produtosDinheiro.length > 0) {
      username = produtosDinheiro[0]["produtos"][0].usernameComprador;
      String compraPorDinheiro = "none";
      compraPorDinheiro = await this.compraCadaItem(
          produtosDinheiro,
          "Entrega - Dinheiro",
          apagarCarrinho,
          now,
          endereco,
          nomeComprador,
          "",
          idCompra);

      while (compraPorDinheiro == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
      print("acabou");
    }
    //================================================

    //=================Cartão de credito==============
    if (produtosCredito.length > 0) {
      username = produtosCredito[0]["produtos"][0].usernameComprador;
      String compraPorCredito = "none";
      compraPorCredito = await this.compraCadaItem(
          produtosCredito,
          "Entrega - Cartão de crédito",
          apagarCarrinho,
          now,
          endereco,
          nomeComprador,
          "",
          idCompra);

      while (compraPorCredito == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
    }
    //=================================================

    if (apagarCarrinho == true) {
      await ControllerProduto().apagaCarrinho(username);
    }

    return "Finalizei";
  }

  Future<List> recuperaVendasVendedor(String username) async {
    print("recuperaVendasVendedor");
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

    try {
      List<ItemComprado> lista = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('itemComprado')
          .where('usernameVendedor', isEqualTo: username)
          .where("data", isNotEqualTo: "")
          .orderBy("data", descending: true)
          .get();

      querySnapshot.docs.forEach((element) {
        print(element.data().toString());
        ItemComprado item = ItemComprado(
          element.data()["data"],
          element.data()["enderecoComprador"],
          element.data()["idCompra"],
          element.data()["idItemComprado"],
          element.data()["idProduto"],
          element.data()["imagePath"],
          element.data()["nome"],
          element.data()["nomeComprador"],
          element.data()["nomeVendedor"],
          element.data()["metodoPagamento"],
          element.data()["precoUnitario"],
          element.data()["status"],
          element.data()["quantidade"],
          element.data()["qtdPacote"],
          element.data()["tokenPagamentoYapay"],
          element.data()["unidadeMedida"],
          element.data()["usernameComprador"],
          element.data()["usernameVendedor"],
        );
        lista.add(item);
      });

      if (lista.length == 0)
        return [
          {"erro": "Não há vendas"}
        ];

      return lista;
    } catch (err) {
      print(err);
      return [
        {"erro": "Não foi possivel recuperar as vendas"}
      ];
    }
  }

  Future<List> resumoPreCompras() async {
    List carrinho = null;
    carrinho = await ControllerProduto().recuperaCarrinho();

    while (carrinho == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    Map itensParaCompra = {"message": "", "itens": []};
    ControllerUsuario ctrUsuario = ControllerUsuario();


    int iterador = 0;
    var carrinhoAgrupadoVendedor = [];
    var keys = {};

    //loop para agrupar por vendedor
    carrinho.forEach((element) async {
      if (keys.containsKey(element.usernameVendedor) == false) {
        //Primeira recorrencia

        carrinhoAgrupadoVendedor.add({
          "metodosPagamentoPossiveis": (DadosVendedor),
          "produtos": [],
          "frete": "0,00",
          "valorTotal":
              double.parse(element.precoTotal.toString().replaceAll(",", "."))
        });
        carrinhoAgrupadoVendedor[carrinhoAgrupadoVendedor.length - 1]
                ["produtos"]
            .add(element);

        keys[element.usernameVendedor] = iterador;
      } else {

        carrinhoAgrupadoVendedor[keys[element.usernameVendedor]]
                ["valorTotal"] +=
            double.parse(element.precoTotal.toString().replaceAll(",", "."));
        carrinhoAgrupadoVendedor[keys[element.usernameVendedor]]["produtos"]
            .add(element);
      }

      iterador++;
    });

    int iterador2 = 0;
    for (int i = 0; i < carrinhoAgrupadoVendedor.length; i++) {
      Map dadosVendedor = null;
      dadosVendedor = await ctrUsuario.recuperaDadosVendedorPorUsername(
          carrinhoAgrupadoVendedor[i]["produtos"][0].usernameVendedor);

      Map freteVendedor = {};
      freteVendedor = await ControllerUsuario.recuperaFreteVendedorPorUsername(
          carrinhoAgrupadoVendedor[i]["produtos"][0].usernameVendedor);
      while (freteVendedor == {} && dadosVendedor == null) {
        await Future.delayed(Duration(seconds: 1), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }

      var usuario = await ControllerAutenticao().recuperaLoginSalvo();
      String valorFrete = "0,00";
      String key = "${usuario.cidade} - ${usuario.estado}";

      if (freteVendedor["data"].localidades.containsKey(key) == true) {
        print(freteVendedor["data"].localidades[key].keys);

        if (freteVendedor["data"].localidades[key].containsKey("Padrão") ==
            true) {
          valorFrete = freteVendedor["data"].localidades[key]["Padrão"];
        }
        if (freteVendedor["data"]
                .localidades[key]
                .containsKey("${usuario.bairro}") ==
            true) {
          valorFrete =
              freteVendedor["data"].localidades[key]["${usuario.bairro}"];
        }
      }

      carrinhoAgrupadoVendedor[i]["metodosPagamentoPossiveis"] =
          dadosVendedor["data"];
      carrinhoAgrupadoVendedor[i]["frete"] = valorFrete;

      iterador2++;
    }
    int tamanho = carrinhoAgrupadoVendedor.length;

    while (iterador2 < tamanho) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    itensParaCompra["message"] = "Sucesso";
    return carrinhoAgrupadoVendedor;

  }
}

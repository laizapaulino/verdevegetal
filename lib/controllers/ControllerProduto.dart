import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/FirebaseDB.dart';
import 'package:verde_vegetal_app/model/Cesta.dart';
import 'package:verde_vegetal_app/model/CestaCarrinho.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';

import 'ControllerCommon.dart';
import 'ControllerUsuario.dart';

class ControllerProduto {
  //Cadastrar view.produto
  Future<String> cadastraProduto(Produto produto, File _image) async {
    try {
      ControllerCommon _ctrCommon = ControllerCommon();
      String url = "none";
      url = await _ctrCommon.uploadFile(
          _image, produto.id_produto + "_1", "produtos");

      while (url == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }

      produto.imagePath = url;

      await FirebaseDB.save("produto", produto.getProdutoJson());

      return "true";
    } catch (err) {
      print(err);
      return "false";
    }
  }

  Future<String> cadastraCesta(
      Cesta cesta, Map produtosCesta, File image) async {
    try {
      ControllerCommon _ctrCommon = ControllerCommon();
      //cadastra cada imagem do produto
      if (image != null) {
        String url = "none";
        url = await _ctrCommon.uploadFile(
            image,
            "${cesta.nome}_${cesta.usernameVendedor}_${DateTime.now()}",
            "produtosCesta");
        while (url == "none") {
          await Future.delayed(Duration(seconds: 2), () {
            //Faz função esperar um pouco para terminar de receber dados
            return 'Dados recebidos...';
          });
        }
        print(url);
        cesta.imagePath = url;
      }

      cesta.produtos = produtosCesta;
      await FirebaseDB.save("cesta", cesta.getCestaJson());

      return "true";
    } catch (err) {
      print(err);
      return "false";
    }
  }

  Future<bool> atualizaQtdProduto(String idProduto, int quantidadeComprada,
      String collection, String parametro) async {
    print("função atualizaQtdProduto");
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery(collection, parametro, idProduto);

      var id = querySnapshot.docs.first.id;

      print("vou atualizar para: ");
      print(
          querySnapshot.docs.first.data()["qtdEstoque"] - (quantidadeComprada));

      Map dadoAtualizaJson = {
        "qtdEstoque":
            querySnapshot.docs.first.data()["qtdEstoque"] - (quantidadeComprada)
      };

      await FirebaseDB.update(collection, id, dadoAtualizaJson);

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<dynamic> atualizaDadosItem(Map<String, dynamic> dados,
      String collection, String parametro, String idItem) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery(collection, parametro, idItem);

      // print("atualizer");
      if (querySnapshot.docs.length == 1) {
        await FirebaseDB.update(collection, querySnapshot.docs[0].id, dados);

        var itemAtualizado;
        if (collection == "produto")
          itemAtualizado = await recuperaProdutoPorId(idItem);
        else
          itemAtualizado = await recuperaCestaPorId(idItem);
        return itemAtualizado;
      }

      return {"erro": "nada"};
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return {"erro": "nada"};
    }
  }

  Future<List> recuperaProdutoHome(int fim) async {
    try {
      List lista = [];

      QuerySnapshot querySnapshot =
          await FirebaseDB.findQueryLimit("produto", "status", "ativo", fim);

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });

      QuerySnapshot querySnapshot2 =
          await FirebaseDB.findQueryLimit("cesta", "status", "ativo", fim);

      querySnapshot2.docs.forEach((element) {
        lista.add(element.data());
      });

      if (lista.length == 0) return [];

      lista.sort((a, b) => b["dataCadastro"].compareTo(a["dataCadastro"]));

      return lista;
    } catch (err) {
      print(err);
      return new List();
    }
  }

  Future<Map> valorFrete(String usernameVendedor) async {
    Map freteVendedor = {};
    freteVendedor = await ControllerUsuario.recuperaFreteVendedorPorUsername(
        usernameVendedor);

    while (freteVendedor == {}) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados
        return 'Dados recebidos...';
      });
    }

    if (freteVendedor["message"] == "sucesso") {
      var usuario = null;
      ControllerAutenticao ctrAutenticacao = ControllerAutenticao();

      bool entregaNaLocalidade = false;
      String valorFrete = "0,00";

      usuario = await ctrAutenticacao.recuperaLoginSalvo();

      if (usuario.runtimeType == Usuario) {
        String key = "${usuario.cidade} - ${usuario.estado}";
        print(freteVendedor["data"].localidades.keys);

        if (freteVendedor["data"].localidades.containsKey(key) == true) {
          if (freteVendedor["data"].localidades[key].containsKey("Padrão") ==
              true) {
            valorFrete = freteVendedor["data"].localidades[key]["Padrão"];
            entregaNaLocalidade = true;
          }
          if (freteVendedor["data"]
                  .localidades[key]
                  .containsKey("${usuario.bairro}") ==
              true) {
            valorFrete =
                freteVendedor["data"].localidades[key]["${usuario.bairro}"];
            entregaNaLocalidade = true;
          }
        }
      }

      Map retorno = {
        "message": "sucesso",
        "entregaNaLocalidade": entregaNaLocalidade,
        "valorFrete": valorFrete,
      };

      return retorno;
    }

    return {
      "message": "sucesso",
      "entregaNaLocalidade": false,
      "valorFrete": "0,00",
    };
  }

  Future<Map> recuperaProdutoPorId(String id) async {
    print("recuperaProdutoPorId");
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("produto", "id_produto", id);

      if (querySnapshot.docs.length == 0) {
        return {"erro": "nada"};
      }

      Map reto = {};
      reto = await valorFrete(querySnapshot.docs[0].data()["usernameVendedor"]);

      while (reto == {}) {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }
      Produto produto = Produto(
          querySnapshot.docs[0].data()["categoria"],
          querySnapshot.docs[0].data()["descricao"],
          querySnapshot.docs[0].data()["id_produto"],
          querySnapshot.docs[0].data()["imagePath"],
          querySnapshot.docs[0].data()["nome"],
          querySnapshot.docs[0].data()["nomeVendedor"],
          querySnapshot.docs[0].data()["preco"],
          querySnapshot.docs[0].data()["qtdEstoque"],
          querySnapshot.docs[0].data()["qtdPacote"],
          querySnapshot.docs[0].data()["status"],
          querySnapshot.docs[0].data()["unidadeMedida"],
          querySnapshot.docs[0].data()["usernameVendedor"]);

      reto["produto"] = produto;

      return {
        "message": "sucesso",
        "produto": produto,
        "entregaNaLocalidade": false,
        "valorFrete": "0,00",
      };
    } catch (err) {
      print("erro aqui");
      print(err);
      return {"erro": "nada"};
    }
  }

  Future<Map> recuperaCestaPorId(String id) async {
    print("recuperaCestaPorId");
    try {
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("cesta", "idCesta", id);

      if (querySnapshot.docs.length == 0) {
        return {"erro": "nada"};
      }

      Map reto = {};
      reto = await valorFrete(querySnapshot.docs[0].data()["usernameVendedor"]);

      while (reto == {}) {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }

      Cesta cesta = Cesta(
          querySnapshot.docs[0].data()["categoria"],
          querySnapshot.docs[0].data()["descricao"],
          querySnapshot.docs[0].data()["imagePath"],
          querySnapshot.docs[0].data()["idCesta"],
          querySnapshot.docs[0].data()["nome"],
          querySnapshot.docs[0].data()["nomeVendedor"],
          querySnapshot.docs[0].data()["preco"],
          querySnapshot.docs[0].data()["qtdEstoque"],
          querySnapshot.docs[0].data()["status"],
          querySnapshot.docs[0].data()["produtos"],
          querySnapshot.docs[0].data()["usernameVendedor"]);

      reto["cesta"] = cesta;
      return reto;
    } catch (err) {
      print("erro aqui");
      print(err);
      return {
        "message": "erro",
        "description": err.toString(),
        "produto": {},
        "entregaNaLocalidade": false,
        "valorFrete": "0,00",
      };
    }
  }

  Future<dynamic> recuperaProdutosPorNome(String nome) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseDB.findQueryFiltroContains(
          "produto", "status", "ativo", "filtro", [nome, nome.toLowerCase()]);

      var lista = [];

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });

      QuerySnapshot querySnapshot2 = await FirebaseDB.findQueryFiltroContains(
          "cesta", "status", "ativo", "filtro", [nome, nome.toLowerCase()]);

      querySnapshot2.docs.forEach((element) {
        lista.add(element.data());
      });

      return lista;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Future<List> recuperaItemVendedorLogado(String collection) async {
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      var lista = [];

      QuerySnapshot querySnapshot = await FirebaseDB.findQueryLimit(
          collection, "usernameVendedor", _usuario.username, 3);

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });

      if (lista.length == 0) return [];

      return lista;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Future<List> recuperaTodosItensVendedorPorUsername(
      String origem, String username, int fim) async {
    print("recuperaTodosItensVendedorPorUsername");

    try {
      var lista = [];

      QuerySnapshot querySnapshot;
      if (origem == "minha loja") {
        querySnapshot = await FirebaseDB.findQueryLimit(
            "produto", "usernameVendedor", username, fim);
      } else {
        querySnapshot = await FirebaseDB.findQueryLimit2Where(
            "produto", "usernameVendedor", username, "status", "ativo", fim);
      }

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });
      QuerySnapshot querySnapshot2;

      if (origem == "minha loja") {
        querySnapshot2 = await FirebaseDB.findQueryLimit(
            "cesta", "usernameVendedor", username, fim);
      } else {
        querySnapshot2 = await FirebaseDB.findQueryLimit2Where(
            "cesta", "usernameVendedor", username, "status", "ativo", fim);
      }
      querySnapshot2.docs.forEach((element) {
        lista.add(element.data());
      });
      lista.addAll(lista);
      lista.sort((a, b) => b["dataCadastro"].compareTo(a["dataCadastro"]));

      if (lista.length == 0) return [];

      return lista;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Future<Map<String, String>> verificaDisponibilidade(
      String idProduto, int qtdPedido, String tipo) async {
    try {
      print("verifica disponibilidade");
      QuerySnapshot querySnapshot;
      if (tipo == "Cesta") {
        querySnapshot = await FirebaseDB.findQuery2Where(
            "cesta", "idCesta", idProduto, "status", "ativo");
      } else {
        querySnapshot = await FirebaseDB.findQuery2Where(
            "produto", "id_produto", idProduto, "status", "ativo");
      }

      print(querySnapshot.docs.length);
      if (querySnapshot.docs.length == 0)
        return {"mensagem": "Indisponivel"};
      else {
        if (querySnapshot.docs[0].data()["qtdEstoque"] >= qtdPedido)
          return {"mensagem": "Disponivel"};
        else
          return {"mensagem": "Indisponivel"};
      }
    } catch (err) {
      return {"mensagem": "Erro"};
    }
  }

  Future<Map> recuperaCompraPorData() async {
    print("recuperaCompraPorData");
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      List lista = [];

      QuerySnapshot querySnapshot = await FirebaseDB.findQuery2WhereOrderBy(
          "compraReferencia",
          "usernameComprador",
          _usuario.username,
          "dataCompra",
          "",
          "dataCompra",
          true);

      print(querySnapshot.docs[0].data());

      if (querySnapshot.docs.length == 0)
        return {"message": "Não tem compras", "compras": lista};

      querySnapshot.docs.forEach((element) {
        lista.add(element.data());
      });

      return {"message": "Tem compras", "compras": lista};
    } catch (err) {
      return {"message": "ERRO", "compras": []};
    }
  }

  Future<bool> insereCarrinho(ProdutoCarrinho prod, String username) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot = await FirebaseDB.findQuery2Where(
          "carrinho",
          "usernameComprador",
          prod.usernameComprador,
          "idProduto",
          prod.idProduto);

      //Se não achar insere
      if (querySnapshot.docs.length == 0) {
        CollectionReference carrinho =
            await FirebaseDB.save("carrinho", prod.getProdutoCarrinhoJson());
      }

      //Se achar atualiza com quantidade nova se a quantidade nova for menor ou igual que a quantidade disponivel
      else {
        var carrinho = await FirebaseDB.update("carrinho",
            querySnapshot.docs[0].id, prod.getProdutoCarrinhoJson());
      }

      return true;
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return false;
    }
  }

  Future<bool> insereCestaCarrinho(CestaCarrinho prod, String username) async {
    try {
      //Procura no banco
      QuerySnapshot querySnapshot = await FirebaseDB.findQuery2Where("carrinho",
          "usernameComprador", prod.usernameComprador, "idCesta", prod.idCesta);

      //Se não achar insere

      if (querySnapshot.docs.length == 0) {
        CollectionReference carrinho =
            await FirebaseDB.save("carrinho", prod.getCestaCarrinhoJson());
      }

      //Se achar atualiza com quantidade nova se a quantidade nova for menor ou igual que a quantidade disponivel
      else {
        await FirebaseDB.update(
            "carrinho", querySnapshot.docs[0].id, prod.getCestaCarrinhoJson());
      }

      return true;
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return false;
    }
  }

  Future<Map> atualizaCarro(String operacao, var prod) async {
    try {
      NumberFormat formatter = NumberFormat("0.00");

      print("Função atualizaCarro");
      String nomeColecao;
      String id = "";
      String parametro = "";

      QuerySnapshot querySnapshot;
      if (prod.runtimeType == CestaCarrinho) {
        nomeColecao = "cesta";
        parametro = "idCesta";
        id = prod.idCesta;

        querySnapshot = await FirebaseDB.findQuery2Where("carrinho",
            "usernameComprador", prod.usernameComprador, "idCesta", id);
      } else {
        nomeColecao = "produto";
        parametro = "id_produto";
        id = prod.idProduto;
        querySnapshot = await FirebaseDB.findQuery2Where("carrinho",
            "usernameComprador", prod.usernameComprador, "idProduto", id);
      }
      //Procura no banco
      if (querySnapshot.docs.length > 0) {
        String idDocumento = querySnapshot.docs[0].id;

        var carrinho = FirebaseFirestore.instance
            .collection('carrinho')
            .doc(querySnapshot.docs[0].id);

        //Remove carrinho
        if (operacao == "apagar") {
          await FirebaseDB.delete("carrinho", idDocumento);
          return {"mensagem": "Sucesso"};
        } else if (operacao == "diminuir" || operacao == "aumentar") {
          QuerySnapshot querySnapshot2 =
              await FirebaseDB.findQuery(nomeColecao, parametro, id);

          int quantidadeNova =
              prod.quantidade + (operacao == "aumentar" ? 1 : -1);
          double precoNovoDouble = (quantidadeNova) *
              double.parse(
                  querySnapshot2.docs[0].data()["preco"].replaceAll(",", "."));

          String precoNovo = formatter.format(precoNovoDouble);

          if (querySnapshot2.docs[0].data()["qtdEstoque"] >= quantidadeNova) {
            //Tem estoque
            await FirebaseDB.update("carrinho", idDocumento, {
              "quantidade": quantidadeNova,
              "precoTotal": precoNovo.replaceAll(".", ",")
            });
            return {"mensagem": "Sucesso", "quantidade": quantidadeNova};
          } else if (querySnapshot2.docs[0].data()["qtdEstoque"] == 0) {
            //Não tem
            await FirebaseDB.delete("carrinho", idDocumento);
            return {
              "mensagem":
                  "Sentimos muito, o ${prod.nome} esgotou e será removido do carrinho",
              "quantidade": "0"
            };
          } else if (querySnapshot2.docs[0].data()["qtdEstoque"] > 0 &&
              querySnapshot2.docs[0].data()["qtdEstoque"] < quantidadeNova) {
            //Tem menos que o desejado
            precoNovoDouble = querySnapshot2.docs[0].data()["qtdEstoque"] *
                double.parse(querySnapshot2.docs[0]
                    .data()["preco"]
                    .replaceAll(",", "."));
            String precoNovo = formatter.format(precoNovoDouble);

            await FirebaseDB.update("carrinho", idDocumento, {
              "quantidade": querySnapshot2.docs[0].data()["qtdEstoque"],
              "precoTotal": precoNovo.toString().replaceAll(".", ",")
            });

            return {
              "mensagem":
                  "A quantidade solicitada não está disponivel, por isso foi atualizada para a maior quantia disponivel no estoque.",
              "quantidade": querySnapshot2.docs[0].data()["qtdEstoque"]
            };
          } else {
            return {
              "mensagem": "Não foi possivel ${operacao} a quantidade",
              "quantidade": prod.quantidade
            };
          }
        }
      }
      return {"erro": "Não foi possivel atualizar a quantidade"};
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return {"erro": err};
    }
  }

  Future<List> recuperaCarrinho() async {
    //Carrinho carrinhoCompras
    try {
      ControllerAutenticao ctrAutenticao = ControllerAutenticao();
      var usuario = await ctrAutenticao.recuperaLoginSalvo();
      if (usuario.runtimeType == Usuario) {
        List lista = [];
        QuerySnapshot querySnapshot = await FirebaseDB.findQuery(
            "carrinho", "usernameComprador", usuario.username);

        querySnapshot.docs.forEach((element) {
          if (element.data().containsKey("idCesta")) {
            CestaCarrinho cestaCarrinho = CestaCarrinho(
                element.data()["idCesta"],
                element.data()["imagePath"],
                element.data()["nome"],
                element.data()["nomComprador"],
                element.data()["nomeVendedor"],
                element.data()["precoTotal"],
                element.data()["precoUnitario"],
                element.data()["quantidade"],
                element.data()["produtos"],
                element.data()["usernameComprador"],
                element.data()["usernameVendedor"]);
            lista.add(cestaCarrinho);
          } else {
            ProdutoCarrinho prCarrinho = ProdutoCarrinho(
                element.data()["idProduto"],
                element.data()["imagePath"],
                element.data()["nome"],
                element.data()["nomeVendedor"],
                element.data()["precoTotal"],
                element.data()["precoUnitario"],
                element.data()["quantidade"],
                element.data()["qtdPacote"],
                element.data()["unidadeMedida"],
                element.data()["usernameComprador"],
                element.data()["usernameVendedor"]);
            lista.add(prCarrinho);
          }
        });
        return lista;
      } else {
        return [
          {"erro": "Faça login"}
        ];
      }
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return [
        {"erro": "Não foi possivel recuperar os itens do carrinho."}
      ];
    }
  }

  Future<dynamic> apagaCarrinho(String username) async {
    try {
      ControllerAutenticao ctrAutenticao = ControllerAutenticao();
      List lista = [];
      QuerySnapshot querySnapshot =
          await FirebaseDB.findQuery("carrinho", "usernameComprador", username);

      querySnapshot.docs.forEach((element) async {
        await FirebaseDB.delete("carrinho", element.id);
      });

      return {"mensagem": "Carrinho excluido"};
    } catch (err) {
      print("vou te contar um erro");
      print(err);
      return [
        {"erro": "Não foi possivel recuperar os itens do carrinho."}
      ];
    }
  }
}

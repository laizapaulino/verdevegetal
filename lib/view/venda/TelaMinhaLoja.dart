import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/produto/TelaCadastroProduto.dart';
import 'package:verde_vegetal_app/view/produto/TelaCadastroProdutoCesta.dart';

import 'TelaMinhasVendas2.dart';

class TelaMinhaLoja extends StatefulWidget {
  @override
  _TelaMinhaLojaState createState() => _TelaMinhaLojaState();
}

class _TelaMinhaLojaState extends State<TelaMinhaLoja> {
  ElementosInterface elementosInterface = new ElementosInterface();
  ControllerProduto _ctrProduto = ControllerProduto();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();

  ScrollController _controller = new ScrollController();

  Future<List> _produtos;
  Future<dynamic> _usuario;
  String username = "";

  _apertoOpcao(String nomeOpcao, var user) async {
    if ((nomeOpcao == "Cadastrar produto" || nomeOpcao == "Cadastrar cesta") &&
        user["freteVendedor"]["data"].runtimeType == FreteVendedor) {
      String retorno = "none";

      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => nomeOpcao == "Cadastrar produto"
                  ? TelaCadastroProduto(user["usuario"])
                  : TelaCadastroCesta(user["usuario"])));
    } else if (nomeOpcao == "Cadastrar produto" ||
        nomeOpcao == "Cadastrar cesta") {
      ElementosInterface.caixaDialogo(
          "Antes de cadastrar produtos, você precisa informar as localidades que o seu frete atende.\n\nPara isso acesse ${"Meu perfil"}",
          context);
    } else {
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TelaMinhasVendas2()));
    }
  }


  Future<bool> _onBackPressed() async {
    return await Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  Future<List> recuperaProdutos() async {
    var usuario = null;
    ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
    usuario = await ctrAutenticacao.recuperaLoginSalvo();

    while (usuario == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }

    return await _ctrProduto.recuperaTodosItensVendedorPorUsername("minha loja",
        usuario.username, 50);
  }

  void initState() {
    _usuario = _ctrUsuario.recuperarDadosVisualizacaoPerfil();

    _produtos = recuperaProdutos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return new Future(() {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

            return true;
          });
        },
        child: Scaffold(
            appBar: ElementosInterface.barra(context),
            body: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _usuario = _ctrUsuario.recuperarDadosVisualizacaoPerfil();
                    _produtos = recuperaProdutos();
                  });
                },
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(

                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Minha loja",
                                  //textAlign: TextAlign.center,
                                  style: ControllerCommon.estiloTexto(
                                      "titulo", Colors.black)),
                              Padding(padding: EdgeInsets.only(top: 20)),
                              FutureBuilder(
                                  future: _usuario,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      username =
                                          snapshot.data["usuario"].username;
                                      if (snapshot.data != null) {
                                        var _opcoes = [
                                          {
                                            "nome": "Cadastrar produto",
                                          },
                                          {
                                            "nome": "Cadastrar cesta",
                                          },
                                          {
                                            "nome": "Visualizar vendas",
                                          },
                                        ];
                                        return ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: _opcoes.length,
                                            itemBuilder: (context, indice) {
                                              // print("item ${_opcoes[indice].toString()}");

                                              return InkWell(
                                                  highlightColor: Colors.cyan,
                                                  hoverColor: Colors.cyan,
                                                  child: Container(
                                                      child: Card(
                                                          child: ListTile(
                                                    onTap: () async {
                                                      await _apertoOpcao(
                                                          _opcoes[indice]
                                                              ["nome"],
                                                          snapshot.data);
                                                    },
                                                    title: Text(
                                                      "${_opcoes[indice]["nome"]}",
                                                      style: ControllerCommon
                                                          .estiloTexto("normal",
                                                              Colors.black),
                                                    ),
                                                  ))));
                                            });
                                      } else {
                                        return Text("Você não tem produtos");
                                      }
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
//================================================================================
                              Text("Seus itens a venda",
                                  //textAlign: TextAlign.center,
                                  style: ControllerCommon.estiloTexto(
                                      "titulo 2 negrito", Colors.black)),
                              Padding(padding: EdgeInsets.only(top: 20)),

                              FutureBuilder(
                                  future: _produtos,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data.length == 0) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Text(
                                            "Você ainda não possui itens cadastrados",
                                            style: ControllerCommon.estiloTexto(
                                                "normal", Colors.blueGrey),
                                          ),
                                        );
                                      }
                                      //List tile com produtos
                                      return  ElementosInterface.criaListTile(context, snapshot.data);

                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }),

//================================================================================
                            ])

                    )
                    )),
            drawer: FutureBuilder(
                future: _usuario,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data["usuario"].runtimeType == Usuario)
                      return new NavDrawer(snapshot.data["usuario"]);
                    else {
                      return new NavDrawer(null);
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                })));
  }
}

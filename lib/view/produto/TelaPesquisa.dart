import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/funcoesComumWidget.dart';

import 'TelaExibeProduto.dart';

class TelaPesquisa extends StatefulWidget {
  @override
  _TelaPesquisaState createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  TextEditingController _textcontrol = TextEditingController();
  ElementosInterface _elementosInterface = ElementosInterface();
  ControllerProduto _ctrProduto = ControllerProduto();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

  var _n = [];
  ScrollController _controller = new ScrollController();
  var produtosBuscados = [];

  _verProduto(Produto produto) async {
    var usu = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      Usuario user = usu;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, user)));
    } catch (err) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, {})));
    }
  }
bool clicouBuscar;
  _realizaBusca() async {
    setState(() {
      clicouBuscar = true;
    });
    var retornoProdutos = null;
    retornoProdutos =
        await _ctrProduto.recuperaProdutosPorNome(_textcontrol.text.toString());
    while (retornoProdutos == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados
        return 'Dados recebidos...';
      });
    }

    setState(() {
      produtosBuscados = retornoProdutos;
    });
  }

  @override
  void initState() {
    clicouBuscar =false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Verde Vegetal",
            style: TextStyle(fontFamily: "HachiMaruPop"),
          ),
          backgroundColor: Color.fromRGBO(34, 192, 149, 1),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            //padding: EdgeInsets.all(32),

            child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    if (_textcontrol.text.isNotEmpty) {
                      _realizaBusca();
                    }
                  });
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Campo de busca
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Flexible(
                    child:
                    Container(
                            width: 250,
                            child: TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              enabled: true,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.cyan),
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Busque por um produto',
                              ),

                              controller: _textcontrol,
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                          ),
                          ElevatedButton(
                              onPressed: _realizaBusca, child: Text("Buscar"))
                        ],
                      ),
                      produtosBuscados.length == 0 && clicouBuscar == true?
                      InkWell(
                          highlightColor: Colors.cyan,
                          hoverColor: Colors.cyan,
                          onTap: null, // child: Card(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              "Não achamos nenhum produto :(",
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                            ),
                          )):Text(""),

                      Expanded(
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _controller,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: produtosBuscados.length,
                              itemBuilder: (context, indice) {
                                if (produtosBuscados[indice]
                                ["categoria"] ==
                                    "Cesta") {
                                  return InkWell(
                                      highlightColor: Colors.cyan,
                                      hoverColor: Colors.cyan,
                                      onTap: () {
                                        funcoesComumWidget.verCesta(
                                            produtosBuscados[indice],
                                            context);
                                      }, // child: Card(
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 20.0),
                                        child: _elementosInterface
                                            .childrenCardCesta(
                                            produtosBuscados[indice]),
                                      ));
                                }
                                // print("item ${_categorias[indice].toString()}");
                                  else  {
                                  Produto p = Produto(
                                      produtosBuscados[indice]["categoria"],
                                      produtosBuscados[indice]["descricao"],
                                      produtosBuscados[indice]["id_produto"],
                                      produtosBuscados[indice]["imagePath"],
                                      produtosBuscados[indice]["nome"],
                                      produtosBuscados[indice]["nomeVendedor"],
                                      produtosBuscados[indice]["preco"],
                                      produtosBuscados[indice]["qtdEstoque"],
                                      produtosBuscados[indice]["qtdPacote"],
                                      produtosBuscados[indice]["status"],
                                      produtosBuscados[indice]["unidadeMedida"],
                                      produtosBuscados[indice]
                                          ["usernameVendedor"]);

                                  return InkWell(
                                      highlightColor: Colors.cyan,
                                      hoverColor: Colors.cyan,
                                      onTap: () {
                                        // produtosBuscados[indice];
                                        _verProduto(p);
                                      }, // child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child: _elementosInterface
                                            .childrenCardProdutoX(p),
                                      ));
                                }
                              })),
                    ]))));

    // drawer: new NavDrawer(true),
  }
}

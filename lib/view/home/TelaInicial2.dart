import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCategoria.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/categoria/TelaProdutoPorCategoria.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/common/funcoesComumWidget.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeProduto.dart';
import 'package:verde_vegetal_app/view/produto/TelaTodosProdutos.dart';

class TelaInicial2 extends StatefulWidget {
  @override
  _TelaInicial2State createState() => _TelaInicial2State();
}

class _TelaInicial2State extends State<TelaInicial2> {
  ElementosInterface elementosInterface = new ElementosInterface();
  CarouselController buttonCarouselController = CarouselController();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ValidacaoDados validacao = ValidacaoDados();
  ControllerCategoria ctrCategoria = ControllerCategoria();
  ControllerProduto ctrProduto = ControllerProduto();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ScrollController _controller = new ScrollController();

  Future<dynamic> _usuario;
  Future<List> _produtos;
  Future<List> _categoriass;
  var logado = null;

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

  buscaProdutosCategoria(String categoriaEscolhida) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TelaProdutosPorCategoria(categoriaEscolhida)));
  }

  @override
  void initState() {
    _categoriass = ctrCategoria.recuperaCategoria();
    _produtos = ctrProduto.recuperaProdutoHome(7);
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
            padding: EdgeInsets.all(20),

            child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _produtos = ctrProduto.recuperaProdutoHome(7);
                  });
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Categorias",

                          style: ControllerCommon.estiloTexto(
                              "titulo 2 negrito", Colors.black)),
                      FutureBuilder(
                        future: _categoriass,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CarouselSlider(

                              items: snapshot.data.map<Widget>((item) {
                                //=======FORMATA CATEGORIA============
                                String nome = "";
                                if (item["nome"].split(" ").length == 1)
                                  nome = item["nome"];
                                else {
                                  for (int i = 0; i < item["nome"].split(" ").length; i++) {
                                    nome += item["nome"].split(" ")[i] + " ";
                                    if (i == 0) nome += "\n";
                                  }
                                }
                                //=====================================
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1.70,
                                      width: MediaQuery.of(context).size.width,
                                      child: Card(
                                        color: Colors.white,
                                        child: Card(
                                            child: InkWell(
                                          highlightColor: Colors.cyan,
                                          hoverColor: Colors.cyan,
                                          onTap: () {
                                            buscaProdutosCategoria(
                                                item["nome"]);
                                          },
                                          child: Stack(children: <Widget>[
                                            Positioned(

                                              bottom: 13,
                                              child: FadeInImage(
                                                imageErrorBuilder:
                                                    (BuildContext context,
                                                        Object exception,
                                                        StackTrace stackTrace) {
                                                  print('Error Handler');
                                                  return Icon(Icons.error);
                                                },
                                                placeholder: AssetImage(
                                                    'assets/images/desfoque.png'),
                                                image: NetworkImage(
                                                    item["imagePath"]),
                                                fit: BoxFit.cover,
                                                height: 70.0,
                                                width: 100.0,
                                              ),
                                            ),
                                            Positioned(
                                                left: 5,
                                                bottom: -5,
                                                child:
                                                    Column(children: <Widget>[
                                                  Text(
                                                    nome,

                                                    style: ControllerCommon
                                                        .estiloTextoNegrito(12),
                                                  )
                                                ])),
                                          ]),
                                        )),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                              carouselController: buttonCarouselController,
                              options: CarouselOptions(
                                height: 110,
                                autoPlay: false,
                                enlargeCenterPage: true,
                                viewportFraction: 0.4,
                                //Aumenta ou diminui a qtd que é mostrada
                                aspectRatio: 3.0,
                                initialPage: 2,
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      Text("Produtos",

                          style: ControllerCommon.estiloTexto(
                              "titulo 2 negrito", Colors.black)),
                      FutureBuilder(
                          future: _produtos,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data.length == 0) {
                                return ListView.builder(
                                    physics: const BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    controller: _controller,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: 1,
                                    itemBuilder: (context, indice) {
                                      return InkWell(
                                          highlightColor: Colors.cyan,
                                          hoverColor: Colors.cyan,
                                          onTap: null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                            child: Text(
                                              "Não existem produtos disponiveis no momento",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal", Colors.black),
                                            ),
                                          ));
                                    });
                              }

                              return Expanded(
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      controller: _controller,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, indice) {

                                        if (indice ==
                                                snapshot.data.length - 1 &&
                                            snapshot.data.length > 2) {
                                          return ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TelaTodosProdutos()));
                                              },
                                              child: Text(
                                                "Ver todos os produtos",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        "normal negrito",
                                                        Colors.white),
                                              ));
                                        } else if (snapshot.data[indice]
                                                ["categoria"] ==
                                            "Cesta") {
                                          return Padding(
                                              padding: EdgeInsets.all(4),
                                              child: InkWell(
                                                  highlightColor: Colors.cyan,
                                                  hoverColor: Colors.cyan,
                                                  onTap: () {
                                                    funcoesComumWidget.verCesta(
                                                        snapshot.data[indice],
                                                        context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 20.0),
                                                    child: elementosInterface
                                                        .childrenCardCesta(
                                                            snapshot
                                                                .data[indice]),
                                                  )));
                                        } else {
                                          Produto p = Produto(
                                              snapshot.data[indice]
                                                  ["categoria"],
                                              snapshot.data[indice]
                                                  ["descricao"],
                                              snapshot.data[indice]
                                                  ["id_produto"],
                                              snapshot.data[indice]
                                                  ["imagePath"],
                                              snapshot.data[indice]["nome"],
                                              snapshot.data[indice]
                                                  ["nomeVendedor"],
                                              snapshot.data[indice]["preco"],
                                              snapshot.data[indice]
                                                  ["qtdEstoque"],
                                              snapshot.data[indice]
                                                  ["qtdPacote"],
                                              snapshot.data[indice]["status"],
                                              snapshot.data[indice]
                                                  ["unidadeMedida"],
                                              snapshot.data[indice]
                                                  ["usernameVendedor"]);

                                          return Padding(
                                              padding: EdgeInsets.all(4),
                                              child: InkWell(
                                                  highlightColor: Colors.cyan,
                                                  hoverColor: Colors.cyan,
                                                  onTap: () {
                                                    _verProduto(p);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: elementosInterface
                                                        .childrenCardProdutoX(
                                                            p),
                                                  )));
                                        }
                                        ;
                                      }));
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                    ]))),
        drawer: FutureBuilder(
            future: _usuario,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.runtimeType == Usuario)
                  return new NavDrawer(snapshot.data);
                else {
                  return new NavDrawer(null);
                }
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

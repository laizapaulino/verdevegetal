import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCategoria.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/common/funcoesComumWidget.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeProduto.dart';

class TelaProdutosPorCategoria extends StatefulWidget {
  String nomeCategoria;

  TelaProdutosPorCategoria(this.nomeCategoria); //parametro opcional

  @override
  _TelaProdutosPorCategoriaState createState() =>
      _TelaProdutosPorCategoriaState();
}

class _TelaProdutosPorCategoriaState extends State<TelaProdutosPorCategoria> {
  ElementosInterface _elementosInterface = ElementosInterface();
  double _escolha = 0;
  ScrollController _controller = new ScrollController();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

  Future<dynamic> _usuario;
  Future<dynamic> _retornoProdutos;

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

  @override
  initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _retornoProdutos =
        ControllerCategoria.produtosCategoria(widget.nomeCategoria);
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
                  _usuario = _ctrAutenticacao.recuperaLoginSalvo();
                  _retornoProdutos = ControllerCategoria.produtosCategoria(
                      widget.nomeCategoria);
                });
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Categoria: ${widget.nomeCategoria}",
                        //textAlign: TextAlign.center,
                        style: ControllerCommon.estiloTexto(
                            "titulo", Colors.black)),
                    FutureBuilder(
                        future: _retornoProdutos,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data.length == 0) {
                              return ListView.builder(
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  controller: _controller,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  itemBuilder: (context, indice) {
                                    // return Text(
                                    //   "Não existem produtos disponiveis no momento",
                                    //   style: ControllerCommon.estiloTexto("normal", Colors.black),);
                                    //
                                    return InkWell(
                                        highlightColor: Colors.cyan,
                                        hoverColor: Colors.cyan,
                                        onTap: null, // child: Card(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                          child: Text(
                                            "Ainda não temos produtos nessa categoria :(",
                                            style: ControllerCommon.estiloTexto(
                                                "normal", Colors.black),
                                          ),
                                        ));
                                  });
                            }
                            print("foi aqui?");
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
                                      // print("item ${_categorias[indice].toString()}");
                                      print(snapshot.data[indice].toString());

                                      if(snapshot.data[indice].containsKey("unidadeMedida")){
                                        Produto p = Produto(
                                            snapshot.data[indice]["categoria"],
                                            snapshot.data[indice]["descricao"],
                                            snapshot.data[indice]["id_produto"],
                                            snapshot.data[indice]["imagePath"],
                                            snapshot.data[indice]["nome"],
                                            snapshot.data[indice]
                                                ["nomeVendedor"],
                                            snapshot.data[indice]["preco"],
                                            snapshot.data[indice]["qtdEstoque"],
                                            snapshot.data[indice]["qtdPacote"],
                                            snapshot.data[indice]["status"],
                                            snapshot.data[indice]
                                                ["unidadeMedida"],
                                            snapshot.data[indice]
                                                ["usernameVendedor"]);

                                        return InkWell(
                                            highlightColor: Colors.cyan,
                                            hoverColor: Colors.cyan,
                                            onTap: () {
                                              _verProduto(p);
                                            }, // child: Card(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 20.0),
                                              child: _elementosInterface
                                                  .childrenCardProdutoX(p),
                                            ));
                                      }
                                      else{
                                        return InkWell(
                                            highlightColor: Colors.cyan,
                                            hoverColor: Colors.cyan,
                                            onTap: () {
                                              funcoesComumWidget.verCesta(
                                                  snapshot.data[indice],
                                                  context);
                                            }, // child: Card(
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 20.0),
                                              child: _elementosInterface
                                                  .childrenCardCesta(
                                                  snapshot.data[indice]),
                                            ));

                                      }
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
          }),
    );
  }
}

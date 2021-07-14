import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/funcoesComumWidget.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeProduto.dart';


class TelaTodosProdutosVendedor extends StatefulWidget {
  String username;
  String nome;

  TelaTodosProdutosVendedor(this.username, this.nome);

  @override
  _TelaTodosProdutosVendedorState createState() =>
      _TelaTodosProdutosVendedorState();
}

class _TelaTodosProdutosVendedorState extends State<TelaTodosProdutosVendedor> {
  ElementosInterface _elementosInterface = new ElementosInterface();
  Future<dynamic> _usuarioVendedor;
  Future<List> _produtos;
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();
  ControllerProduto _ctrProduto = ControllerProduto();
  ScrollController _controller = new ScrollController();

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
              builder: (context) => TelaExibeProduto(produto, null)));
    }
  }

  void initState() {
    _usuarioVendedor =
        _ctrUsuario.recuperarDadosVisualizacaoPerfilPublico(widget.username);

    _produtos =
        _ctrProduto.recuperaTodosItensVendedorPorUsername("produtos vendedor",widget.username, 50);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
          padding: EdgeInsets.all(20),
          // child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text("Todos os produtos ${widget.nome == ""? "":"de ${widget.nome}"}",
                    //textAlign: TextAlign.center,
                    style:
                        ControllerCommon.estiloTexto("titulo", Colors.black)),
                FutureBuilder(
                    future: _produtos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data.length == 0) {
                          return Text(
                              "Não existem produtos disponiveis no momento");
                        }

                        return Expanded(child:ListView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _controller,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, indice) {
                                if (snapshot.data[indice]["categoria"] == "Cesta"){print("Não entrei");
                                  return InkWell(
                                      highlightColor: Colors.cyan,
                                      hoverColor: Colors.cyan,
                                      onTap: () {

                                        funcoesComumWidget.verCesta(snapshot.data[indice], context);
                                      }, // child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 20.0),
                                        child: _elementosInterface
                                            .childrenCardCesta(snapshot.data[indice]),
                                      ));
                                }
                                else {
                                      Produto p = Produto(
                                          snapshot.data[indice]["categoria"],
                                          snapshot.data[indice]["descricao"],
                                          snapshot.data[indice]["id_produto"],
                                          snapshot.data[indice]["imagePath"],
                                          snapshot.data[indice]["nome"],
                                          snapshot.data[indice]["nomeVendedor"],
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
                                            // snapshot.data[indice];
                                            _verProduto(p);
                                          }, // child: Card(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                            child: _elementosInterface
                                                .childrenCardProdutoX(p),
                                          ));
                                    }
                                  }))
                        ;
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ])

        ));
  }
}

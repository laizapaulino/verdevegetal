import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerVendas.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/compra/TelaResumoCompra.dart';

class TelaEscolhaPagamento extends StatefulWidget {
  @override
  _TelaEscolhaPagamentoState createState() => _TelaEscolhaPagamentoState();
}

class _TelaEscolhaPagamentoState extends State<TelaEscolhaPagamento> {
  ElementosInterface _elementosInterface = ElementosInterface();
  ControllerVenda _ctrVenda = ControllerVenda();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ScrollController _controller = new ScrollController();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future _usuario;
  Future<dynamic> _produtosCarrinho;
  List todosProduto = [];
  var valorTotal = 0.00;
  String endereco = "";
  NumberFormat formatter = NumberFormat("0.00");
  List formaPagamentoEscolhida = [];
  bool primeiraVez = true;
  List listaProdutos = [];

  prosseguir(List lista) {
    Map listaPorMetodos = {
      "entregaCredito": [],
      "entregaDinheiro": [],
      "online": []
    };

    for (int i = 0; i < lista.length; i++) {
      if (formaPagamentoEscolhida[i]["metodo"]
          .toString()
          .contains("Dinheiro")) {
        listaPorMetodos["entregaDinheiro"].add({
          "frete": lista[i]["frete"],
          "valorTotal": lista[i]["valorTotal"],
          "produtos": lista[i]["produtos"],
        });
      }
      if (formaPagamentoEscolhida[i]["metodo"]
          .toString()
          .contains("Cartão de crédito")) {
        listaPorMetodos["entregaCredito"].add({
          "frete": lista[i]["frete"],
          "valorTotal": lista[i]["valorTotal"],
          "produtos": lista[i]["produtos"],
        });
      }
      if (formaPagamentoEscolhida[i]["metodo"].toString().contains("Yapay")) {
        listaPorMetodos["online"].add({
          "frete": lista[i]["frete"],
          "dadosVendedor": lista[i]["metodosPagamentoPossiveis"],
          "valorTotal": lista[i]["valorTotal"],
          "produtos": lista[i]["produtos"],
        });
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TelaResumoCompra(valorTotal, listaPorMetodos)));
  }

  setaTotal(List lista) {
    double total = 0;
    // print("========================================");

    lista.forEach((element) {
      // print(element.toString());
      total += element["valorTotal"]+ double.parse(element["frete"].replaceAll(",","."));
    });
    // print("========================================");
    this._memoizer.runOnce(() async {
      SchedulerBinding.instance
          .addPostFrameCallback((currentFrameTimeStamp) => setState(() {
                setState(() {
                  valorTotal = total;
                });
              }));
    });
  }

  setaVendedores(List lista) {
    listaProdutos = lista;
    primeiraVez = false;
    lista.forEach((element) {
      formaPagamentoEscolhida.add({
        "usernameVendedor": element["produtos"][0].nomeVendedor,
        "apenaUmMetodo": element["metodosPagamentoPossiveis"]
                    .getListaOpcoesPagamento()
                    .length ==
                1
            ? true
            : false,
        "metodo":
            element["metodosPagamentoPossiveis"].getListaOpcoesPagamento()[0]
      });
    });
  }

  void initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _produtosCarrinho = _ctrVenda.resumoPreCompras();

    // _atualizaValorTotal(widget.produtosCompra, true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Text(
            "Escolha o método de pagamento",
            //textAlign: TextAlign.center,
            style: ControllerCommon.estiloTexto("titulo", Colors.black),
            textAlign: TextAlign.left,
          ),

//-------------- Inicio endereço
          FutureBuilder(
              future: _usuario,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.runtimeType == Usuario) {
                    Usuario us = snapshot.data;
                    endereco = us.getEndereco();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              "Endereço: ",
                              style: ControllerCommon.estiloTexto(
                                  "normal negrito", Colors.black),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "${endereco}",
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Text("");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }),
// ------------- Fim endereço

// ------------- Produtos
          FutureBuilder(
              future: _produtosCarrinho,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    if (primeiraVez == true) {
                      setaVendedores(snapshot.data);
                      setaTotal(snapshot.data);
                    }
                    return Expanded(
                        child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, indice) {
                        return Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Card(
                              shadowColor: Colors.cyan,
                              child: Column(
                                children: [
                                  Text(
                                    snapshot.data[indice]["produtos"][0]
                                        .nomeVendedor,
                                    style:
                                        ControllerCommon.estiloTextoNegrito(17),
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  Text(
                                      "Frete: ${snapshot.data[indice]["frete"]}",
                                      style: ControllerCommon.estiloTexto(
                                          "normal negrito", Colors.black)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Formas de pagamento",
                                          style: ControllerCommon.estiloTexto(
                                              "normal negrito", Colors.black)),
                                      Text(
                                          "R\$ " +
                                              formatter
                                                  .format(snapshot.data[indice]
                                                          ["valorTotal"] +
                                                      double.parse(snapshot
                                                          .data[indice]["frete"]
                                                          .replaceAll(
                                                              ",", ".")))
                                                  .replaceAll(".", ","),
                                          style: ControllerCommon.estiloTexto(
                                              "normal negrito", Colors.black))
                                    ],
                                  ),

                                    //Metodos pag

                                  snapshot.data[indice]
                                                  ["metodosPagamentoPossiveis"]
                                              .pagamentoEntregaDinheiro ==
                                          true
                                      ? RadioListTile(
                                          title: Text("Entrega - Dinheiro",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal", Colors.black)),
                                          value: "Entrega - Dinheiro",
                                          groupValue:
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"],
                                          onChanged: (valor) {
                                            setState(() {
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"] = valor.toString();
                                            });
                                          },
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(left: 1),
                                        ),

                                  snapshot
                                              .data[indice]
                                                  ["metodosPagamentoPossiveis"]
                                              .pagamentoEntregaCartao ==
                                          true
                                      ? RadioListTile(
                                          title: Text(
                                              "Entrega - Cartão de crédito",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal", Colors.black)),
                                          value: "Entrega - Cartão de crédito",
                                          groupValue:
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"],
                                          onChanged: (valor) {
                                            setState(() {
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"] = valor.toString();
                                            });
                                          },
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(left: 1),
                                        ),

                                  snapshot
                                              .data[indice]
                                                  ["metodosPagamentoPossiveis"]
                                              .pagamentoOnline ==
                                          true
                                      ? RadioListTile(
                                          title: Text(
                                              "Pagamento online - Yapay",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal", Colors.black)),
                                          value: "Pagamento online - Yapay",
                                          groupValue:
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"],
                                          onChanged: (valor) {
                                            setState(() {
                                              formaPagamentoEscolhida[indice]
                                                  ["metodo"] = valor.toString();
                                            });
                                          },
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(left: 1),
                                        ),

//Fim metodos pag
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount: snapshot
                                        .data[indice]["produtos"].length,
                                    itemBuilder: (context2, indice2) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child: snapshot
                                                    .data[indice]["produtos"]
                                                        [indice2]
                                                    .runtimeType ==
                                                ProdutoCarrinho
                                            ? _elementosInterface
                                                .childrenCardPreVenda(
                                                    snapshot.data[indice]
                                                        ["produtos"][indice2],
                                                    snapshot.data[indice]
                                                        ["frete"])
                                            : _elementosInterface
                                                .childrenCardCestaPreVenda(
                                                    snapshot.data[indice]
                                                        ["produtos"][indice2],
                                                    snapshot.data[indice]
                                                        ["frete"]),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ));
                      },
                    ));
                  } else {
                    return Text("");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }),
// ------------- Fim produtos

          Padding(padding: EdgeInsets.only(top: 15)),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              "Total: R\$ " + formatter.format(valorTotal).replaceAll(".", ","),
              style: ControllerCommon.estiloTexto("normal", Colors.black)),
          FlatButton(
              onPressed: () {
                prosseguir(listaProdutos);
              } //_comprarProdutos
              ,
              child: Text("Prosseguir"))
        ],
      )),

      // drawer: new NavDrawer(""), //Colocar dentro de um Future
    );
  }
}

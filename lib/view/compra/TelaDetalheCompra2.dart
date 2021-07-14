import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerVendas.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaDetalheCompra2 extends StatefulWidget {
  String idCompra;
  String dataCompra;
  int qtdProd;
  int qtdCancelada;
  String status;
  String previsaoEntrega;
  String usernameVendedor;
  double valorFrete;

  TelaDetalheCompra2(this.idCompra, this.dataCompra, this.qtdProd, this.qtdCancelada, this.status, this.previsaoEntrega, this.usernameVendedor,
      this.valorFrete);

  @override
  _TelaDetalheCompra2State createState() => _TelaDetalheCompra2State();
}

class _TelaDetalheCompra2State extends State<TelaDetalheCompra2> {
  ScrollController _controller = new ScrollController();
  ElementosInterface _elementosInterface = new ElementosInterface();
  ControllerVenda _ctrVenda = ControllerVenda();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  NumberFormat formatter = NumberFormat("0.00");

  Future<Map> _compras;
  Future<dynamic> _usuario;
  bool botaoHabilitado = true;

  _cancelaItem(String idProduto, String idItemComprado, String usernameVendedor) async {
    print("_cancelaItem");
    bool confirmou = await ElementosInterface.caixaDialogoSimNao(
        "Deseja cancelar o pedido desse item?", context);

    if (confirmou == true) {
      setState(() {
        botaoHabilitado = false;
      });

      String cancelamento = "none";
      cancelamento = await _ctrVenda.cancelaItemCompra(
          idProduto, widget.idCompra, idItemComprado, "comprador", usernameVendedor);

      while (cancelamento == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }
      print(cancelamento);
      setState(() {
        botaoHabilitado = true;
        _compras = _ctrVenda.recuperaComprasConsumidorIdCompra(
            widget.idCompra, widget.usernameVendedor);
      });
    }
  }

  void initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _compras = _ctrVenda.recuperaComprasConsumidorIdCompra(
        widget.idCompra, widget.usernameVendedor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
          padding: EdgeInsets.all(10),
          //padding: EdgeInsets.all(32),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text("Pedido ${widget.dataCompra}",
                    //textAlign: TextAlign.center,
                    style: ControllerCommon
                        .estiloTexto("titulo", Colors.black)),
                FutureBuilder(
                    future: _compras,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data.length == 0) {
                          return Text("Não foi possivel recuperar suas compras",
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black));
                        }
                        print(snapshot.data["itensComprados"].length);
                        print(snapshot.data.keys.toString());
                        print(snapshot.data.toString());
                        return
                          // Expanded(
                          //   child:
                            Column(
                                children: [
                          Column(
                            children: [
                              Row(children: [
                                Flexible(
                                    child: Text(
                                        "Status entrega atual: " +
                                            widget.status.replaceAll("\n", ""),
                                        //textAlign: TextAlign.center,
                                        style: ControllerCommon.estiloTexto(
                                            "normal negrito",
                                            widget.status
                                                    .toString()
                                                    .contains("Cancelado")
                                                ? Colors.redAccent
                                                : widget.status
                                                        .toString()
                                                        .contains("Preparando")
                                                    ? Colors.green
                                                    : widget.status
                                                            .toString()
                                                            .contains("final")
                                                        ? Colors.indigo
                                                        : Colors.black)))
                              ]),
                              //======Dados comprador=================================
                              Column(children: [
                                Row(children: [
                                  Flexible(
                                      child: Text(
                                          (
                                              widget.qtdProd != widget.qtdCancelada ?
                                              "Valor a pagar: R\$${formatter.format(snapshot.data['valorTotal'])} + R\$${formatter.format(widget.valorFrete)} (frete)\n"
                                                  : "")
                                              +
                                              "Telefone do vendedor: ${snapshot.data['celularVendedor']}",
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black))),
                                ]),
                                Row(children: [
                                  Flexible(
                                      child: Text(
                                          "Email do vendedor: ${snapshot.data['emailVendedor']}",
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black))),
                                ]),
                                Divider(
                                  color: Colors.indigo,
                                ),
                              ]),
                              //======================================================

                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                        "Previsão entrega: ${widget.previsaoEntrega}",
                                        //textAlign: TextAlign.center,
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black)),
                                  )
                                ],
                              ),

                            ],
                          ),

                          Divider(
                            color: Colors.cyan,
                          ),

                          ListViwerAninhadoItemCompra(
                              snapshot.data["itensComprados"]),

                          //============OLD=====================================
                          // Expanded(
                          //     child:
                          //     ListView.builder(
                          //         physics: const BouncingScrollPhysics(
                          //             parent: AlwaysScrollableScrollPhysics()),
                          //         controller: _controller,
                          //         scrollDirection: Axis.vertical,
                          //         shrinkWrap: true,
                          //         itemCount: snapshot.data["itensComprados"].length,
                          //         itemBuilder: (context, indice) {
                          //
                          //
                          //           double precoItem = double.parse(snapshot
                          //               .data["itensComprados"][indice]["precoUnitario"]
                          //               .replaceAll(",", ".")) *
                          //               snapshot
                          //                   .data["itensComprados"][indice]["quantidade"];
                          //
                          //
                          //           return InkWell(
                          //               highlightColor: Colors.cyan,
                          //               hoverColor: Colors.cyan,
                          //               onTap: () {}, // child: Card(
                          //               child: Card(
                          //                 child: Container(
                          //                   padding: const EdgeInsets.symmetric(
                          //                       vertical: 10.0,
                          //                       horizontal: 20.0),
                          //                   child: Column(
                          //                     children: <Widget>[
                          //
                          //                       ElementosInterface.itemComprado(
                          //                           snapshot
                          //                               .data["itensComprados"][indice],
                          //                           precoItem),
                          //
                          //                       snapshot
                          //                           .data["itensComprados"][indice]["status"]
                          //                           .contains("Aguardando")
                          //
                          //                           ? MaterialButton(
                          //                           onPressed: snapshot
                          //                               .data["itensComprados"][indice]
                          //                           ["status"]
                          //                               .toString()
                          //                               .contains(
                          //                               "Preparando") ||
                          //                               snapshot
                          //                                   .data["itensComprados"][indice]
                          //                               ["status"]
                          //                                   .toString()
                          //                                   .contains(
                          //                                   "Cancelado") ||
                          //                               botaoHabilitado ==
                          //                                   false
                          //                               ? null
                          //                               : () async {
                          //                             await _cancelaItem(
                          //                                 snapshot
                          //                               .data["itensComprados"][indice]
                          //                                 ["idProduto"],
                          //                                 snapshot
                          //                               .data["itensComprados"][indice][
                          //                                 "idItemComprado"]);
                          //                           },
                          //                           color: Colors.white,
                          //                           child:
                          //                           snapshot
                          //                               .data["itensComprados"][indice]
                          //                           ["status"].contains(
                          //                               "Cancelado") ||
                          //                               snapshot
                          //                               .data["itensComprados"][indice]
                          //                               ["status"].contains(
                          //                                   "finalizada")
                          //                               ? Divider() :
                          //                           Text("Cancelar",
                          //                               //textAlign: TextAlign.center,
                          //                               style: ControllerCommon
                          //                                   .estiloTexto(
                          //                                   "normal",
                          //                                   Colors
                          //                                       .redAccent)))
                          //                           : Divider()
                          //                       ,
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ));
                          //           //       }));
                          //
                          //
                          //         }))
                          //====================================================
                        ]);
                        // );
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
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

  ListViwerAninhadoItemCompra(List listaPorMetodo) {
    List<Widget> itens = [];

    for (int indice = 0; indice < listaPorMetodo.length; indice++) {
      String produtosCesta = "";
      if (listaPorMetodo[indice].containsKey("produtos")) {
        listaPorMetodo[indice]["produtos"].forEach((key, value) {
          produtosCesta += produtosCesta == "" ? "" : ",";
          produtosCesta += " " +
              value["nomeProduto"] +
              " - " +
              value["qtdPacote"] +
              value['unidadeMedida'];
        });
      }

      double precoItem = double.parse(
              listaPorMetodo[indice]["precoUnitario"].replaceAll(",", ".")) *
          listaPorMetodo[indice]["quantidade"];

      itens.add(Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color:
                listaPorMetodo[indice]["status"].toString().contains("Cancel")
                    ? Colors.black12
                    : Colors.white,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child:

                  Column(
                    children: <Widget>[
                      ElementosInterface.itemComprado(
                          listaPorMetodo[indice], precoItem),
                      listaPorMetodo[indice]["status"].contains("Aguardando")
                          ? MaterialButton(
                              onPressed: listaPorMetodo[indice]["status"]
                                          .toString()
                                          .contains("Preparando") ||
                                      listaPorMetodo[indice]["status"]
                                          .toString()
                                          .contains("Cancelado") ||
                                      botaoHabilitado == false
                                  ? null
                                  : () async {
                                      await _cancelaItem(
                                          listaPorMetodo[indice]["idProduto"],
                                          listaPorMetodo[indice]["idItemComprado"],listaPorMetodo[indice]["usernameVendedor"]);
                                    },
                              color: Colors.white,
                              child: listaPorMetodo[indice]["status"]
                                          .contains("Cancelado") ||
                                      listaPorMetodo[indice]["status"]
                                          .contains("finalizada")
                                  ? Divider()
                                  : Text("Cancelar",
                                      //textAlign: TextAlign.center,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.redAccent)))
                          : Divider(),
                    ],
                  ),

      ));
    }

    return Column(children: itens);
  }
}

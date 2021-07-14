import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerVendas.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/compra/TelaCreditCardPay.dart';
import 'package:verde_vegetal_app/view/compra/TelaMinhasCompras.dart';

class TelaResumoCompra extends StatefulWidget {
  Map itemCompra;
  double valorTotal;

  TelaResumoCompra(this.valorTotal, this.itemCompra);

  /*
  * Estutura do map
  * tipoPagamento:[
      * {
      *   valorTotal
      *   produtosDoVendedor
      * },
      * {
      *   valorTotal
      *   produtosDoVendedor
      * }
  * ]
  * */

  @override
  _TelaResumoCompraState createState() => _TelaResumoCompraState();
}

class _TelaResumoCompraState extends State<TelaResumoCompra> {
  ElementosInterface _elementosInterface = ElementosInterface();
  ControllerVenda _ctrVenda = ControllerVenda();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ScrollController _controller = new ScrollController();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future _usuario;
  Future<dynamic> _produtosCarrinho;
  List todosProduto = [];
  String endereco = "";
  NumberFormat formatter = NumberFormat("0.00");
  List formaPagamentoEscolhida = [];
  bool primeiraVez = true;
  bool botaoHabilitado = true;
  String nomeComprador = "";

  setaVendedores(List lista) {
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

  finalizar() async {
    setState(() {
      botaoHabilitado = false;
    });

    var now = DateTime.now();
    bool possoProsseguir = true;
    String aviso =
        "Os produtos de pagamento na entrega serão efetuados automaticamente e você será redirecionado para realizar o pagamento online?\n\nPodemos prosseguir?";
    if ((widget.itemCompra["entregaDinheiro"].length > 0 ||
            widget.itemCompra["entregaCredito"].length > 0) &&
        widget.itemCompra["online"].length > 0) {
      possoProsseguir =
          await ElementosInterface.caixaDialogoSimNao(aviso, context);
    }
    print("passei da validação ali");
    bool apagarCarrinho =
        false; //widget.itemCompra["online"].length > 0 ? false : true;

    String username = widget.itemCompra["entregaDinheiro"].length > 0
        ? widget
            .itemCompra["entregaDinheiro"][0]["produtos"][0].usernameComprador
        : widget.itemCompra["entregaCredito"].length > 0
            ? widget.itemCompra["entregaCredito"][0]["produtos"][0]
                .usernameComprador
            : widget.itemCompra["online"][0]["produtos"][0].usernameComprador;
    var rng = new Random();
    String idCompra = "${rng.nextInt(100000)}__${username}__${now.millisecond}";

    //Faz compra dos produtos para entrega
    if (possoProsseguir == true) {
      if (widget.itemCompra["entregaDinheiro"].length > 0 ||
          widget.itemCompra["entregaCredito"].length > 0) {
        String retorno = "none";

        retorno = await _ctrVenda.cadastraCompraEntrega(
            widget.itemCompra["entregaDinheiro"],
            widget.itemCompra["entregaCredito"],
            endereco,
            now,
            apagarCarrinho,
            nomeComprador,
            idCompra);
        print("PASSOU DAQUI");
        while (retorno == "none") {
          await Future.delayed(Duration(seconds: 2), () {
            //Faz função esperar um pouco para terminar de receber dados do forEach
            return 'Dados recebidos...';
          });
        }
        print("PASSOU DAQUI");

        widget.itemCompra["entregaCredito"] = {};
        widget.itemCompra["entregaDinheiro"] = {};
      }

      if (widget.itemCompra["online"].length > 0) {
        List pagamentoOnline = widget.itemCompra["online"];
        double valorTotal = 0.0;
        pagamentoOnline.forEach((element) {
          //Soma o valorTotal de todos os vendedores
          valorTotal += double.parse(
              element["valorTotal"].toString().replaceAll(",", "."));
        });

        // Navigator.pop(context);
        //Leva para a tela de cartao de credito
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TelaCreditCardPay(pagamentoOnline,
                    valorTotal, _usuario, endereco, now, idCompra)));
      }

      if (widget.itemCompra["online"].length == 0) {
        print("Pagamento entrega apenas");
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TelaMinhasCompras()));
      }
    }

    setState(() {
      botaoHabilitado = true;
    });
  }

  void initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _produtosCarrinho = _ctrVenda.resumoPreCompras();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(

        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Resumo compra",
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
                        nomeComprador = us.nome;

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

// ------------- Produtos credito
              widget.itemCompra["entregaCredito"].length == 0
                  ? Text("")
                  : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: (Text("Pagamento na entrega - cartão de crédito",
                          style: ControllerCommon.estiloTexto(
                              "titulo 2 negrito", Colors.black)))),
              widget.itemCompra["entregaCredito"].length == 0
                  ? Text("")
                  : _elementosInterface.ListViwerAninhadoResumoCompra(
                          widget.itemCompra["entregaCredito"]),
// ------------- Fim produtos credito

              // ------------- Produtos dinheir
              widget.itemCompra["entregaDinheiro"].length == 0
                  ? Text("")
                  : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: (Text("Pagamento na entrega - Dinheiro",
                          style: ControllerCommon.estiloTexto(
                              "titulo 2 negrito", Colors.black)))),
              widget.itemCompra["entregaDinheiro"].length == 0
                  ? Text("")
                  : _elementosInterface.ListViwerAninhadoResumoCompra(
                          widget.itemCompra["entregaDinheiro"]),
// ------------- Fim produtos dinheiro

              // ------------- Produtos online

// ------------- Fim produtos online

              Padding(padding: EdgeInsets.only(top: 15)),
            ])),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              "Total: R\$ " +
                  formatter.format(widget.valorTotal).replaceAll(".", ","),
              style:
                  ControllerCommon.estiloTexto("normal negrito", Colors.black)),
          FlatButton(
              onPressed:
                  botaoHabilitado == true ? finalizar : null, //_comprarProdutos

              child: Text(
                widget.itemCompra["online"].length > 0
                    ? "Prosseguir"
                    : "Finalizar compra",
                style: ControllerCommon.estiloTexto(
                    "normal negrito", Colors.black),
              ))
        ],
      )),

      // drawer: new NavDrawer(""), //Colocar dentro de um Future
    );
  }
}

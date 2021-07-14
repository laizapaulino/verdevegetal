import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/DadosVendedor.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';

class TelaMetodosPagamento2 extends StatefulWidget {
  String username;

  TelaMetodosPagamento2(this.username);

  @override
  _TelaMetodosPagamento2State createState() => _TelaMetodosPagamento2State();
}

class _TelaMetodosPagamento2State extends State<TelaMetodosPagamento2> {
  ElementosInterface _elementosInterface = new ElementosInterface();
  bool _pagamentoEntregaDinheiro = true;
  bool _pagamentoEntregaCredito = false;
  bool _pagamentoOnlineCredito = false;
  String emailYapay = "";
  String nomeYapay = "";
  String cpfYapay = "";
  String cnpjYapay = "";
  ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();

  TextEditingController _emailYapaycontrol = TextEditingController();
  ValidacaoDados _validacaoDados = ValidacaoDados();
  String dadosYapay = "";
  String validacaoYapay = "";
  bool inicio = true;

  Future<dynamic> _dadosVendedor;
  clicouEnviar() async {
    if (_pagamentoEntregaDinheiro == false &&
        _pagamentoEntregaCredito == false &&
        _pagamentoOnlineCredito == false) {
      ElementosInterface.caixaDialogo(
          "Você precisa selecionar ao menos um método de pagamento", context);
    } else {
      // var usuario = await ctrAutenticacao.recuperaLoginSalvo();
      showDialog(
          context: context,
          builder: (BuildContext context) => Container(
              child: SimpleDialog(
                children: [
                  Center(
                    child: Container(
                      height: 70.0,
                      width: 70.0,
                      child: CircularProgressIndicator(
                        // backgroundColor: Colors.cyan,
                      ),
                    ),
                  )
                ], // The content inside the dialog
              )));
      await Future.delayed(Duration(seconds: 3), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });

      String resultadoVendedor = "";
      DadosVendedor dadosVendedor = DadosVendedor(
          widget.username,
          _pagamentoOnlineCredito == true ? emailYapay : "",
          _pagamentoOnlineCredito == true ? cpfYapay : "",
          _pagamentoOnlineCredito == true ? cnpjYapay : "",
          _pagamentoEntregaDinheiro,
          _pagamentoEntregaCredito,
          _pagamentoOnlineCredito,
          {"Itajubá": 6.00} //Mudar
          );

      resultadoVendedor =
          await ctrAutenticacao.cadastraDadosVendedor(dadosVendedor);
      while (resultadoVendedor == "") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
      print("cadastrei");
      Navigator.pop(context);
      Navigator.pushNamed(context, "/meuperfil");
    }
  }

  @override
  void initState() {
    _dadosVendedor =
        _ctrUsuario.recuperaDadosVendedorPorUsername(widget.username);
    super.initState();
  }

  setaOpcoes(var dadosV) {
    inicio = false;
    print(dadosV.toString());
    // setState(() {

    _pagamentoEntregaDinheiro = dadosV["data"].pagamentoEntregaDinheiro;
    _pagamentoEntregaCredito = dadosV["data"].pagamentoEntregaCartao;
    _pagamentoOnlineCredito = dadosV["data"].pagamentoOnline;
    emailYapay = dadosV["data"].emailYapay;
    // nomeYapay = dadosV["data"].nomeYapay;
    cpfYapay = dadosV["data"].cpfYapay;
    cnpjYapay = dadosV["data"].cnpjYapay;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
                //padding: EdgeInsets.all(32),
                child: FutureBuilder(
                    future: _dadosVendedor,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data["message"] == "Sucesso" &&
                            inicio == true) {
                          setaOpcoes(snapshot.data);
                        }

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Métodos de pagamento",
                                  //textAlign: TextAlign.center,
                                  style:
                                      ControllerCommon.estiloTextoNegrito(25)),

                              Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                    "Selecione as formas como você deseja receber os pagamentos",
                                    //textAlign: TextAlign.center,
                                    style: ControllerCommon.estiloTexto(
                                        "normal", Colors.black)),
                              ),
                              CheckboxListTile(
                                  title: Text("Pagamento na entrega - Dinheiro",
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black)),
                                  activeColor: Colors.green,
                                  //selected: true,
                                  secondary:
                                      Icon(Icons.monetization_on_outlined),
                                  value: _pagamentoEntregaDinheiro,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _pagamentoEntregaDinheiro = valor;
                                    });
                                    print(valor);
                                  }),

                              CheckboxListTile(
                                  title: Text(
                                      "Pagamento na entrega - Cartão de crédito",
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black)),
                                  activeColor: Colors.green,
                                  //selected: true,
                                  secondary: Icon(Icons.credit_card_outlined),
                                  value: _pagamentoEntregaCredito,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _pagamentoEntregaCredito = valor;
                                    });
                                  }),

                              // CheckboxListTile(
                              //     title: Text(
                              //         "Pagamento online - Cartão de crédito via Yapay",
                              //         style: ControllerCommon.estiloTexto(
                              //             "normal", Colors.black)),
                              //     activeColor: Colors.green,
                              //     //selected: true,
                              //     secondary: Icon(Icons.credit_card_outlined),
                              //     value: _pagamentoOnlineCredito,
                              //     onChanged: (bool valor) {
                              //       setState(() {
                              //         if (valor == true) {
                              //           validacaoYapay = "Pendente";
                              //         } else {
                              //           _emailYapaycontrol.text = "";
                              //           validacaoYapay = "";
                              //           dadosYapay = "";
                              //         }
                              //         _pagamentoOnlineCredito = valor;
                              //       });
                              //
                              //       print(
                              //           "pagamento online: ${_pagamentoOnlineCredito}");
                              //     }),

                              // _pagamentoOnlineCredito == true
                              //     ? Column(
                              //         children: [
                              //           Padding(
                              //               padding: EdgeInsets.only(top: 20)),
                              //           Divider(
                              //             color: Colors.cyan,
                              //           ),
                              //           Text(
                              //               "Informe o email do seu cadastro no Yapay",
                              //               //textAlign: TextAlign.center,
                              //               style: ControllerCommon.estiloTexto(
                              //                   "titulo 2 negrito",
                              //                   Colors.black)),
                              //
                              //           //Campo email
                              //           TextField(
                              //             //Define o campo de texto
                              //             keyboardType:
                              //                 TextInputType.emailAddress,
                              //             //Define  tipo de teclado
                              //             decoration: InputDecoration(
                              //                 labelText: "E-mail"),
                              //             enabled: true,
                              //             //maxLength: 11,
                              //             maxLengthEnforced: false,
                              //             style: TextStyle(
                              //                 fontSize: 15, color: Colors.cyan),
                              //             obscureText: false,
                              //             onSubmitted: (String texto) {
                              //               //Quando fecha o teclado
                              //               print(texto);
                              //             },
                              //             controller: _emailYapaycontrol,
                              //           ),
                              //           //Fim campo email
                              //           Padding(
                              //             padding: EdgeInsets.only(top: 10),
                              //             child: RaisedButton(
                              //                 color: Colors.deepOrange,
                              //                 child: Text("Validar conta Yapay",
                              //                     style: ControllerCommon
                              //                         .estiloTexto(
                              //                             "titulo 2 negrito",
                              //                             Colors.black)),
                              //                 padding: EdgeInsets.all(15),
                              //                 onPressed: () async {
                              //                   var retorno = {};
                              //                   retorno = await _validacaoDados
                              //                       .validaVendedorYapay(
                              //                           _emailYapaycontrol
                              //                               .text);
                              //                   while (retorno == {}) {
                              //                     await Future.delayed(
                              //                         Duration(seconds: 2), () {
                              //                       //Faz função esperar um pouco para terminar de receber dados do forEach
                              //                       return 'Dados recebidos...';
                              //                     });
                              //                   }
                              //
                              //                   print("Voltei");
                              //                   print(retorno["message"]);
                              //                   setState(() {
                              //                     if (retorno["message"] ==
                              //                         'success') {
                              //                       validacaoYapay = "Sucesso";
                              //
                              //                       emailYapay =
                              //                           "${retorno["email"]}";
                              //                       nomeYapay =
                              //                           "${retorno["nome"]}";
                              //                       cpfYapay =
                              //                           "${retorno["cpf"]}";
                              //                       cnpjYapay =
                              //                           "${retorno["email"]}";
                              //
                              //                       dadosYapay =
                              //                           "Nome cadastrado: ${retorno["nome"]}\nCPF cadastrado:${retorno["cpf"] != null ? retorno["cpf"] : '-'}\nCNPJ cadastrado:${retorno["cnpj"] != null ? retorno["cnpj"] : '-'}";
                              //                     } else {
                              //                       dadosYapay =
                              //                           "Revise se o email está correto e tente novamente";
                              //                       validacaoYapay = "Falha";
                              //                     }
                              //                   });
                              //                 }),
                              //           ),
                              //           InkWell(
                              //             highlightColor: Colors.deepOrange,
                              //             child: Text(
                              //                 "Caso ainda não tenha uma conta no Yapay, CLIQUE AQUI"),
                              //             onTap: () async {
                              //               if (await canLaunch(
                              //                   "https://www.yapay.com.br/criar-conta/")) {
                              //                 await launch(
                              //                     "https://www.yapay.com.br/criar-conta/");
                              //               }
                              //             },
                              //           ),
                              //         ],
                              //       )
                              //     : Text(""),
                              //
                              // dadosYapay != ""
                              //     ? Column(
                              //         children: [
                              //           Padding(
                              //               padding: EdgeInsets.only(top: 10),
                              //               child: Text(
                              //                   "Confira seus dados no Yapay",
                              //                   style: ControllerCommon
                              //                       .estiloTexto(
                              //                           "normal negrito",
                              //                           Colors.black))),
                              //           Padding(
                              //               padding: EdgeInsets.only(top: 10),
                              //               child: Text(dadosYapay,
                              //                   style: ControllerCommon
                              //                       .estiloTexto("normal ",
                              //                           Colors.black)))
                              //         ],
                              //       )
                              //     : Text(""),

                              //Botão proximo
                              Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        RaisedButton(
                                            color:
                                                Color.fromRGBO(34, 192, 149, 1),
                                            child: Text("Salvar",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        "titulo 2 negrito",
                                                        Colors.white)),
                                            padding: EdgeInsets.all(15),
                                            onPressed:
                                                validacaoYapay == "Sucesso" ||
                                                        validacaoYapay == ""
                                                    ? clicouEnviar
                                                    : null)
                                      ])),
                            ]);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }))));
  }
}

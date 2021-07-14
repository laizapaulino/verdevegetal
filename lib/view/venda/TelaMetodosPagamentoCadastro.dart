import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/venda/TelaValoresFreteCadastro.dart';

class TelaMetodosPagamento extends StatefulWidget {
  Map<String, dynamic> usuario;

  TelaMetodosPagamento(this.usuario);

  @override
  _TelaMetodosPagamentoState createState() => _TelaMetodosPagamentoState();
}

class _TelaMetodosPagamentoState extends State<TelaMetodosPagamento> {
  bool _pagamentoEntregaDinheiro = true;
  bool _pagamentoEntregaCredito = false;
  bool _pagamentoOnlineCredito = false;
  String emailYapay = "";
  String nomeYapay = "";
  String cpfYapay = "";
  String cnpjYapay = "";
  ControllerAutenticao ctrAutenticacao = ControllerAutenticao();

  _clicouEnviar() async {
    if (_pagamentoEntregaDinheiro == false &&
        _pagamentoEntregaCredito == false &&
        _pagamentoOnlineCredito == false) {
      ElementosInterface.caixaDialogo(
          "Você precisa selecionar ao menos um método de pagamento", context);
    } else {
      if (widget.usuario.isNotEmpty) {
        widget.usuario.addAll({
          "emailYapay": emailYapay,
          "nomeYapay": nomeYapay,
          "cpfYapay": cpfYapay,
          "cnpjYapay": cnpjYapay,
          "pagamentoEntregaDinheiro": _pagamentoEntregaDinheiro,
          "pagamentoEntregaCredito": _pagamentoEntregaCredito,
          "pagamentoOnlineCredito": _pagamentoOnlineCredito
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TelaValoresFrete(widget.usuario)));
      }
    }
  }

  TextEditingController _emailYapaycontrol = TextEditingController();
  ValidacaoDados _validacaoDados = ValidacaoDados();
  String dadosYapay = "";
  String validacaoYapay = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            //padding: EdgeInsets.all(32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Text("Cadastro de usuário",
                  //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTextoNegrito(25)),

              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("Métodos pagamento",
                    //textAlign: TextAlign.center,
                    style: ControllerCommon.estiloTexto(
                        "titulo 2 negrito", Colors.black)),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text("Selecione as formas como você deseja receber",
                    //textAlign: TextAlign.center,
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
              ),
              CheckboxListTile(
                  title: Text("Pagamento na entrega - Dinheiro",
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black)),
                  activeColor: Colors.green,
                  //selected: true,
                  secondary: Icon(Icons.monetization_on_outlined),
                  value: _pagamentoEntregaDinheiro,
                  onChanged: (bool valor) {
                    setState(() {
                      _pagamentoEntregaDinheiro = valor;
                    });
                    print(valor);
                  }),

              CheckboxListTile(
                  title: Text("Pagamento na entrega - Cartão de crédito",
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black)),
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
              //     title: Text("Pagamento online - Cartão de crédito via Yapay",
              //         style:
              //             ControllerCommon.estiloTexto("normal", Colors.black)),
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
              //     }),

              _pagamentoOnlineCredito == true
                  ? Column(
                      children: [
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Divider(
                          color: Colors.cyan,
                        ),
                        Text("Informe o email do seu cadastro no Yapay",
                            //textAlign: TextAlign.center,
                            style: ControllerCommon.estiloTexto(
                                "titulo 2 negrito", Colors.black)),

                        //Campo email
                        TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.emailAddress,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "E-mail"),
                          enabled: true,
                          //maxLength: 11,
                          maxLengthEnforced: false,
                          style: TextStyle(fontSize: 15, color: Colors.cyan),
                          obscureText: false,
                          onSubmitted: (String texto) {
                            //Quando fecha o teclado
                            print(texto);
                          },
                          controller: _emailYapaycontrol,
                        ),
                        //Fim campo email
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: RaisedButton(
                              color: Colors.deepOrange,
                              child: Text("Validar conta Yapay",
                                  style: ControllerCommon.estiloTexto(
                                      "titulo 2 negrito", Colors.black)),
                              padding: EdgeInsets.all(15),
                              onPressed: () async {
                                var retorno = {};
                                retorno =
                                    await _validacaoDados.validaVendedorYapay(
                                        _emailYapaycontrol.text);
                                while (retorno == {}) {
                                  await Future.delayed(Duration(seconds: 2),
                                      () {
                                    //Faz função esperar um pouco para terminar de receber dados do forEach
                                    return 'Dados recebidos...';
                                  });
                                }


                                setState(() {
                                  if (retorno["message"] == 'success') {
                                    validacaoYapay = "Sucesso";

                                    emailYapay = "${retorno["email"]}";
                                    nomeYapay = "${retorno["nome"]}";
                                    cpfYapay = "${retorno["cpf"]}";
                                    cnpjYapay = "${retorno["email"]}";

                                    dadosYapay =
                                        "Nome cadastrado: ${retorno["nome"]}\nCPF cadastrado:${retorno["cpf"] != null ? retorno["cpf"] : '-'}\nCNPJ cadastrado:${retorno["cnpj"] != null ? retorno["cnpj"] : '-'}";
                                  } else {
                                    dadosYapay =
                                        "Revise se o email está correto e tente novamente";
                                    validacaoYapay = "Falha";
                                  }
                                });
                              }),
                        ),
                        // InkWell(
                        //   highlightColor: Colors.deepOrange,
                        //   child: Text(
                        //       "Caso ainda não tenha uma conta no Yapay, CLIQUE AQUI", style: ControllerCommon.estiloTexto("normal", Colors.black),),
                        //   onTap: () async {
                        //     if (await canLaunch(
                        //         "https://www.yapay.com.br/criar-conta/")) {
                        //       await launch(
                        //           "https://www.yapay.com.br/criar-conta/");
                        //     }
                        //   },
                        // ),
                      ],
                    )
                  : Text(""),

              dadosYapay != ""
                  ? Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text("Confira seus dados no Yapay",
                                style: ControllerCommon.estiloTexto(
                                    "normal negrito", Colors.black))),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(dadosYapay,
                                style: ControllerCommon.estiloTexto(
                                    "normal ", Colors.black)))
                      ],
                    )
                  : Text(""),

              //Botão proximo
              Padding(
                  padding: EdgeInsets.only(top: 30),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    RaisedButton(
                        color: Color.fromRGBO(34, 192, 149, 1),
                        child: Text("Próximo",
                            style: ControllerCommon.estiloTexto(
                                "titulo 2 negrito", Colors.white)),
                        padding: EdgeInsets.all(15),
                        onPressed:
                            validacaoYapay == "Sucesso" || validacaoYapay == ""
                                ? _clicouEnviar
                                : null)
                  ])),
            ]),
          )
          //    )
          ),
      drawer: new NavDrawer(false),
    );
  }
}

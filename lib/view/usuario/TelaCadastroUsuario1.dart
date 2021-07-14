import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/usuario/TelaCadastroUsuario2X.dart';

import '../venda/TelaMetodosPagamentoCadastro.dart';

class TelaCadastroUsuario extends StatefulWidget {
  String email;
  String nome;
  String foto;
  String telefone;

  TelaCadastroUsuario(this.email, this.nome, this.foto, this.telefone);

  @override
  _TelaCadastroUsuarioState createState() => _TelaCadastroUsuarioState();
}

TextEditingController cpfMask =
    new MaskedTextController(mask: '000.000.000-00');
TextEditingController cnpjMask =
    new MaskedTextController(mask: "00.000.000/0000-00");
TextEditingController _nomecontrol = TextEditingController();
TextEditingController _emailcontrol = TextEditingController();

TextEditingController _telefoneControl = TextEditingController();

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  String _escolha = "Consumidor";
  String _cpfCnpj = "cpf";

  bool _validador = false;
  var maskPadrao = cpfMask;
  String numberId = "";
  ValidacaoDados _validacao = ValidacaoDados();

  clicouEnviar() {
    var campos = {
      "Nome": _nomecontrol.text,
      "E-mail": _emailcontrol.text,
      "Tipo Conta": _escolha, //widget.usuario.tipoConta,
      "Telefone": _telefoneControl.text,
    };
    if (_cpfCnpj == "cpf")
      campos["CPF"] = cpfMask.text;
    else
      campos["CNPJ"] = cnpjMask.text;

    String camposVazios = _validacao.validaCamposPreenchidos(campos);
    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
      Map<String, dynamic> usuario = {
        "nome": _nomecontrol.text,
        "tipoConta": _escolha,
        "cpf": _cpfCnpj == "cpf" ? cpfMask.text : "",
        "cnpj": _cpfCnpj == "cnpj" ? cnpjMask.text : "",
        "email": _emailcontrol.text,
        "senha": "",
        "telefone": _telefoneControl.text,
      };
      if (_escolha == "Vendedor") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TelaMetodosPagamento(usuario)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TelaCadastroUsuario2X(usuario)));
      }
    }
  }

  @override
  void initState() {
    _nomecontrol.text = widget.nome;
    _emailcontrol.text = widget.email;
    _telefoneControl.text = widget.telefone;
    cpfMask.text = "";
    cnpjMask.text = "";
    // TODO: implement initState
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
              //Tipo de usuario
              Row(children: [
                Radio(
                  //title: Text("Consumidor"),
                  value: "Consumidor",
                  groupValue: _escolha,
                  onChanged: (String valor) {
                    setState(() {
                      _escolha = valor;
                    });
                  },
                ),
                Text("Consumidor",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
                Radio(
                  //title: Text("Consumidor"),
                  value: "Vendedor",
                  groupValue: _escolha,
                  onChanged: (String valor) {
                    setState(() {
                      _escolha = valor;
                    });
                  },
                ),
                Text("Vendedor",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
              ]),
              //Fim Tipo de usuario

              //Nome
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.text,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "Nome completo"),
                enabled: true,
                maxLengthEnforced: false,
                style: ControllerCommon.estiloTexto("normal", Colors.black),
                obscureText: false,
                maxLength: 35,
                onSubmitted: (String texto) {
                  //Quando fecha o teclado
                  print(texto);
                },
                controller: _nomecontrol,
              ),
              //Fim nome usuario

              //Opção CPF ou CNPJ
              Row(children: [
                Radio(
                  //title: Text("Consumidor"),
                  value: "cpf",
                  groupValue: _cpfCnpj,
                  onChanged: (String valor) {
                    setState(() {
                      _cpfCnpj = valor;
                      maskPadrao = cpfMask;
                    });
                  },
                ),
                Text("CPF",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
                Radio(
                  //title: Text("Consumidor"),
                  value: "cnpj",
                  groupValue: _cpfCnpj,
                  onChanged: (String valor) {
                    setState(() {
                      _cpfCnpj = valor;
                      maskPadrao = cnpjMask;
                    });
                  },
                ),
                Text("CNPJ",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
              ]),
              //Fim Tipo de usuario

              //Campo cpf cnpj
              TextField(
                //controle: cpfMask,
                keyboardType: TextInputType.number,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "CPF/CNPJ"),
                enabled: true,
                maxLength: _cpfCnpj == "cpf" ? 14 : 18,
                maxLengthEnforced: true,
                style: ControllerCommon.estiloTexto("normal", Colors.black),
                obscureText: false,
                onChanged: (String texto) {
                  numberId = texto
                      .replaceAll('.', '')
                      .replaceAll('/', '')
                      .replaceAll('-', ''); //remove a formatação da mascara
                },


                controller: maskPadrao,
              ),
              //Fim CPF

              //telefone
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.number,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "Telefone"),
                enabled: true,
                // maxLength: 11,
                maxLengthEnforced: false,
                style: ControllerCommon.estiloTexto("normal", Colors.black),
                obscureText: false,
                controller: _telefoneControl,
              ),
              //Fim campo telefone

              //Campo email
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.emailAddress,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "E-mail"),
                enabled: false,
                //maxLength: 11,
                maxLengthEnforced: false,
                style: ControllerCommon.estiloTexto("normal", Colors.grey),
                obscureText: false,
                onSubmitted: (String texto) {
                  //Quando fecha o teclado
                  print(texto);
                },
                controller: _emailcontrol,
              ),
              //Fim campo email

              //Botão proximo
              Padding(padding: EdgeInsets.only(top: 10)),

              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                RaisedButton(
                    color: Color.fromRGBO(34, 192, 149, 1),
                    child: Text(
                      "Próximo",
                      style: ControllerCommon.estiloTexto(
                          "normal negrito", Colors.white),
                    ),
                    padding: EdgeInsets.all(15),
                    onPressed: clicouEnviar)
              ]),
            ]),
          )
          //    )
          ),
      drawer: new NavDrawer(false),
    );
  }
}

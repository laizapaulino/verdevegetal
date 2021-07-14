import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaAlteraEndereco2 extends StatefulWidget {
  @override
  _TelaAlteraEndereco2State createState() => _TelaAlteraEndereco2State();
}

bool apertei;

class _TelaAlteraEndereco2State extends State<TelaAlteraEndereco2> {
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  bool modoEdicao = false;
  Future<dynamic> _usuario;

  ValidacaoDados _validacao = ValidacaoDados();
  ControllerUsuario _ctrUsuario = ControllerUsuario();

  TextEditingController _cepControl = TextEditingController();
  TextEditingController _logradouroControl = TextEditingController();
  TextEditingController _bairroControl = TextEditingController();
  TextEditingController _numeroControl = TextEditingController();
  TextEditingController _complementoControl = TextEditingController();
  TextEditingController _cidadeControl = TextEditingController();
  TextEditingController _estadoControl = TextEditingController();

  bool cepValido = false;

  void initState() {
    print("init state");
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    cepValido = true;
    apertei = false;

    super.initState();
  }

  buscaCep() async {

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
              title:Text("Estou buscando o CEP...",
              //textAlign: TextAlign.center,
              style: ControllerCommon.estiloTexto(
                  "normal", Colors.black)));
        });
    await Future.delayed(Duration(seconds: 1), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });
    var retorno = await _validacao.buscaCep(_cepControl.text.toString());
    print("retorno via cep");
    print(retorno.containsKey("erro").toString());
    if (retorno == null || retorno.containsKey("erro")) {
      ElementosInterface.caixaDialogo("O CEP informado não é válido", context);
      return false;
    } else {
      setState(() {
        apertei == true;

        print(retorno["bairro"]);
        _bairroControl.text =
            retorno["bairro"] == null ? "" : retorno["bairro"];
        _cidadeControl.text =
            retorno["localidade"] == null ? "" : retorno["localidade"];
        _estadoControl.text = retorno["uf"] == null ? "" : retorno["uf"];
        _logradouroControl.text =
            retorno["logradouro"] == null ? "" : retorno["logradouro"];
      });
      return true;
    }
  }

  finalizaEdicao(String username) async {
    String camposVazios = _validacao.validaCamposPreenchidos({
      "CEP": _cepControl.text,
      "Logradouro": _logradouroControl.text,
      "Numero do endereço": _numeroControl.text,
      "Bairro": _bairroControl.text,
      "Cidade": _cidadeControl.text,
      "Estado": _estadoControl.text,
    });
    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
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

      Map<String, String> dadosAtualizar = {
        "bairro": _bairroControl.text,
        "cep": _cepControl.text,
        "cidade": _cidadeControl.text,
        "estado": _estadoControl.text,
        "logradouro": _logradouroControl.text,
        "num": _numeroControl.text,
        "complemento": _complementoControl.text
      };

      String retorno = "";
      retorno =
          await _ctrUsuario.atualizaDadosBasicos(dadosAtualizar, username);

      while (retorno == "") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }

      print("Atualizou endereço");

      // if (retorno == true) {
      Navigator.pushReplacementNamed(context, "/meuperfil");
      // }
    }
  }

  setaControllers(var dados) {
    print("setaControllers");
    print(_cepControl.text);

    if (_cepControl.text == "" && apertei == false) {
      _cepControl.text = dados.cep;
      _logradouroControl.text =
          dados.logradouro == null ? "" : dados.logradouro;
      _bairroControl.text = dados.bairro == null ? "" : dados.bairro;
      _numeroControl.text = dados.num == null ? "" : dados.num;
      _complementoControl.text =
          dados.complemento == null ? "" : dados.complemento;
      _cidadeControl.text = dados.cidade == null ? "" : dados.cidade;
      _estadoControl.text = dados.estado == null ? "" : dados.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: _usuario,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      setaControllers(snapshot.data);
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Endereço",
                                //textAlign: TextAlign.center,
                                style: ControllerCommon.estiloTexto(
                                    "titulo", Colors.black)),
                            Row(children: [
                              Flexible(
                                  child: Text(
                                      "• Pesquise pelo seu CEP para que os dados sejam preenchidos.",
                                      //textAlign: TextAlign.center,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black))),
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text(
                                      "• Caso a cidade possua um CEP geral, você poderá completar as informações",
                                      //textAlign: TextAlign.center,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black))),
                            ]),

                            //CEP
                            Row(
                              children: [
                                Flexible(
                                    child: TextField(
                                  //Define o campo de texto
                                  keyboardType: TextInputType.number,
                                  //Define  tipo de teclado
                                  decoration: InputDecoration(labelText: "CEP"),
                                  enabled: true,
                                  maxLength: 8,
                                  maxLengthEnforced: false,
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.indigo),
                                  obscureText: false,
                                  onChanged: (String text) {
                                    cepValido = false;
                                    _logradouroControl.text = "";
                                    _estadoControl.text = "";
                                    _cidadeControl.text = "";
                                    _bairroControl.text = "";
                                  },

                                  onSubmitted: (String texto) {
                                    print(texto);
                                  },
                                  controller: _cepControl,
                                )),
                                Padding(padding: EdgeInsets.only(left: 4)),
                                RaisedButton(
                                  color: Colors.blue,
                                  child: Text(
                                    "Busca CEP",
                                    style: ControllerCommon.estiloTexto(
                                        "normal negrito", Colors.white),
                                  ),
                                  onPressed: () async {
                                    bool _resposta = await buscaCep();
                                    if (_resposta == false) {
                                      setState(() {
                                        apertei = false;
                                        print("entrei");
                                        _cepControl.text = "";
                                        setaControllers(snapshot.data);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),

                            FutureBuilder(
                              future: _usuario,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  print(snapshot.data.toString());

                                  setaControllers(snapshot.data);
                                  return Column(
                                    children: [
                                      //Campo Logradouro
                                      TextField(
                                        //Define o campo de texto
                                        keyboardType: TextInputType.number,
                                        //Define  tipo de teclado
                                        decoration: InputDecoration(
                                            labelText: "Logradouro"),
                                        enabled: _logradouroControl.text == ""
                                            ? true
                                            : false,
                                        maxLengthEnforced: false,
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black),
                                        obscureText: false,

                                        onSubmitted: (String texto) {
                                          //Quando fecha o teclado
                                          print(texto);
                                        },
                                        controller: _logradouroControl,
                                      ),

                                      //Bairro
                                      TextField(
                                        //Define o campo de texto
                                        keyboardType: TextInputType.number,
                                        //Define  tipo de teclado
                                        decoration: InputDecoration(
                                            labelText: "Bairro"),
                                        enabled: _bairroControl.text == ""
                                            ? true
                                            : false,
                                        maxLengthEnforced: false,
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black),
                                        obscureText: false,
                                        onSubmitted: (String texto) {
                                          //Quando fecha o teclado
                                          print(texto);
                                        },
                                        controller: _bairroControl,
                                      ),

                                      //Campo Cidade
                                      TextField(
                                        //Define o campo de texto
                                        keyboardType: TextInputType.number,
                                        //Define  tipo de teclado
                                        decoration: InputDecoration(
                                            labelText: "Cidade"),
                                        enabled: false,
                                        maxLengthEnforced: false,
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black),
                                        obscureText: false,
                                        onSubmitted: (String texto) {
                                          //Quando fecha o teclado
                                          print(texto);
                                        },
                                        controller: _cidadeControl,
                                      ),

                                      //Campo Estado
                                      TextField(
                                        //Define o campo de texto
                                        keyboardType: TextInputType.number,
                                        //Define  tipo de teclado
                                        decoration: InputDecoration(
                                            labelText: "Estado"),
                                        enabled: false,
                                        maxLengthEnforced: false,
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black),
                                        obscureText: false,
                                        onSubmitted: (String texto) {
                                          //Quando fecha o teclado
                                          print(texto);
                                        },
                                        controller: _estadoControl,
                                      ),
                                    ],
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),

                            //Fim nome usuario

                            //Campo Número
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.number,
                              //Define  tipo de teclado
                              decoration: InputDecoration(labelText: "Número"),
                              enabled: true,
                              maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,

                              onSubmitted: (String texto) {
                                //Quando fecha o teclado
                                print(texto);
                              },
                              controller: _numeroControl,
                            ),

                            //Campo Complemento
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              decoration:
                                  InputDecoration(labelText: "Complemento"),
                              enabled: true,
                              maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,

                              controller: _complementoControl,
                            ),

                            //Botão proximo
                            Padding(padding: EdgeInsets.only(top: 10)),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RaisedButton(
                                      color: Color.fromRGBO(34, 192, 149, 1),
                                      child: Text(
                                        "Salvar",
                                        style: ControllerCommon.estiloTexto(
                                            "normal negrito", Colors.white),
                                      ),
                                      padding: EdgeInsets.all(15),
                                      onPressed: () async {
                                        await finalizaEdicao(
                                            snapshot.data.username);
                                      })
                                ])
                          ]);
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            )),
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

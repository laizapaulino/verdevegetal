import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerEstados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/usuario/TelaCadastroUsuario2X.dart';

class TelaValoresFrete extends StatefulWidget {
  Map<String, dynamic> usuario;

  TelaValoresFrete(this.usuario);

  @override
  _TelaValoresFreteState createState() => _TelaValoresFreteState();
}

class _TelaValoresFreteState extends State<TelaValoresFrete> {
  ElementosInterface _elementosInterface = new ElementosInterface();

  Map frete = {};
  ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
  String _cidade = "";
  String _uf = "";
  List<String> listaCidades = [""];

  _clicouProximo() async {
    if (frete.length == 0) {
      ElementosInterface.caixaDialogo(
          "Insira ao menos uma localidade.", context);
    } else {
      widget.usuario.addAll({"frete": frete});

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaCadastroUsuario2X(widget.usuario)));
    }
  }

  _salvaNoMap() {
    print(_escolha);
    setState(() {
      if (_escolha == "Bairro") {
        print("por bairro");
        print(_bairroControl.text);
        if (_bairroControl.text.isEmpty) {
          ElementosInterface.caixaDialogo(
              "É necessario que todos os campos estejam preenchidos.", context);
        } else {
          if (frete["${_cidade} - ${_uf}"] != null) {
            if (frete["${_cidade} - ${_uf}"][_bairroControl.text] == null) {
              //Se padrao não foi inserido, insere
              frete["${_cidade} - ${_uf}"]
                  .addAll({_bairroControl.text: _precoControl.text});
              print(frete.toString());
            } else {
              //Senão atualiza
              frete["${_cidade} - ${_uf}"][_bairroControl.text] =
                  _precoControl.text;
              print(frete.toString());
            }
          } else {
            frete.addAll({
              "${_cidade} - ${_uf}": {_bairroControl.text: _precoControl.text}
            });
            print(frete.toString());
          }
        }
      } else if (_escolha == "Padrão") {
        if (_uf == "" || _cidade == "") {
          ElementosInterface.caixaDialogo(
              "É necessario que uma localidade valida seja informada", context);
        } else {
          if (frete["${_cidade} - ${_uf}"] != null) {
            if (frete["${_cidade} - ${_uf}"]["Padrão"] == null) {
              //Se padrao não foi inserido, insere
              frete["${_cidade} - ${_uf}"]
                  .addAll({"Padrão": _precoControl.text});
            } else {
              //Senão atualiza
              frete["${_cidade} - ${_uf}"]["Padrão"] = _precoControl.text;
            }
          } else {
            //Se cidade não foi inserida

            frete.addAll({
              "${_cidade} - ${_uf}": {"Padrão": _precoControl.text}
            });
            // print(frete.toString());
          }
        }
      }
    });
  }

  String dadosYapay = "";
  String validacaoYapay = "";
  TextEditingController _bairroControl = TextEditingController();
  TextEditingController _precoControl =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  String _escolha = "Padrão";
  bool bairroHabilitado = false;
  ScrollController _controller = new ScrollController();

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
              Text("Cadastro de usuário - Frete",
                  //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTextoNegrito(25)),

//=======================Explicação==================================================================
              Text("Informe as localidades que seu frete atenderá.\n",
                  style: ControllerCommon.estiloTexto("normal", Colors.black)),

              Row(children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: '• Selecione o ',
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Estado ',
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.black)),
                        TextSpan(
                            text: ', em seguida ',
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black)),
                        TextSpan(
                            text: 'Cidade ',
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.black)),
                        TextSpan(
                            text: ' e defina o valor do frete.',
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black)),
                      ],
                    ),
                  ),
                ),
              ]),

              Row(children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: '• Pressione ',
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Adicionar localidade',
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.black)),
                        TextSpan(
                            text:
                                ' para incluir a localidade que você definiu.',
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black)),
                      ],
                    ),
                  ),
                ),
              ]),

              Row(children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text:
                          '• Quando tiver incluido todas as localidades, pressione ',
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Salvar',
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.black)),
                      ],
                    ),
                  ),
                ),
              ]),

              Divider(
                color: Colors.indigo,
              ),
//===================================================================================================

//=====================Estado e Cidade ================================================================

              Row(children: [
                Text("Estado: ",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
                Padding(padding: EdgeInsets.only(left: 5)),
                Flexible(
                  child: DropdownButton<String>(
                    value: _uf,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: ControllerCommon.estiloTexto("normal", Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue != "") {
                          listaCidades =
                              ControllerEstados.formataListaCidades(newValue);
                        } else {
                          listaCidades = [""];
                        }
                        _cidade = "";
                        _uf = newValue;
                      });
                    },
                    items: ControllerEstados.formataListaEstados()
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black)),
                      );
                    }).toList(),
                  ),
                ),
              ]),

              Row(children: [
                Text("Cidade: ",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
                Padding(padding: EdgeInsets.only(left: 5)),
                Flexible(
                  child: DropdownButton<String>(
                    value: _cidade,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: ControllerCommon.estiloTexto("normal", Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        _cidade = newValue;
                      });
                    },
                    items: listaCidades
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black)),
                      );
                    }).toList(),
                  ),
                )
              ]),

//=============================PREÇO==========================================================================

              Row(children: [
                Flexible(
                  child: TextField(
                    //Define o campo de texto
                    keyboardType: TextInputType.number,
                    //Define  tipo de teclado
                    decoration: InputDecoration(labelText: "Valor (R\$)"),
                    enabled: true,
                    //maxLength: 5,
                    //maxLengthEnforced: false,
                    style: ControllerCommon.estiloTexto("normal", Colors.black),
                    obscureText: false,

                    controller: _precoControl,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RaisedButton(
                              color: Colors.cyan,
                              child: Text("Adicionar localidade",
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.white)),
                              // padding: EdgeInsets.all(15),
                              onPressed: _salvaNoMap)
                        ])),
              ]),
              Divider(
                color: Colors.cyan,
              ),
              ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: frete.length,
                  itemBuilder: (context, indice) {
                    String key = frete.keys.elementAt(indice);
                    print(key);

                    return ListView.builder(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        controller: _controller,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: frete[key].length,
                        itemBuilder: (context, indice) {
                          String key2 = frete[key].keys.elementAt(indice);
                          print(frete[key]);
                          print(key2);
                          return InkWell(
                              highlightColor: Colors.cyan,
                              hoverColor: Colors.cyan,
                              onTap: () {
                                setState(() {
                                  frete[key].remove(key2);
                                  if (frete[key].length == 0) {
                                    frete.remove(key);
                                  }
                                });
                              }, // child: Card(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: _elementosInterface.childrenCardFrete(
                                    key, key2, frete[key][key2]),
                              ));
                        });
                  }),
              RaisedButton(
                  color: Color.fromRGBO(34, 192, 149, 1),
                  child: Text("Prosseguir",
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.white)),
                  padding: EdgeInsets.all(15),
                  onPressed: _clicouProximo)
            ]),
          )),
      drawer: new NavDrawer(false),
    );
  }
}

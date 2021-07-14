import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerEstados.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaValoresFreteEdicao extends StatefulWidget {
  String username;
  var fretes;

  TelaValoresFreteEdicao(this.username, this.fretes);

  @override
  _TelaValoresFreteEdicaoState createState() => _TelaValoresFreteEdicaoState();
}

class _TelaValoresFreteEdicaoState extends State<TelaValoresFreteEdicao> {
  String _cidade = "";
  String _estado = "";
  List<String> listaCidades = [""];
  ScrollController _controller = new ScrollController();
  TextEditingController _bairroControl = TextEditingController();
  TextEditingController _precoControl =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  String _escolha = "Padrão";

  _clicouProximo() async {
    if (widget.fretes.localidades.length == 0) {
      ElementosInterface.caixaDialogo(
          "Insira ao menos uma localidade.", context);
    } else {
      String retorno = "none";
      print(widget.fretes.localidades);

      retorno = await ControllerUsuario.atualizaFreteVendedor(
          widget.username, widget.fretes.localidades);
      Navigator.pop(context);

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

      while (retorno == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados
          return 'Dados recebidos...';
        });
      }

      // widget.usuario.addAll({"widget.fretes": widget.fretes});

      Navigator.pushNamed(context, "/meuperfil");
    }
  }

  _salvaNoMap() {
    print(_escolha);
    setState(() {
      if (_escolha == "Bairro") {
        print("por bairro");
        print(_bairroControl.text);
        if (_bairroControl.text.isEmpty || _cidade.isEmpty) {
          ElementosInterface.caixaDialogo(
              "É necessario que todos os campos estejam preenchidos.", context);
        } else {
          if (widget.fretes.localidades["${_cidade} - ${_estado}"] != null) {
            if (widget.fretes.localidades["${_cidade} - ${_estado}"]
                    [_bairroControl.text] ==
                null) {
              //Se padrao não foi inserido, insere
              widget.fretes.localidades["${_cidade} - ${_estado}"]
                  .addAll({_bairroControl.text: _precoControl.text});
              print(widget.fretes.localidades.toString());
            } else {
              //Senão atualiza
              widget.fretes.localidades["${_cidade} - ${_estado}"]
                  [_bairroControl.text] = _precoControl.text;
              print(widget.fretes.localidades.toString());
            }
          } else {
            widget.fretes.localidades.addAll({
              "${_cidade} - ${_estado}": {
                _bairroControl.text: _precoControl.text
              }
            });
            print(widget.fretes.localidades.toString());
          }
        }
      } else if (_escolha == "Padrão") {
        if (_estado == "" || _cidade == "") {
          ElementosInterface.caixaDialogo(
              "É necessario que uma localidade valida seja informada", context);
        } else {
          if (widget.fretes.localidades["${_cidade} - ${_estado}"] != null) {
            if (widget.fretes.localidades["${_cidade} - ${_estado}"]
                    ["Padrão"] ==
                null) {
              //Se padrao não foi inserido, insere
              widget.fretes.localidades["${_cidade} - ${_estado}"]
                  .addAll({"Padrão": _precoControl.text});
            } else {
              //Senão atualiza
              widget.fretes.localidades["${_cidade} - ${_estado}"]["Padrão"] =
                  _precoControl.text;
            }
          } else {
            //Se cidade não foi inserida

            widget.fretes.localidades.addAll({
              "${_cidade} - ${_estado}": {"Padrão": _precoControl.text}
            });
            // print(widget.fretes.toString());
          }
        }
      }
    });
  }

  @override
  void initState() {
    // localidades = ControllerUsuario.recuperaFreteVendedorPorUsername(widget.username);
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
              Text("Edição - Frete",
                  //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTextoNegrito(25)),
//====================================================================

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
                                text:
                                ', em seguida ',
                                style: ControllerCommon.estiloTexto(
                                    "normal", Colors.black)),
                            TextSpan(
                                text: 'Cidade ',
                                style: ControllerCommon.estiloTexto(
                                    "normal negrito", Colors.black)),
                            TextSpan(
                                text:
                                ' e defina o valor do frete.',
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
                          text: '• Quando tiver incluido todas as localidades, pressione ',
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
                  Divider(color: Colors.indigo,),
//===================================================================================================

//=====================Estado e Cidade ================================================================

              Row(children: [
                Text("Estado: ",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
                Padding(padding: EdgeInsets.only(left: 5)),
                Flexible(
                  child: DropdownButton<String>(
                    value: _estado,
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
                        _estado = newValue;
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

//=======================================================================================================

              Padding(padding: EdgeInsets.only(top: 10)),

              Row(children: [
                //PREÇO

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

                    onSubmitted: (String texto) {
                      //Quando fecha o teclado
                      // print(texto);
                    },
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
                  itemCount: widget.fretes.localidades.length,
                  itemBuilder: (context, indice) {
                    // print("item ${_categorias[indice].toString()}");
                    String key =
                        widget.fretes.localidades.keys.elementAt(indice);
                    print(key);

                    return ListView.builder(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        controller: _controller,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: widget.fretes.localidades[key].length,
                        itemBuilder: (context, indice) {
                          String key2 = widget.fretes.localidades[key].keys
                              .elementAt(indice);
                          print(widget.fretes.localidades[key]);
                          print(key2);
                          return InkWell(
                              highlightColor: Colors.cyan,
                              hoverColor: Colors.cyan,
                              onTap: () {
                                setState(() {
                                  widget.fretes.localidades[key].remove(key2);
                                  if (widget.fretes.localidades[key].length ==
                                      0) {
                                    widget.fretes.localidades.remove(key);
                                  }
                                });
                              }, // child: Card(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: ElementosInterface().childrenCardFrete(
                                    key,
                                    key2,
                                    widget.fretes.localidades[key][key2]),
                              ));
                        });
                  }),
              RaisedButton(
                  color: Color.fromRGBO(34, 192, 149, 1),
                  child: Text("Salvar",
                      style: ControllerCommon.estiloTexto(
                          "normal negrito", Colors.white)),
                  padding: EdgeInsets.all(15),
                  onPressed: _clicouProximo)
            ]),
          )),
      drawer: new NavDrawer(false),
    );
  }
}

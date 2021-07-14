import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verde_vegetal_app/controllers/ControllerCategoria.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/Cesta.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/venda/TelaMinhaLoja.dart';

class TelaCadastroCesta extends StatefulWidget {
  Usuario usuario;

  TelaCadastroCesta(this.usuario);

  @override
  _TelaCadastroCestaState createState() => _TelaCadastroCestaState();
}

class _TelaCadastroCestaState extends State<TelaCadastroCesta> {
  TextEditingController _nomeCestaControl = TextEditingController();
  TextEditingController _nomeProdutoControl = TextEditingController();
  TextEditingController _descricaoControl = TextEditingController();
  TextEditingController _precoControl = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.'); //after
  TextEditingController _qtdEstoqueControl = TextEditingController();
  TextEditingController _qtdPacoteControl = TextEditingController();

  ValidacaoDados _validacao = ValidacaoDados();
  ControllerCategoria ctrCategoria = ControllerCategoria();
  ControllerUsuario _ctrUsuario = ControllerUsuario();
  ScrollController _controller = new ScrollController();
  ElementosInterface _elementosInterface = new ElementosInterface();

  String unidadeMedida = "g (gramas)";
  String categoria = "";
  File _image = null;
  String idCesta = "";
  Future<dynamic> _usuario;

  bool mostraCampos = false;

  Map produtosCestaMap = {};

  _concluirCadastro(BuildContext context) async {
    if (produtosCestaMap.length < 1) {
      ElementosInterface.caixaDialogo(
          "A cesta precisa conter ao menos um produto", context);
    } else {
      String camposVazios = _validacao.validaCamposPreenchidos({
        "Nome da Cesta": _nomeCestaControl.text,
        "Descricao": _descricaoControl.text,
        "Preço da Cesta": _precoControl.text,
      });

      if (camposVazios != "") {
        camposVazios = camposVazios.substring(0, camposVazios.length-2);
        String aviso = "Os campos $camposVazios estão vazios";
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

        var now = DateTime.now();
        String dataAgora =
            "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}${now.hour.toString()}-${now.minute.toString()}";

        Cesta cesta = Cesta(
          "Cesta",
            _descricaoControl.text,
            "",
            "cesta_${widget.usuario.username}_${DateTime.now()}",
            _nomeCestaControl.text,
            "${widget.usuario.nome}",
            _precoControl.text,
            int.parse(_qtdEstoqueControl.text),
            "ativo",
            {},
            widget.usuario.username);

        ControllerProduto ctrProduto = ControllerProduto();
        String retorno = "none";
        retorno = await ctrProduto.cadastraCesta(cesta, produtosCestaMap, _image);
        Navigator.pop(context);

        while (retorno == "none") {
          await Future.delayed(Duration(seconds: 2), () {
            //Faz função esperar um pouco para terminar de receber dados do forEach
            return 'Dados recebidos...';
          });
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TelaMinhaLoja()));
      }
    }
  }

  Future<List> _categoriass;

  Future chooseFile() async {
    if (_image != null) {
      setState(() {
        _image.delete();
        _image = null;
      });
    }
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  _salvaNoMap() {
    String camposVazios = _validacao.validaCamposPreenchidos({
      "Nome do Produto": _nomeProdutoControl.text,
      "Quantidade": _qtdPacoteControl.text,
    });
    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
      var produtoCesta = {
        // "image": _image != null ? _image : "",
        "nomeProduto": _nomeProdutoControl.text,
        "qtdPacote": _qtdPacoteControl.text,
        "unidadeMedida": unidadeMedida
      };
      setState(() {
        produtosCestaMap.addAll({"${_nomeProdutoControl.text}": produtoCesta});
        _nomeProdutoControl.text = "";
        _qtdPacoteControl.text = "";
        mostraCampos = false;
      });
    }
  }

  @override
  void initState() {
    _image = null;
    _usuario = _ctrUsuario.recuperarDadosVisualizacaoPerfil();
    _categoriass = ctrCategoria.recuperaCategoriaComboBox();
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
            children: [
              Padding(padding: EdgeInsets.only(top: 20)),
              FutureBuilder(
                  future: _usuario,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {

                      idCesta =
                          "cesta_${widget.usuario.username}_${DateTime.now()}";
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Cadastro de cesta",
                                //textAlign: TextAlign.center,
                                style: ControllerCommon.estiloTexto(
                                    "titulo", Colors.black)),
                            Padding(padding: EdgeInsets.only(top: 20)),

                            // ----------- IMAGEM ---------------------
                            Row(
                              children: [
                                Text(
                                  'Imagem da cesta',
                                  style: ControllerCommon.estiloTexto(
                                      "normal negrito", Colors.black),
                                ),
                                Padding(padding: EdgeInsets.only(left: 6),),
                                _image != null
                                    ? Image(
                                        image: FileImage(_image),
                                        width: 70,
                                        height: 70,
                                      )
                                    : Image(
                                  image: AssetImage('assets/images/cesta.png'),
                                  width: 70,
                                  height: 70,
                                ),

                                  //------------Imagem --------------
                                  Divider(color: Colors.indigo),
                                ],
                              ),
                              RaisedButton(
                                child: Text('Escolha a imagem',
                                    style: ControllerCommon.estiloTexto(
                                        "normal negrito", Colors.black)),
                                onPressed: chooseFile,
                                color: Colors.white70,
                              ),
                            //------------------------------------------


                            //Nome da cesta
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              decoration:
                                  InputDecoration(labelText: "Nome da cesta"),
                              enabled: true,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.cyan),
                              obscureText: false,
                              controller: _nomeCestaControl,
                            ),

                            //Descrição da cesta
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              decoration: InputDecoration(
                                  labelText: "Descrição da cesta"),
                              enabled: true,
                              maxLines: 5,
                              //maxLength: 11,
                              maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,
                              controller: _descricaoControl,
                            ),

                            //Quantidade estoque
                            Row(
                              children: [
                                Flexible(child: Text("Quantidade estoque: ")),
                                Flexible(
                                    child: TextField(
                                  //Define o campo de texto
                                  keyboardType: TextInputType.number,
                                  //Define  tipo de teclado
                                  decoration: InputDecoration(labelText: ""),
                                  enabled: true,
                                  obscureText: false,

                                  //maxLength: 11,
                                  maxLengthEnforced: false,
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.black),
                                  onSubmitted: (String texto) {
                                    //Quando fecha o teclado
                                    // print(texto);
                                  },
                                  controller: _qtdEstoqueControl,
                                )),
                              ],
                            ),

                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.number,
                              //Define  tipo de teclado
                              decoration: InputDecoration(
                                  labelText: "Preço da cesta (R\$)"),
                              enabled: true,
                              //maxLength: 5,
                              //maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,

                              onSubmitted: (String texto) {
                                //Quando fecha o teclado
                                // print(texto);
                              },
                              controller: _precoControl,
                            ),

                            Divider(
                              color: Colors.indigo,
                            ),

/*********************************************/
                            Text(
                              "Produtos",
                              style: ControllerCommon.estiloTexto(
                                  "titulo 2 negrito", Colors.black),
                            ),

                            ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                controller: _controller,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: produtosCestaMap.length,
                                itemBuilder: (context, indice) {
                                  String key =
                                      produtosCestaMap.keys.elementAt(indice);

                                  return InkWell(
                                      highlightColor: Colors.cyan,
                                      hoverColor: Colors.cyan,
                                      onTap: () {
                                        setState(() {
                                          produtosCestaMap.remove(key);
                                        });
                                      }, // child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child:
                                        Align(
                                          child:Row(
                                          //   children: [
                                          // Column(
                                            children: [
                                              Text(
                                                "${produtosCestaMap[key]["nomeProduto"]}",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        'normal negrito',
                                                        Colors.black),
                                              ),
                                              Text(
                                                "${produtosCestaMap[key]["qtdPacote"]} ${produtosCestaMap[key]["unidadeMedida"]}",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        'normal', Colors.black),
                                              ),
                                          //   ],
                                          // ),
                                              Padding(padding: EdgeInsets.only(left: 10)),
                                          Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                        ]),alignment: FractionalOffset.topLeft,
                                      ),
                                      ));
                                }),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RaisedButton(
                                      color: Colors.cyan,
                                      child: Text(
                                        "Adicionar produto",
                                        style: ControllerCommon.estiloTexto(
                                            "normal negrito", Colors.white),
                                      ),
                                      padding: EdgeInsets.all(5),
                                      onPressed: () {
                                        setState(() {
                                          mostraCampos = true;
                                        });
                                      })
                                ]),

                            mostraCampos == false
                                ? Divider()
                                : Column(children: [
                                    Divider(color: Colors.deepOrange),
                                    Divider(color: Colors.deepOrange),
                                    //Nome do produto
                                    TextField(
                                      maxLength: 26,
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      //Define o campo de texto
                                      keyboardType: TextInputType.text,
                                      //Define  tipo de teclado
                                      decoration: InputDecoration(
                                          labelText: "Nome do produto"),
                                      enabled: true,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.cyan),
                                      obscureText: false,
                                      controller: _nomeProdutoControl,
                                    ),

                                    Row(
                                      children: [
                                        Flexible(
                                            child: TextField(
                                          //Define o campo de texto
                                          keyboardType: TextInputType.number,
                                          //Define  tipo de teclado
                                          decoration: InputDecoration(
                                              labelText:
                                                  "Quantidade no pacote"),
                                          enabled: true,
                                          //maxLength: 11,
                                          maxLengthEnforced: false,
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black),
                                          obscureText: false,

                                          controller: _qtdPacoteControl,
                                        )),
                                        DropdownButton<String>(
                                          value: unidadeMedida,
                                          icon: Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              unidadeMedida = newValue;
                                            });
                                          },
                                          items: <String>[
                                            'un (unidades)',
                                            'g (gramas)',
                                            'kg (quilogramas)',
                                            'ml (miligramas)',
                                            'l (litros)'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: ControllerCommon
                                                      .estiloTexto("normal",
                                                          Colors.black)),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),


                                    //   Divider(color: Colors.indigo),
                                    RaisedButton(
                                      child: Text('Incluir produto',
                                          style: ControllerCommon.estiloTexto(
                                              "normal negrito", Colors.white)),
                                      onPressed: _salvaNoMap,
                                      color: Colors.cyan,
                                    ),

                                    Divider(color: Colors.deepOrange),
                                    Divider(color: Colors.deepOrange),
                                  ]),

/*********************************************/
                            //Preço da cesta
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                            ),

                            Padding(padding: EdgeInsets.only(top: 20)),

                            //Botão cadastrar
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RaisedButton(
                                      color: Color.fromRGBO(34, 192, 149, 1),
                                      child: Text(
                                        "Cadastrar cesta",
                                        style: ControllerCommon.estiloTexto(
                                            "normal negrito", Colors.white),
                                      ),
                                      padding: EdgeInsets.all(15),
                                      onPressed: () {
                                        _concluirCadastro(context);
                                      })
                                ]),
                          ]);
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
            ],
          ))),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:verde_vegetal_app/view/produto/TelaExibeCesta.dart';

class TelaEditaCesta extends StatefulWidget {
  var cesta;
  Usuario usuario;

  TelaEditaCesta(this.cesta, this.usuario);

  @override
  _TelaEditaCestaState createState() => _TelaEditaCestaState();
}

class _TelaEditaCestaState extends State<TelaEditaCesta> {
  TextEditingController _nomeCestaControl = TextEditingController();
  TextEditingController _nomeProdutoControl = TextEditingController();
  TextEditingController _descricaoControl = TextEditingController();
  TextEditingController _precoControl = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.'); //after
  TextEditingController _unidadeControl = TextEditingController();
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

        Cesta cesta = Cesta(
            widget.cesta.categoria,
            _descricaoControl.text,
            widget.cesta.imagePath,
            widget.cesta.idCesta,
            _nomeCestaControl.text,
            widget.cesta.nomeVendedor,
            _precoControl.text,
            int.parse(_qtdEstoqueControl.text),
            "ativo",
            produtosCestaMap,
            widget.cesta.usernameVendedor);
        ControllerProduto ctrProduto = ControllerProduto();

        if (produtosCestaMap != widget.cesta) {
          var cestaatualizada = {};
          cestaatualizada = await ctrProduto.atualizaDadosItem(
              cesta.getCestaJson(), "cesta", "idCesta", widget.cesta.idCesta);

          while (cestaatualizada == {}) {
            await Future.delayed(Duration(seconds: 2), () {
              //Faz função esperar um pouco para terminar de receber dados
              return 'Dados recebidos...';
            });
          }
          Navigator.pop(context);

          if (cestaatualizada.containsKey("erro") == false) {
            print("==========dsdsd================");
            print(cestaatualizada.toString());
            print("==========dsdsd================");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TelaExibeCesta(
                        cestaatualizada["cesta"], widget.usuario)));
          } else {
            print("=====================================");
            print("EEEEEEERRRROOOOOO");
            print("=====================================");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TelaExibeCesta(widget.cesta, widget.usuario)));
          }
        }
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
        "image": _image != null ? _image : "",
        "nomeProduto": _nomeProdutoControl.text,
        "qtdPacote": _qtdPacoteControl.text,
        "unidadeMedida": unidadeMedida
      };
      Map produ = {"${_nomeProdutoControl.text}": produtoCesta};
      setState(() {
        produtosCestaMap.addAll(produ);
        _image = null;
        _nomeProdutoControl.text = "";
        _qtdPacoteControl.text = "";
        mostraCampos = false;
      });
    }
  }

  setaControllers() {
    print("setaControllers");
    categoria = "Cesta";
    _nomeCestaControl.text = widget.cesta.nome;
    _descricaoControl.text = widget.cesta.descricao;
    _precoControl.text = widget.cesta.preco;
    _qtdEstoqueControl.text = widget.cesta.qtdEstoque.toString();
    produtosCestaMap.addAll(Map<String, dynamic>.from(widget.cesta.produtos));
  }

  @override
  void initState() {
    print("init state");
    setaControllers();

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
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                Text("Edição de cesta",
                    //textAlign: TextAlign.center,
                    style:
                        ControllerCommon.estiloTexto("titulo", Colors.black)),
                Padding(padding: EdgeInsets.only(top: 20)),

                //Nome da cesta
                TextField(
                  //Define o campo de texto
                  keyboardType: TextInputType.text,
                  //Define  tipo de teclado
                  decoration: InputDecoration(labelText: "Nome da cesta"),
                  enabled: true,
                  style: TextStyle(fontSize: 15, color: Colors.cyan),
                  obscureText: false,
                  controller: _nomeCestaControl,
                ),

                //Descrição da cesta
                TextField(
                  //Define o campo de texto
                  keyboardType: TextInputType.text,
                  //Define  tipo de teclado
                  decoration: InputDecoration(labelText: "Descrição da cesta"),
                  enabled: true,
                  maxLines: 5,
                  //maxLength: 11,
                  maxLengthEnforced: false,
                  style: ControllerCommon.estiloTexto("normal", Colors.black),
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
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
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
                  decoration:
                      InputDecoration(labelText: "Preço da cesta (R\$)"),
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

                Divider(
                  color: Colors.indigo,
                ),
///////////////////////////////////////////////////////////////
                //Nome
                //Imagem
                //Quantidade
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
                      String key = produtosCestaMap.keys.elementAt(indice);

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
                            child: Align(
                              child: Row(
                                  //   children: [
                                  // Column(
                                  children: [
                                    Flexible(
                                        child: Text(
                                      "${produtosCestaMap[key]["nomeProduto"]}",
                                      style: ControllerCommon.estiloTexto(
                                          'normal negrito', Colors.black),
                                    )),
                                    Flexible(
                                        child: Text(
                                      "${produtosCestaMap[key]["qtdPacote"]} ${produtosCestaMap[key]["unidadeMedida"]}",
                                      style: ControllerCommon.estiloTexto(
                                          'normal', Colors.black),
                                    )),
                                    //   ],
                                    // ),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ]),
                              alignment: FractionalOffset.topLeft,
                            ),
                          ));
                    }),

                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                          maxLengthEnforced: true,
                          maxLength: 30,
                          keyboardType: TextInputType.text,
                          //Define  tipo de teclado
                          decoration:
                              InputDecoration(labelText: "Nome do produto"),
                          enabled: true,
                          style: TextStyle(fontSize: 15, color: Colors.cyan),
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
                                  labelText: "Quantidade no pacote"),
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
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black)),
                                );
                              }).toList(),
                            )
                          ],
                        ),

                        Divider(color: Colors.indigo),
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

///////////////////////////////////////////////////////////////
                //Preço da cesta
                Padding(
                  padding: EdgeInsets.only(top: 20),
                ),

                Padding(padding: EdgeInsets.only(top: 20)),

                //Botão cadastrar
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RaisedButton(
                      color: Color.fromRGBO(34, 192, 149, 1),
                      child: Text(
                        "Salvar",
                        style: ControllerCommon.estiloTexto(
                            "normal negrito", Colors.white),
                      ),
                      padding: EdgeInsets.all(15),
                      onPressed: () {
                        _concluirCadastro(context);
                      })
                ]),
              ])
            ],
          ))),
      // drawer: NavDrawer(widget.usuario),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

import 'TelaExibeProduto.dart';

class TelaEditaProduto extends StatefulWidget {
  var produto;
  Usuario usuario;

  TelaEditaProduto(this.produto, this.usuario);

  @override
  _TelaEditaProdutoState createState() => _TelaEditaProdutoState();
}

class _TelaEditaProdutoState extends State<TelaEditaProduto> {
  TextEditingController _descricaoControl = TextEditingController();
  TextEditingController _precoControl = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.'); //after
  TextEditingController _unidadeControl = TextEditingController();
  TextEditingController _qtdEstoqueControl = TextEditingController();
  TextEditingController _qtdPacoteControl = TextEditingController();
  ValidacaoDados _validacao = ValidacaoDados();

  ControllerProduto ctrProduto = ControllerProduto();
  Future<List> _categoriass;

  double _escolha = 0;
  String unidadeMedida = "g (gramas)";
  String categoria;
  List<String> categorias = [
    "Frutas",
    "Verduras",
    "Legumes",
    "Raízes",
    "Grãos",
    "Ervas",
    "Produtos variados"
  ];

  File _image;
  String processei = "não";

  Future chooseFile() async {
    processei = "não";
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        processei = "sim";
        _image = image;
      });
    });
    while (processei != "sim") {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }
    if (_image != null) {
      _askedToLead();
    }
  }

  Future<void> _askedToLead() async {
    int apertou = 0;
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Foto escolhida',
                style: ControllerCommon.estiloTexto(
                    "normal negrito", Colors.blueAccent)),
            children: <Widget>[
              _image != null
                  ? Image(
                      image: FileImage(_image),
                      width: 100,
                      height: 100,
                    )
                  : Container(height: 100),
              Padding(padding: EdgeInsets.only(top: 10)),
              SimpleDialogOption(
                child: Text('Salvar nova foto',
                    style: ControllerCommon.estiloTexto(
                        "normal negrito", Colors.blueAccent)),
                onPressed: () async {
                  apertou++;

                  if (apertou < 2) {
                    //Mesmo se usuario apertar duas vezes, não salva duplicado
                    String urlImage = "none";
                    urlImage = await (ControllerCommon())
                        .uploadFile(_image, widget.produto.nome, "produtos");
                    while (urlImage == "none") {
                      await Future.delayed(Duration(seconds: 2), () {
                        //Faz função esperar um pouco para terminar de receber dados do forEach
                        return 'Dados recebidos...';
                      });
                    }
                    if (urlImage.contains("http")) {
                      await ctrProduto.atualizaDadosItem(
                          {"imagePath": urlImage},
                          "produto",
                          "id_produto",
                          widget.produto.id_produto);

                      await Future.delayed(Duration(seconds: 2), () {
                        //Faz função esperar um pouco para terminar de receber dados do forEach
                        return 'Dados recebidos...';
                      });
                      setState(() {
                        widget.produto.imagePath = urlImage;
                      });

                      Navigator.pop(context, "Salvar");
                    } else {
                      ElementosInterface.caixaDialogo(
                          "Não foi salvar a imagem. Tente novamente mais tarde.",
                          context);
                    }
                  }
                },
              ),
            ],
          );
        })) {
      case "Salvar":

        break;
      case "null":
        // dialog dismissed
        break;
    }
  }


  _concluirEdicao() async {
    String camposVazios = _validacao.validaCamposPreenchidos({
      "Descricao": _descricaoControl.text,
      "Unidade de medida": unidadeMedida,
      "Quantidade por pacote": _qtdPacoteControl.text,
      "Quantidade estoque": _qtdEstoqueControl.text,
      "Preço": _precoControl.text,
    });
    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
      Map<String, dynamic> prod = {
        "filtro": widget.produto.nome.toLowerCase().split(" "),
        "descricao": _descricaoControl.text,
        "unidadeMedida": unidadeMedida,
        "qtdPacote": _qtdPacoteControl.text.toString(),
        "qtdEstoque": int.parse(_qtdEstoqueControl.text.toString()),
        "preco": _precoControl.text,
      };

      var produtoAtualizado = await ctrProduto.atualizaDadosItem(
          prod, "produto", "id_produto", widget.produto.id_produto);

      Navigator.pop(context);
      try {
        Produto produto = produtoAtualizado;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TelaExibeProduto(produto, widget.usuario)));
      } catch (err) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TelaExibeProduto(widget.produto, widget.usuario)));
      }
    }
  }

  setaControllers() {
    print("setaControllers");
    categoria = widget.produto.categoria;
    unidadeMedida = widget.produto.unidadeMedida;

    _descricaoControl.text = widget.produto.descricao;
    _precoControl.text = widget.produto.preco;
    _unidadeControl.text = widget.produto.unidadeMedida;
    _qtdPacoteControl.text = widget.produto.qtdPacote.toString();
    _qtdEstoqueControl.text = widget.produto.qtdEstoque.toString();
  }

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
            //padding: EdgeInsets.all(32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Text("Edição do produto", //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTextoNegrito(25)),

              //Nome do produto
              Row(children: <Widget>[
                Text("Nome do produto:",
                    style: ControllerCommon.estiloTexto(
                        "normal negrito", Colors.black),
                    textAlign: TextAlign.left),
                Padding(padding: EdgeInsets.only(left: 10)),
                Flexible(
                  child: Text(
                    widget.produto.nome,
                    style: ControllerCommon.estiloTexto("normal", Colors.black),
                  ),
                ),
              ]),


              //Descrição do produto
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.text,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "Descrição do produto"),
                enabled: true,
                maxLines: 5,
                maxLengthEnforced: false,
                style: ControllerCommon.estiloTexto("normal", Colors.black),
                obscureText: false,

                controller: _descricaoControl,
              ),

              ///--------------------------------------------------------
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    //Define o campo de texto
                    keyboardType: TextInputType.number,
                    //Define  tipo de teclado
                    decoration: InputDecoration(
                        labelText: "Vendido a cada (quantidade em um pacote)"),
                    enabled: true,
                    //maxLength: 11,
                    maxLengthEnforced: false,
                    style: ControllerCommon.estiloTexto("normal", Colors.black),
                    obscureText: false,

                    controller: _qtdPacoteControl,
                  )),
                  DropdownButton<String>(
                    value: unidadeMedida,
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

              ///--------------------------------------------------------

              //Unidade de medida

              //Quantidade estoque
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.number,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "Quantidade estoque"),
                enabled: true,
                obscureText: false,

                //maxLength: 11,
                maxLengthEnforced: false,
                style: ControllerCommon.estiloTexto("normal", Colors.black),
                controller: _qtdEstoqueControl,
              ),

              //Preço
              TextField(
                //Define o campo de texto
                keyboardType: TextInputType.number,
                //Define  tipo de teclado
                decoration: InputDecoration(labelText: "Preço do produto"),
                enabled: true,

                style: ControllerCommon.estiloTexto("normal", Colors.black),
                obscureText: false,

                controller: _precoControl,
              ),

              Image(
                image: widget.produto.imagePath == ""
                    ? AssetImage("assets/images/sem-imagem.png")
                    : NetworkImage(widget.produto.imagePath),
                fit: BoxFit.fitHeight,
                //width: 350,
                height: 150,
              ),
              RaisedButton(
                  color: Colors.cyan,
                  child: Text(
                    "Alterar imagem",
                    style: ControllerCommon.estiloTexto(
                        "normal negrito", Colors.white),
                  ),
                  padding: EdgeInsets.all(15),
                  onPressed: () async {
                    chooseFile();
                  }),

              Padding(padding: EdgeInsets.only(top: 20)),
              //Botão cadastrar
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                RaisedButton(
                    color: Color.fromRGBO(34, 192, 149, 1),
                    child: Text(
                      "Concluir edição",
                      style: ControllerCommon.estiloTexto(
                          "normal negrito", Colors.white),
                    ),
                    padding: EdgeInsets.all(15),
                    onPressed: () {
                      _concluirEdicao();
                    })
              ]),
            ]),
          )),
      drawer: new NavDrawer(widget.usuario),
    );
  }
}

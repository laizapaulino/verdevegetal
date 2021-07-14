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
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/venda/TelaMinhaLoja.dart';

class TelaCadastroProduto extends StatefulWidget {
  Usuario usuario;

  TelaCadastroProduto(this.usuario);

  @override
  _TelaCadastroProdutoState createState() => _TelaCadastroProdutoState();
}

class _TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  TextEditingController _nomeProdutoControl = TextEditingController();
  TextEditingController _descricaoControl = TextEditingController();
  TextEditingController _precoControl = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.'); //after
  TextEditingController _unidadeControl = TextEditingController();
  TextEditingController _qtdTotalControl = TextEditingController();
  TextEditingController _qtdMinControl = TextEditingController();

  ValidacaoDados _validacao = ValidacaoDados();
  ControllerCategoria ctrCategoria = ControllerCategoria();
  ControllerUsuario _ctrUsuario = ControllerUsuario();


  String unidadeMedida = "g (gramas)";
  String categoria = "";
  File _image = null;
  Future<dynamic> _usuario;

  String _uploadedFileURL;

  _concluirCadastro(BuildContext context) async {
    String camposVazios = _validacao.validaCamposPreenchidos({
      "Nome": _nomeProdutoControl.text,
      "Descricao": _descricaoControl.text,
      "Unidade de medida": unidadeMedida,
      "Quantidade por pacote": _qtdMinControl.text,
      "Quantidade total": _qtdTotalControl.text,
      "Preço": _precoControl.text,
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

                      ),
                    ),
                  )
                ], // The content inside the dialog
              )));

      var now = DateTime.now();
      String dataAgora =
          "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}${now.hour.toString()}-${now.minute.toString()}";

      Produto produto = Produto(
          categoria == "" ? "Outros" : categoria,
          _descricaoControl.text,
          _nomeProdutoControl.text.split(" ")[0] + "_" + dataAgora,
          "",
          _nomeProdutoControl.text,
          widget.usuario.nome,
          _precoControl.text,
          int.parse(_qtdTotalControl.text),
          _qtdMinControl.text,
          "ativo",
          unidadeMedida,
          widget.usuario.username);

      ControllerProduto ctrProduto = ControllerProduto();
      String retorno = "none";
      retorno = await  ctrProduto.cadastraProduto(produto, _image);
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
                      if (snapshot.data["dadosVendedor"]["data"]
                              .getTemAoMenos1Metodo() ==
                          false) {
                        return Row(children: <Widget>[
                          Flexible(
                              child: RichText(
                                  text: TextSpan(


                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Por favor, acesse a área ',
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.black)),
                              new TextSpan(
                                  text: 'Meu perfil ',
                                  style: ControllerCommon.estiloTexto(
                                      "normal negrito", Colors.black)),
                              new TextSpan(
                                  text: 'e defina os métodos de pagamento',
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.black)),
                            ],
                          ))),
                        ]);
                      }

                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Cadastro de produto",
                                //textAlign: TextAlign.center,
                                style: ControllerCommon.estiloTexto(
                                    "titulo", Colors.black)),
                            Padding(padding: EdgeInsets.only(top: 20)),

                            //Nome do produto
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              decoration:
                                  InputDecoration(labelText: "Nome do produto"),
                              enabled: true,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.cyan),
                              obscureText: false,

                              onSubmitted: (String texto) {
                                //Quando fecha o teclado
                              },
                              controller: _nomeProdutoControl,
                            ),

                            FutureBuilder(
                              future: _categoriass,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data.length > 0) {
                                    List<String> lista = [""];
                                    snapshot.data.forEach((element) {
                                      if(element.toString().contains("Cesta")){}
                                      else {
                                        lista.add(element.toString());
                                      }
                                    });
                                    lista.removeAt(0);

                                    categoria =
                                        categoria == "" ? lista[0] : categoria;

                                    print(lista.toString());
                                    return Row(
                                      children: [
                                        Text("Categoria",
                                            style: ControllerCommon.estiloTexto(
                                                "normal negrito",
                                                Colors.black)),
                                        Padding(
                                            padding: EdgeInsets.only(left: 20)),
                                        DropdownButton<String>(
                                          value: categoria,
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
                                              categoria = newValue;
                                            });
                                          },
                                          items: lista
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: ControllerCommon
                                                      .estiloTexto("normal",
                                                          Colors.black)),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text("");
                                  }
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),

                            //Descrição do produto
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.text,
                              //Define  tipo de teclado
                              decoration: InputDecoration(
                                  labelText: "Descrição do produto"),
                              enabled: true,
                              maxLines: 5,
                              maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,

                              onSubmitted: (String texto) {
                                //Quando fecha o teclado
                                // print(texto);
                              },
                              controller: _descricaoControl,
                            ),
                            //Nome do produto

/************************************************************/
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
                                  maxLengthEnforced: false,
                                  style: ControllerCommon.estiloTexto(
                                      "normal", Colors.black),
                                  obscureText: false,

                                  controller: _qtdMinControl,
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
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black)),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
/************************************************************/


                            //Quantidade total
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.number,
                              //Define  tipo de teclado
                              decoration: InputDecoration(
                                  labelText: "Quantidade total de pacotes em estoque"),
                              enabled: true,
                              obscureText: false,

                              maxLengthEnforced: false,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),

                              controller: _qtdTotalControl,
                            ),

                            //Preço
                            TextField(
                              //Define o campo de texto
                              keyboardType: TextInputType.number,
                              //Define  tipo de teclado
                              decoration: InputDecoration(
                                  labelText: "Preço do produto (R\$)"),
                              enabled: true,

                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black),
                              obscureText: false,

                              controller: _precoControl,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                            ),

                            // ----------- IMAGEM ---------------------
                            Text(
                              'Imagem do produto',
                              style: ControllerCommon.estiloTexto(
                                  "normal negrito", Colors.black),
                            ),
                            _image != null
                                ? Image(
                                    image: FileImage(_image),
                                    width: 50,
                                    height: 50,
                                  )
                                : Container(height: 50),
                            RaisedButton(
                              child: Text('Escolha a imagem',
                                  style: ControllerCommon.estiloTexto(
                                      "normal negrito", Colors.white)),
                              onPressed: chooseFile,
                              color: Colors.cyan,
                            ),

                            //------------Imagem --------------

                            Padding(padding: EdgeInsets.only(top: 20)),
                            //Botão cadastrar
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RaisedButton(
                                      color: Color.fromRGBO(34, 192, 149, 1),
                                      child: Text(
                                        "Cadastrar",
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

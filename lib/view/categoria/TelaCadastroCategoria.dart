import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verde_vegetal_app/controllers/ControllerCategoria.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/Categoria.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';

class TelaCadastroCategoria extends StatefulWidget {
  @override
  _TelaCadastroCategoriaState createState() => _TelaCadastroCategoriaState();
}

TextEditingController _nomeControl = TextEditingController();
TextEditingController _descricaoControl = TextEditingController();
TextEditingController _imageControl = TextEditingController();

class _TelaCadastroCategoriaState extends State<TelaCadastroCategoria> {
  ElementosInterface _elementosInterface = new ElementosInterface();
  ValidacaoDados _validacao = ValidacaoDados();

  File _image;

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  _concluirCadastro(BuildContext context) {
    String camposVazios = _validacao.validaCamposPreenchidos({
      "Nome": _nomeControl.text,
      "Descricao": _descricaoControl.text,
    });
    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
      Categoria categoria =
          Categoria(_nomeControl.text, _descricaoControl.text, "");

      ControllerCategoria ctrCategoria = ControllerCategoria();
      ctrCategoria.cadastraCategoria(categoria, _image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              //padding: EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Cadastro de categoria",
                        //textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Dosis")),

                    //Campo Nome da Categoria
                    TextField(
                      //Define o campo de texto
                      keyboardType: TextInputType.text,
                      //Define  tipo de teclado
                      decoration: InputDecoration(labelText: "Nome"),
                      enabled: true,
                      maxLength: 8,
                      maxLengthEnforced: false,
                      style: TextStyle(fontSize: 15, color: Colors.cyan),
                      obscureText: false,

                      onSubmitted: (String texto) {
                        //Quando fecha o teclado
                        print(texto);
                      },
                      controller: _nomeControl,
                    ),
                    //Fim Nome da categoria

                    //Campo Descrição
                    TextField(
                      //Define o campo de texto
                      keyboardType: TextInputType.text,
                      //Define  tipo de teclado
                      decoration: InputDecoration(labelText: "Descrição"),
                      enabled: true,
                      maxLines: 5,
                      maxLengthEnforced: false,
                      style: TextStyle(fontSize: 15, color: Colors.cyan),
                      obscureText: false,

                      onSubmitted: (String texto) {
                        //Quando fecha o teclado
                        print(texto);
                      },
                      controller: _descricaoControl,
                    ),
                    // Fim Descrição

                    //Imagem

                    // ----------- IMAGEM ---------------------
                    Text('Imagem '),
                    _image != null
                        ? Image(
                            image: FileImage(_image),
                            width: 50,
                            height: 50,
                          )
                        : Container(height: 150),
                    _image == null
                        ? RaisedButton(
                            child: Text('Escolha a imagem'),
                            onPressed: chooseFile,
                            color: Colors.cyan,
                          )
                        : Container(),
                    _image != null
                        ? RaisedButton(
                            child: Text('Upload File'),
                            onPressed: () async {
                              // await _ctrCommon.uploadFile(
                              //     _image, widget.usuario.username);
                            },
                            color: Colors.cyan,
                          )
                        : Container(),
                    _image != null
                        ? RaisedButton(
                            child: Text('Clear Selection'),
                            // onPressed: clearSelection,
                          )
                        : Container(),
                    Text('Uploaded Image'),
                    _image != null ? Text(_image.path) : Container(),

                    //------------Imagem --------------

                    Padding(padding: EdgeInsets.only(top: 15)),

                    //Botão proximo
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      RaisedButton(
                          color: Color.fromRGBO(34, 192, 149, 1),
                          child: Text(
                            "Cadastrar",
                            style: TextStyle(
                                fontFamily: "HachiMaruPop",
                                color: Colors.white),
                          ),
                          padding: EdgeInsets.all(15),
                          onPressed: () {
                            _concluirCadastro(context);
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=> Tela2()
                              )
                          );*/
                          })
                    ])
                  ]),
            )
            //    )
            ));
  }
}

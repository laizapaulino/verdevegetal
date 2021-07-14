import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/usuario/TelaAlteraEndereco2.dart';
import 'package:verde_vegetal_app/view/venda/TelaMetodosPagamentoEdita.dart';
import 'package:verde_vegetal_app/view/venda/TelaValoresFreteEdicao.dart';

class TelaPerfilLogado extends StatefulWidget {
  @override
  _TelaPerfilLogadoState createState() => _TelaPerfilLogadoState();
}

class _TelaPerfilLogadoState extends State<TelaPerfilLogado> {
  ValidacaoDados _validacao = ValidacaoDados();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();
  ControllerCommon _ctrCommon = ControllerCommon();

  bool modoEdicao = false;
  Future<dynamic> _usuario;
  Color cor = Colors.black54;
  String nomeBotao = "Editar dados";
  Color corBotao = Colors.blueAccent;
  String username;
  TextEditingController _nomecontrol = TextEditingController();
  TextEditingController _emailcontrol = TextEditingController();
  TextEditingController telefone =
      new MaskedTextController(mask: "(00)00000000");

  TextEditingController _telefoneControl = TextEditingController();
  bool apertouSalvarFoto;
  Future<dynamic> _usua;
  File _image;
  String processei = "não";

  Future chooseFile() async {
    if (_image != null) {
      setState(() {
        _image.delete();
        _image = null;
      });
    }
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
    // _askedToLead(username);
  }

  salvaFoto(String username) async {
    String urlImage = "none";
    urlImage =
        await ControllerCommon().uploadFile(_image, username, "usuarios");
    while (urlImage == "none") {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }
    if (urlImage.contains("http")) {
      String retorno = "none";
      retorno = await _ctrUsuario
          .atualizaDadosBasicos({"imagePath": urlImage}, username);
      while (retorno == "") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      Navigator.pop(context, "Salvar");
      Navigator.pushNamed(context, "/meuperfil");
    } else {
      ElementosInterface.caixaDialogo(
          "Não foi possivel fazer a alteração de imagem. Tente novamente mais tarde.",
          context);
    }
  }

  void initState() {
    apertouSalvarFoto = false;
    _image = null;
    _usua = _ctrAutenticacao.recuperaLoginSalvo();

    _usuario = _ctrUsuario.recuperarDadosVisualizacaoPerfil();
    super.initState();
  }

  setaControllers(var dados) {
    // username = dados.username;
    _nomecontrol.text = dados["usuario"].nome;
    _emailcontrol.text = dados["usuario"].email;
    _telefoneControl.text = dados["usuario"].telefone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ElementosInterface.barra(context),
        body: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Meu perfil",
                    textAlign: TextAlign.start,
                    style:
                        ControllerCommon.estiloTexto("titulo", Colors.black)),
                Padding(padding: EdgeInsets.only(top: 20)),
                FutureBuilder(
                    future: _usuario,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        try {
                          print(snapshot.data.toString());
                          setaControllers(snapshot.data);
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _image == null
                                    ? FadeInImage(
                                        imageErrorBuilder:
                                            (BuildContext context,
                                                Object exception,
                                                StackTrace stackTrace) {
                                          print('Error Handler');
                                          return Icon(Icons.error);
                                        },
                                        placeholder: AssetImage(
                                            'assets/images/desfoque.png'),
                                        image: NetworkImage(
                                            snapshot.data["usuario"].imagePath),
                                        fit: BoxFit.cover,
                                        height: 150.0,
                                        width: 150.0,
                                      )
                                    : Image(
                                        image: FileImage(_image),
                                        width: 150,
                                        height: 150,
                                      ),

                                _image == null
                                    ? Text("")
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            RaisedButton(
                                                color: Colors.redAccent,
                                                child: Text(
                                                  "Cancelar",
                                                  style: ControllerCommon
                                                      .estiloTexto(
                                                          "normal negrito",
                                                          Colors.white),
                                                ),
                                                padding: EdgeInsets.all(15),
                                                onPressed:
                                                    apertouSalvarFoto == true
                                                        ? null
                                                        : () async {
                                                            setState(() {
                                                              _image = null;
                                                            });
                                                          }),
                                            RaisedButton(
                                                color: Colors.blue,
                                                child: Text(
                                                  "Salvar nova foto",
                                                  style: ControllerCommon
                                                      .estiloTexto(
                                                          "normal negrito",
                                                          Colors.white),
                                                ),
                                                padding: EdgeInsets.all(15),
                                                onPressed:
                                                    apertouSalvarFoto == true
                                                        ? null
                                                        : () async {
                                                            setState(() {
                                                              apertouSalvarFoto =
                                                                  true;
                                                            });
                                                            salvaFoto(snapshot
                                                                .data["usuario"]
                                                                .username);
                                                          }),
                                          ]),
                                Padding(padding: EdgeInsets.only(bottom: 5)),

                                RaisedButton(
                                    color: corBotao,
                                    child: Text(
                                      "Alterar foto",
                                      style: ControllerCommon.estiloTexto(
                                          "normal negrito", Colors.white),
                                    ),
                                    padding: EdgeInsets.all(15),
                                    onPressed: () async {
                                      chooseFile();
                                    }),

                                Row(children: <Widget>[
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Flexible(
                                    child: TextField(
                                      style: ControllerCommon.estiloTexto(
                                          "normal", cor),
                                      enabled: modoEdicao,
                                      controller: _nomecontrol,
                                    ),
                                  ),
                                ]),
                                Padding(padding: EdgeInsets.only(top: 30)),
                                Row(children: <Widget>[
                                  Text(
                                    snapshot.data["usuario"].cpf == ""
                                        ? "CNPJ: "
                                        : "CPF: ",
                                    style: ControllerCommon.estiloTexto(
                                        "normal",
                                        Color.fromRGBO(34, 192, 149, 1)),
                                  ),
                                  // Padding(padding: EdgeInsets.only(left: 10)),
                                  Flexible(
                                    child: Text(
                                      snapshot.data["usuario"].cpf == ""
                                          ? snapshot.data["usuario"].cnpj
                                          : snapshot.data["usuario"].cpf,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black),
                                    ),
                                  ),
                                ]),
                                // Padding(padding: EdgeInsets.only(top: 35)),
                                Divider(),
                                Row(children: <Widget>[
                                  Text(
                                    "E-mail:",
                                    style: ControllerCommon.estiloTexto(
                                        "normal",
                                        Color.fromRGBO(34, 192, 149, 1)),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Flexible(
                                    child: TextField(
                                      style: ControllerCommon.estiloTexto(
                                          "normal", cor),
                                      enabled: modoEdicao,
                                      controller: _emailcontrol,
                                      // decoration: new InputDecoration(
                                      //     hintText: snapshot.data["usuario"].email),
                                    ),
                                  ),
                                ]),
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Divider(),
                                Row(children: <Widget>[
                                  Text("Telefone:",
                                      style: ControllerCommon.estiloTexto(
                                          "normal",
                                          Color.fromRGBO(34, 192, 149, 1)),
                                      textAlign: TextAlign.left),
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Flexible(
                                    child: TextField(
                                      style: ControllerCommon.estiloTexto(
                                          "normal", cor),
                                      controller: _telefoneControl,
                                      enabled: modoEdicao,
                                      keyboardType: TextInputType.number,

                                      decoration: new InputDecoration(
                                          hintText: snapshot
                                              .data["usuario"].telefone),
                                    ),
                                  ),
                                ]),
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Divider(),
                                Row(children: <Widget>[
                                  Text("Tipo de conta:",
                                      style: ControllerCommon.estiloTexto(
                                          "normal",
                                          Color.fromRGBO(34, 192, 149, 1)),
                                      textAlign: TextAlign.left),
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Text(
                                      snapshot.data["usuario"].tipoConta
                                          .toString(),
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black),
                                      textAlign: TextAlign.left),
                                ]),

                                Padding(padding: EdgeInsets.only(top: 20)),
                                Divider(),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RaisedButton(
                                          color: corBotao,
                                          child: Text(
                                            nomeBotao,
                                            style: ControllerCommon.estiloTexto(
                                                "normal negrito", Colors.white),
                                          ),
                                          padding: EdgeInsets.all(15),
                                          onPressed: () async {
                                            String camposVazios = _validacao
                                                .validaCamposPreenchidos({
                                              "Nome": _nomecontrol.text,
                                              "E-mail": _emailcontrol.text,
                                              "Telefone": _telefoneControl.text,
                                            });
                                            if (nomeBotao == "Salvar dados") {
                                              Map<String, String> dados = {
                                                "nome": _nomecontrol.text,
                                                "email": _emailcontrol.text,
                                                "telefone":
                                                    _telefoneControl.text,
                                              };
                                              String retorno = "";
                                              retorno = await _ctrUsuario
                                                  .atualizaDadosBasicos(
                                                      dados,
                                                      snapshot.data["usuario"]
                                                          .username);
                                              while (retorno == "") {
                                                await Future.delayed(
                                                    Duration(seconds: 2), () {
                                                  //Faz função esperar um pouco para terminar de receber dados do forEach
                                                  return 'Dados recebidos...';
                                                });
                                              }
                                              print("Retorno");
                                              print(retorno);
                                              if (retorno == "true") {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                    context, "/meuperfil");
                                              }
                                            } else {
                                              setState(() {
                                                cor = Colors.black;
                                                nomeBotao = "Salvar dados";
                                                corBotao = Color.fromRGBO(
                                                    34, 192, 149, 1);
                                                modoEdicao = true;
                                              });
                                            }
                                          })
                                    ]),

                                Divider(
                                  color: Colors.black,
                                ),

                                snapshot.data["usuario"].tipoConta == "Vendedor"
                                    ? Column(
                                        children: [
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 10)),
                                          Text("Métodos de pagamento",
                                              style: ControllerCommon
                                                  .estiloTextoNegrito(15)),
                                          snapshot.data["dadosVendedor"]
                                                      ["data"] ==
                                                  null
                                              ? Text(
                                                  "Você ainda não cadastrou nenhum método",
                                                  style: ControllerCommon
                                                      .estiloTexto("normal",
                                                          Colors.black),
                                                )
                                              : snapshot.data["dadosVendedor"]
                                                              ["data"]
                                                          .getTemAoMenos1Metodo() ==
                                                      true
                                                  ? Column(children: [
                                                      Row(children: <Widget>[
                                                        Text(
                                                          "Na entrega:",
                                                          style: ControllerCommon
                                                              .estiloTexto(
                                                                  "normal",
                                                                  Color
                                                                      .fromRGBO(
                                                                          34,
                                                                          192,
                                                                          149,
                                                                          1)),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10)),
                                                        Flexible(
                                                            child: Text(
                                                                snapshot.data[
                                                                        "dadosVendedor"]
                                                                        ["data"]
                                                                    .getDadosPagamento(
                                                                        "entrega")
                                                                    .toString(),
                                                                style: ControllerCommon
                                                                    .estiloTexto(
                                                                        "normal",
                                                                        Colors
                                                                            .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left)),
                                                      ]),
                                                    ])
                                                  : Text(
                                                      "Você ainda não cadastrou nenhum método",
                                                      style: ControllerCommon
                                                          .estiloTexto("normal",
                                                              Colors.black),
                                                    ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 10)),
                                          //BOTAO ALTERA METODO
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              RaisedButton(
                                                  color: Colors.blueAccent,
                                                  child: Text(
                                                    "Alterar métodos pagamento",
                                                    style: ControllerCommon
                                                        .estiloTexto(
                                                            "normal negrito",
                                                            Colors.white),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                TelaMetodosPagamento2(snapshot
                                                                    .data[
                                                                        "usuario"]
                                                                    .username)));
                                                  })
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.black,
                                          ),
                                          Text(
                                              "Localidades que seu frete atende",
                                              style: ControllerCommon
                                                  .estiloTextoNegrito(15)),

                                          Text(
                                              snapshot
                                                          .data["freteVendedor"]
                                                              ["data"]
                                                          .runtimeType ==
                                                      FreteVendedor
                                                  ? snapshot
                                                      .data["freteVendedor"]
                                                          ["data"]
                                                      .getLocalidadeFormatada()
                                                  : "",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal", Colors.black)),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              RaisedButton(
                                                  color: Colors.blueAccent,
                                                  child: Text(
                                                    "Alterar/adicionar localidades",
                                                    style: ControllerCommon
                                                        .estiloTexto(
                                                            "normal negrito",
                                                            Colors.white),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  onPressed: () async {
                                                    // Map a = {};a.containsKey("localidades");
                                                    Navigator.pop(context);
                                                    if (snapshot.data[
                                                                "freteVendedor"]
                                                            ["message"] ==
                                                        "sucesso") {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => TelaValoresFreteEdicao(
                                                                  snapshot
                                                                      .data[
                                                                          "usuario"]
                                                                      .username,
                                                                  snapshot.data[
                                                                          "freteVendedor"]
                                                                      [
                                                                      "data"])));
                                                    } else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => TelaValoresFreteEdicao(
                                                                  snapshot.data["usuario"].username,
                                                                  FreteVendedor(snapshot.data["usuario"].username, {})
                                                              )));
                                                    }
                                                  })
                                            ],
                                          ),

                                          Divider(
                                            color: Colors.black,
                                          ),
                                        ],
                                      )
                                    : Text(""),
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      snapshot.data["usuario"].tipoConta ==
                                              "Consumidor"
                                          ? RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: Color.fromRGBO(
                                                          34, 192, 149, 1))),
                                              color: Colors.white,
                                              //color: Color.fromRGBO(34, 192, 149, 1),
                                              child: Text(
                                                "Tornar perfil vendedor",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        "normal negrito",
                                                        Color.fromRGBO(
                                                            34, 192, 149, 1)),
                                              ),
                                              padding: EdgeInsets.all(15),
                                              onPressed: () async {
                                                String retorno = "";
                                                retorno = await _ctrUsuario
                                                    .atualizaDadosBasicos(
                                                        {
                                                      "tipoConta": "Vendedor"
                                                    },
                                                        snapshot.data["usuario"]
                                                            .username);
                                                while (retorno == "") {
                                                  await Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    //Faz função esperar um pouco para terminar de receber dados do forEach
                                                    return 'Dados recebidos...';
                                                  });
                                                }
                                                if (retorno == "true") {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, "/meuperfil");
                                                } else {
                                                  ElementosInterface.caixaDialogo(
                                                      "Não foi possivel atualizar seus dados no momento",
                                                      context);
                                                }
                                              })
                                          : Divider()
                                    ]),
                                Row(children: <Widget>[
                                  Text("Endereço:",
                                      style: ControllerCommon.estiloTexto(
                                          "normal",
                                          Color.fromRGBO(34, 192, 149, 1)),
                                      textAlign: TextAlign.left),
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Flexible(
                                    child: Text(
                                        snapshot.data["usuario"].getEndereco(),
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black),
                                        textAlign: TextAlign.left),
                                  )
                                ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RaisedButton(
                                          color: Colors.deepOrange,
                                          child: Text(
                                            "Alterar endereço",
                                            style: ControllerCommon.estiloTexto(
                                                "normal negrito", Colors.white),
                                          ),
                                          padding: EdgeInsets.all(15),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TelaAlteraEndereco2()));
                                          })
                                    ]),
                              ]);
                        } catch (err) {
                          return Text(
                              "Não consegui recuperar seus dados :(\n${err}");
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ],
            ))),
        drawer: FutureBuilder(
            future: _usua,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.runtimeType == Usuario)
                  return NavDrawer(snapshot.data);
                else {
                  return NavDrawer(null);
                }
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

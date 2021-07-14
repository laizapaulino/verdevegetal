import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeProduto.dart';

class TelaPerfilPublico extends StatefulWidget {
  String username;

  TelaPerfilPublico(this.username);

  @override
  _TelaPerfilPublicoState createState() => _TelaPerfilPublicoState();
}

class _TelaPerfilPublicoState extends State<TelaPerfilPublico> {
  ElementosInterface _elementosInterface = new ElementosInterface();
  Future<dynamic> _usuario;
  Future<List> _produtos;
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();
  ControllerProduto _ctrProduto = ControllerProduto();
  ScrollController _controller = new ScrollController();

  _verProduto(Produto produto) async {
    var usu = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      Usuario user = usu;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, user)));
    } catch (err) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, null)));
    }
  }

  void initState() {
    _usuario =
        _ctrUsuario.recuperarDadosVisualizacaoPerfilPublico(widget.username);
    _produtos =
        _ctrProduto.recuperaTodosItensVendedorPorUsername("perfil publico", widget.username, 10);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                FutureBuilder(
                    future: _usuario,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Image(
                                  image: snapshot.data["usuario"].imagePath ==
                                          ""
                                      ? AssetImage('assets/images/user.png')
                                      : NetworkImage(
                                          snapshot.data["usuario"].imagePath),
                                  width: 70, height: 70,
                                  // width: MediaQuery.of(context).size.height*0.50, height: MediaQuery.of(context).size.height*0.50,
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Text(
                                  "${snapshot.data["usuario"].nome}",
                                  style: ControllerCommon.estiloTextoNormal(20),
                                ),
                              ]),

                              Divider(),
                              Row(children: <Widget>[
                                Text(
                                  "Endereço: ",
                                  style: ControllerCommon.estiloTexto(
                                      "normal negrito",
                                      Color.fromRGBO(34, 192, 149, 1)),
                                ),
                                Padding(padding: EdgeInsets.only(left: 7)),
                                Flexible(
                                  child: Text(
                                      "${snapshot.data["usuario"].getEnderecoDiscreto()}",
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black)),
                                ),
                              ]),
                              Divider(),

                              Row(children: <Widget>[
                                Text("Usuario:",
                                    style: ControllerCommon.estiloTexto(
                                        "normal negrito",
                                        Color.fromRGBO(34, 192, 149, 1)),
                                    textAlign: TextAlign.left),
                                Padding(padding: EdgeInsets.only(left: 7)),
                                Text("${snapshot.data["usuario"].tipoConta}",
                                    style: ControllerCommon.estiloTexto(
                                        "normal", Colors.black),
                                    textAlign: TextAlign.left),
                              ]),
                              Divider(),
                              // Column(children: <Widget>[
                                Text("Entrega em:",
                                    style: ControllerCommon.estiloTexto(
                                        "normal negrito",
                                        Colors.black),
                                    textAlign: TextAlign.left),
                                // Padding(padding: EdgeInsets.only(left: 7)),
                                // Flexible(
                                //   child:
                      snapshot.data["freteVendedor"]["data"].runtimeType == FreteVendedor?
                      Row(children:[Flexible(child:Text(
                                      "${snapshot.data["freteVendedor"]["data"].getLocalidadeFormatada()}",
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black)))]):Text("-"),
                                // ),
                              // ]),
                              Divider(),
                              Text("Métodos de pagamento",
                                  style:
                                      ControllerCommon.estiloTextoNegrito(15)),
                              snapshot.data["dadosVendedor"]["data"] == null
                                  ? Text("")
                                  : snapshot.data["dadosVendedor"]["data"]
                                              .getDadosPagamento("entrega") ==
                                          "Não permitido"
                                      ? Text("-")
                                      :
                              Row(children:[Flexible(child:
                              Text(
                                          "Na entrega: " +
                                              snapshot.data["dadosVendedor"]
                                                      ["data"]
                                                  .getDadosPagamento("entrega"),
                                          style: ControllerCommon.estiloTexto(
                                              "normal", Colors.black),
                                        ))]),
                                Divider()

                            ]);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                FutureBuilder(
                    future: _produtos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data.length == 0) {
                          return Text(
                              "Não existem produtos disponiveis no momento");
                        }

                        return Column(children: [
                          ElementosInterface.criaListTile(context, snapshot.data)
                        ]);
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ])),
          //drawer: new NavDrawer(false),
        ));
  }
}

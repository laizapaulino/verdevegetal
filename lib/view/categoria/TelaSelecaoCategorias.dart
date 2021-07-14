import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCategoria.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/categoria/TelaProdutoPorCategoria.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaSelecaoCategorias extends StatefulWidget {
  @override
  _TelaSelecaoCategoriasState createState() => _TelaSelecaoCategoriasState();
}

ElementosInterface elementosInterface = new ElementosInterface();

class _TelaSelecaoCategoriasState extends State<TelaSelecaoCategorias> {
  ControllerCategoria ctrCategoria = ControllerCategoria();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  ScrollController _controller = new ScrollController();

  Future<dynamic> _usuario;
  Future<List> _categoriass;

  buscaProdutosCategoria(String categoriaEscolhida) async {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TelaProdutosPorCategoria(categoriaEscolhida)));
    } catch (err) {}
  }

  @override
  void initState() {
    _categoriass = ctrCategoria.recuperaCategoriaComboBox();
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();

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
              Text("Categoria",
                  //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTexto("titulo", Colors.black)),
              Padding(padding: EdgeInsets.only(top: 20)),
                  Row(children: [
                    Flexible(
                        child: Text(
                            "Selecione uma categoria para ver os produtos disponiveis.",
                            //textAlign: TextAlign.center,
                            style: ControllerCommon.estiloTexto(
                                "normal", Colors.black))),
                  ]),
              FutureBuilder(
                  future: _categoriass,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<Widget> lista = [];

                      snapshot.data.forEach((value) {
                        lista.add(
                        InkWell(
                            highlightColor: Colors.greenAccent,
                            hoverColor: Colors.greenAccent,
                            focusColor: Colors.greenAccent,
                            onTap: () {
                              buscaProdutosCategoria(value);
                            }, // child: Card(
                            child: Container(

                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child:

                                Column(
                                  children: [

                                    Text("${value}",
                                        style: ControllerCommon.estiloTexto(
                                            "normal negrito",
                                            Colors.black)),
                                    Divider(
                                      color: Colors.indigo,
                                    ),
                                  ],
                                ))));

                      });

                      return Column(children: lista,);
                        ListView.builder(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          controller: _controller,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, indice) {
                            // print("item ${_categorias[indice].toString()}");

                            return InkWell(
                                highlightColor: Colors.cyan,
                                hoverColor: Colors.cyan,
                                onTap: () {
                                  buscaProdutosCategoria(snapshot.data[indice]);
                                }, // child: Card(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    child:

                                    Column(
                                      children: [

                                        Text("${snapshot.data[indice]}",
                                            style: ControllerCommon.estiloTexto(
                                                "normal negrito",
                                                Colors.black)),
                                        Divider(
                                          color: Colors.indigo,
                                        ),
                                      ],
                                    )));

                            return Card(
                                child: ListTile(
                              onTap: () {
                                buscaProdutosCategoria(snapshot.data[indice]);
                              },
                              onLongPress: () {},
                              title: Text("${snapshot.data[indice]}"),
                            ));
                          });
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),

              //Imagem

              Padding(padding: EdgeInsets.only(top: 15)),
            ]),
          )
          //    )
          ),
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
          }),
    );
  }
}

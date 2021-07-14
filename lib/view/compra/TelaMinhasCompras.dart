import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerVendas.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/compra/TelaDetalheCompra2.dart';

class TelaMinhasCompras extends StatefulWidget {
  @override
  _TelaMinhasComprasState createState() => _TelaMinhasComprasState();
}

class _TelaMinhasComprasState extends State<TelaMinhasCompras> {
  ScrollController _controller = new ScrollController();
  ElementosInterface _elementosInterface = new ElementosInterface();
  ControllerVenda _ctrVenda = ControllerVenda();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

  Future<Map> _compras;
  Future<dynamic> _usuario;

  void initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _compras = _ctrVenda.recuperaCompraPorData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Popula o array de categorias
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
          padding: EdgeInsets.all(20),
          //padding: EdgeInsets.all(32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Text("Meus pedidos",
                //textAlign: TextAlign.center,
                style: ControllerCommon
                    .estiloTexto("titulo", Colors.black)),
            FutureBuilder(
                future: _compras,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    print(snapshot.data["compras"].toString());

                    if (snapshot.data["compras"].length == 0) {
                      return Text("Você ainda não fez nenhuma compra");
                    }

                    return Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            controller: _controller,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data["compras"].length,
                            itemBuilder: (context, indice) {
                              DateTime now =
                                  new DateTime.fromMicrosecondsSinceEpoch(
                                      snapshot
                                          .data["compras"][indice]["dataCompra"]
                                          .microsecondsSinceEpoch);
// Timestamp.now()

                              String dataCompra =
                                  ("${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString()} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}");
                              return InkWell(
                                  highlightColor: Colors.cyan,
                                  hoverColor: Colors.cyan,
                                  onTap: () {

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TelaDetalheCompra2(
                                                  snapshot.data["compras"]
                                                  [indice]
                                                  ["idCompra"],
                                                  dataCompra,
                                                  snapshot.data["compras"]
                                                  [indice]
                                                  ["qtdProdutosComprados"],
                                                  snapshot.data["compras"]
                                                  [indice]
                                                  ["qtdProdutosCancelados"],
                                                  snapshot.data["compras"]
                                                  [indice]
                                                  ["status"],
                                                  snapshot.data["compras"]
                                                  [indice]
                                                  ["previsaoEntrega"],
                                                    snapshot.data["compras"]
                                                    [indice]
                                                    ["usernameVendedor"],
                                                    snapshot.data["compras"]
                                                    [indice]["valorFrete"]
                                                )));
                                  }, // child: Card(
                                  child: Card(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Column(
                                        children: <Widget>[
                                          Align(
                                            child: Row(children: <Widget>[
                                              Icon(
                                                Icons.shopping_cart_rounded,
                                                color: snapshot.data["compras"]
                                                            [indice]["status"]
                                                        .contains("Cancelado")
                                                    ? Colors.red
                                                    : snapshot.data["compras"]
                                                                [indice]
                                                                ["status"]
                                                            .contains(
                                                                "finalizada")
                                                        ? Colors.indigo
                                                        : Colors.green,
                                                size: 30,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10)),
                                              Flexible(
                                                  child: Text(
                                                "Compra realizada: ${dataCompra}",
                                                style: ControllerCommon
                                                    .estiloTexto(
                                                        "titulo 2 negrito",
                                                        Colors.black),
                                              ))
                                            ]),
                                            //so big text
                                            alignment: FractionalOffset.topLeft,
                                          ),
                                          Divider(
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            "Vendedor: ${snapshot
                                                .data["dadosVendedor"][snapshot.data["compras"]
                                            [indice]
                                            ["usernameVendedor"]]
                                            }",
                                            style: ControllerCommon
                                                .estiloTexto(
                                                "normal",
                                                Colors.black),
                                          )

                                        ],
                                      ),
                                    ),
                                  ));
                            }));
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ])

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

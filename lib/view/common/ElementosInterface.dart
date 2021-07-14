import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/model/CestaCarrinho.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';
import 'package:verde_vegetal_app/view/common/funcoesComumWidget.dart';
import 'package:verde_vegetal_app/view/produto/TelaTodosProdutosVendedor.dart';

class ElementosInterface {
  NumberFormat formatter = NumberFormat("0.00");

  static AppBar barra(BuildContext context) {
    return AppBar(
      title: Text(
        "Verde Vegetal",
        style: TextStyle(fontFamily: "HachiMaruPop"),
      ),
      backgroundColor: Color.fromRGBO(34, 192, 149, 1),
      actions: [
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, "/pesquisa");
            }),
        IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, "/carrinhoCompras");
            }),
      ],
    );
  }

  static SnackBar customSnackBar({String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static caixaDialogo(String aviso, BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(aviso,
              style: ControllerCommon.estiloTexto('normal', Colors.black)),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> caixaDialogoSimNao(
      String aviso, BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(aviso,
              style: ControllerCommon.estiloTexto('normal', Colors.black)),
          actions: <Widget>[
            // define os botões na base do dialogo
            FlatButton(
              child: Text("Sim"),
              onPressed: () {
                Navigator.pop(context, true);

                // Navigator.of(context, true).pop();
              },
            ),
            FlatButton(
              child: Text("Não"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  childrenCardVenda(var p) {
    NumberFormat formatter = NumberFormat("0.00");

    String produtosCesta = "";
    if (p.containsKey("produtos")) {
      p["produtos"].forEach((key, value) {
        produtosCesta += produtosCesta == "" ? "" : ",";
        produtosCesta += " " +
            value["nomeProduto"] +
            " - " +
            value["qtdPacote"] +
            value['unidadeMedida'];
      });
    }

    return Column(
      children: <Widget>[
        Align(
          child: Row(children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 10)),
            Flexible(
                child: Text(
              "${p["nome"]} ",
              style: ControllerCommon.estiloTexto(
                  'titulo 2 negrito', Colors.black),
            )),
          ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            p["status"],
            style: ControllerCommon.estiloTexto(
                'normal negrito',
                p["status"].toString().contains("Cancelado")
                    ? Colors.redAccent
                    : p["status"].toString().contains("Preparando")
                        ? Colors.green
                        : Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Row(
          children: [
            Flexible(
                child: Text(
              "Pagamento: ${p["metodoPagamento"]}",
              style: ControllerCommon.estiloTexto('normal', Colors.black),
            ))
          ],
        ),
        Divider(
          color: Colors.blue,
        ),
        Row(children: [
          Flexible(
            child: Text(
              "Nome comprador: ${p["nomeComprador"]}",
              style: ControllerCommon.estiloTexto('normal', Colors.black),
            ),
          )
        ]),
        Divider(
          color: Colors.blue,
        ),
        Row(children: [
          Flexible(
            child: Text(
              p.containsKey("unidadeMedida")
                  ? "${p["qtdPacote"]} ${p["unidadeMedida"]} - "
                  : "" + "Pacotes comprados: ${p["quantidade"]}",
              style: ControllerCommon.estiloTexto('normal', Colors.black),
            ),
          )
        ]),
        Row(children: [
          Flexible(
            child: Text(
              "Valor total: R\$${formatter.format(double.parse(p["precoUnitario"].replaceAll(",", ".")) * p["quantidade"])} ",
              style: ControllerCommon.estiloTexto('normal', Colors.black),
            ),
          )
        ]),
        Divider(
          color: Colors.blue,
        ),
        Text(
          "${produtosCesta}",
          style: ControllerCommon.estiloTexto("normal", Colors.black),
        ),
        Divider(
          color: Colors.indigo,
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              child: Text(
                "Entregar em: ${p["enderecoComprador"]}",
                style: ControllerCommon.estiloTexto('normal', Colors.black),
              ),
            ),
          ],
        )
      ],
    );
  }

  childrenCardProdutoCesta(var p) {
    NumberFormat formatter = NumberFormat("0.00");

    return Column(
      children: <Widget>[
        Align(
          child: Row(children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 10)),
            Text(
              "${p.nome}",
              style: ControllerCommon.estiloTexto(
                  'titulo 2 negrito', Colors.black),
            ),
          ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            p["status"],
            style: ControllerCommon.estiloTexto(
                'normal negrito',
                p["status"].toString().contains("Cancelado")
                    ? Colors.redAccent
                    : p["status"].toString().contains("Preparando")
                        ? Colors.green
                        : Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Align(
          child: Text(
            "Pagamento: ${p["metodoPagamento"]}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            "Nome comprador: ${p["nomeComprador"]}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            "${p["qtdPacote"]} ${p["unidadeMedida"]} - Pacotes comprados: ${p["quantidade"]}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Align(
          child: Text(
            "Valor total: R\$${formatter.format(double.parse(p["precoUnitario"].replaceAll(",", ".")) * p.quantidade)} ",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              child: Text(
                "Entregar em: ${p.enderecoComprador}",
                style: ControllerCommon.estiloTexto('normal', Colors.black),
              ),
            ),
          ],
        )
      ],
    );
  }

  childrenCardFrete(String cidade, String bairro, String preco) {
    NumberFormat formatter = NumberFormat("0.00");

    return Column(
      children: <Widget>[
        Align(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 10)),
                Flexible(
                  child: Text(
                    "${cidade} - ${bairro}: R\$ ${preco}",
                    style: ControllerCommon.estiloTexto(
                        'normal negrito', Colors.black),
                  ),
                ),
                Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                )
              ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
      ],
    );
  }

  childrenCardProdutoX(Produto p) {
    return Column(
      children: <Widget>[
        Align(
          child: Row(children: <Widget>[
            FadeInImage(
              imageErrorBuilder: (BuildContext context, Object exception,
                  StackTrace stackTrace) {
                print('Error Handler');
                return Icon(Icons.error);
              },
              placeholder: AssetImage('assets/images/desfoque.png'),
              image: NetworkImage(p.imagePath),
              fit: BoxFit.cover,
              height: 70.0,
              width: 70.0,
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Flexible(
                child: Text(
              p.nome,
              style: ControllerCommon.estiloTexto(
                  'titulo 2 negrito', Colors.black),
            )),
          ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(
            "Vendido por: ${p.nomeVendedor}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          )
        ]),
        Divider(
          color: Colors.blue,
        ),
        Row(children: [
          Flexible(
              child: Text(
            "${p.qtdPacote} ${p.unidadeMedida} - R\$${p.preco}",
            style: ControllerCommon.estiloTexto('normal negrito', Colors.black),
          )),
        ]),
      ],
    );
  }

  childrenCardCesta(var p) {
    print("childrenCardCesta");
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          p["imagePath"] != null && p["imagePath"] != ""
              ? FadeInImage(
                  imageErrorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                    print('Error Handler');
                    return Icon(Icons.error);
                  },
                  placeholder: AssetImage('assets/images/desfoque.png'),
                  image: NetworkImage(p["imagePath"]),
                  fit: BoxFit.cover,
                  height: 70.0,
                  width: 70.0,
                )
              : Image(
                  image: AssetImage('assets/images/cesta.png'),
                  width: 70,
                  height: 70,
                ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Flexible(
              child: Text(
            "${p["nome"]}",
            style:
                ControllerCommon.estiloTexto('titulo 2 negrito', Colors.black),
          )),
        ]),
        Divider(
          color: Colors.blue,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Flexible(
              child: Text(
            "Vendido por: ${p["nomeVendedor"]}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          )),
        ]),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            "R\$ ${p["preco"]} cada",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
      ],
    );
  }

  childrenCardPreVenda(ProdutoCarrinho p, String frete) {
    double valorcomFrete = double.parse(p.precoTotal.replaceAll(",", ".")) +
        double.parse(frete.replaceAll(",", "."));
    return Column(
      children: <Widget>[
        Align(
          child: Row(children: <Widget>[
            FadeInImage(
              imageErrorBuilder: (BuildContext context, Object exception,
                  StackTrace stackTrace) {
                print('Error Handler');
                return Icon(Icons.error);
              },
              placeholder: AssetImage('assets/images/desfoque.png'),
              image: NetworkImage(p.imagePath),
              fit: BoxFit.cover,
              height: 50.0,
              width: 50.0,
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Text(
              p.nome,
              style: ControllerCommon.estiloTexto(
                  'titulo 2 negrito', Colors.black),
            ),
          ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            "Cada pacote contém ${p.qtdPacote} ${p.unidadeMedida} - R\$${p.precoUnitario}",
            style: ControllerCommon.estiloTexto('normal', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
        Align(
          child: Text(
            "Quantidade: ${p.quantidade}\nValor total: R\$ "
                // "${formatter.format(valorcomFrete).replaceAll(".", ",")}"
                +
                p.precoTotal,
            style: ControllerCommon.estiloTexto('normal negrito', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
      ],
    );
  }

  static childrenFormataTextSpan(Map produtos) {
    List<TextSpan> listTextSpan = [];

    produtos.forEach((key, value) {
      listTextSpan.add(new TextSpan(
          text: '${value["nomeProduto"]}\n',
          style: ControllerCommon.estiloTexto("normal negrito", Colors.black)));
      listTextSpan.add(new TextSpan(
          text: '${value["qtdPacote"]} ${value["unidadeMedida"]}\n',
          style: ControllerCommon.estiloTexto("normal", Colors.black)));
    });

    return RichText(
        text: TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: new TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: listTextSpan,
    ));
  }

  static criaListTile(BuildContext context, var dados) {
    //Esse metodo foi criado para melhorar a visualização de um widget que continha listview builder
    List<Widget> itens = [];
    for (int indice = 0; indice < dados.length; indice++) {
      if (indice == dados.length - 1 && dados.length > 2) {
        itens.add(ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaTodosProdutosVendedor(
                          dados[indice]["usernameVendedor"],
                          dados[indice]["nomeVendedor"])));
            },
            child: Text(
              "Ver mais",
              style:
                  ControllerCommon.estiloTexto("normal negrito", Colors.white),
            )));
      } else if (dados[indice]["categoria"] == "Cesta") {
        itens.add(InkWell(
            highlightColor: Colors.cyan,
            hoverColor: Colors.cyan,
            onTap: () {
              funcoesComumWidget.verCesta(dados[indice], context);
            }, // child: Card(
            child: Container(
              color: dados[indice]["status"] == "ativo"
                  ? Colors.white
                  : Colors.black12,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(children: [
                Text(
                  "Produto: ${dados[indice]["status"]}",
                  style: ControllerCommon.estiloTexto("normal", Colors.black),
                ),
                ElementosInterface().childrenCardCesta(dados[indice])
              ]),
            )));
      } else {
        Produto p = Produto(
            dados[indice]["categoria"],
            dados[indice]["descricao"],
            dados[indice]["id_produto"],
            dados[indice]["imagePath"],
            dados[indice]["nome"],
            dados[indice]["nomeVendedor"],
            dados[indice]["preco"],
            dados[indice]["qtdEstoque"],
            dados[indice]["qtdPacote"],
            dados[indice]["status"],
            dados[indice]["unidadeMedida"],
            dados[indice]["usernameVendedor"]);

        itens.add(InkWell(
            highlightColor: Colors.cyan,
            hoverColor: Colors.cyan,
            onTap: () {
              // dados[indice];
              funcoesComumWidget.verProduto(p, context);
            }, // child: Card(
            child: Container(
              color: dados[indice]["status"] == "ativo"
                  ? Colors.white
                  : Colors.black12,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(children: [
                Text(
                  "Produto: ${dados[indice]["status"]}",
                  style: ControllerCommon.estiloTexto("normal", Colors.black),
                ),
                ElementosInterface().childrenCardProdutoX(p)
              ]),
            )));
      }
    }

    return Column(children: itens);
  }

  childrenCardCestaPreVenda(CestaCarrinho p, String frete) {
    // double valorcomFrete = double.parse(p.precoTotal.replaceAll(",", ".")) +
    //     double.parse(frete.replaceAll(",", "."));
    return Column(
      children: <Widget>[
        Align(
          child: Row(children: <Widget>[
            p.imagePath != ""
                ? FadeInImage(
                    imageErrorBuilder: (BuildContext context, Object exception,
                        StackTrace stackTrace) {
                      print('Error Handler');
                      return Icon(Icons.error);
                    },
                    placeholder: AssetImage('assets/images/desfoque.png'),
                    image: NetworkImage(p.imagePath),
                    fit: BoxFit.cover,
                    height: 50.0,
                    width: 50.0,
                  )
                : Image(
                    image: AssetImage('assets/images/cesta.png'),
                    width: 50,
                    height: 50,
                  ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Text(
              p.nome,
              style: ControllerCommon.estiloTexto(
                  'titulo 2 negrito', Colors.black),
            ),
          ]),
          //so big text
          alignment: FractionalOffset.topLeft,
        ),
        Divider(
          color: Colors.blue,
        ),
        Align(
          child: Text(
            "Quantidade: ${p.quantidade}\nValor total: "
                    "R\$"
                // "${formatter.format(valorcomFrete).replaceAll(".", ",")}"
                +
                p.precoTotal,
            style: ControllerCommon.estiloTexto('normal negrito', Colors.black),
          ),
          alignment: FractionalOffset.topLeft,
        ),
      ],
    );
  }

  ListViwerAninhadoResumoCompra(List listaPorMetodo) {
    List<Widget> itens = [];
    for (int indice = 0; indice < listaPorMetodo.length; indice++) {
      double valorcomFrete = listaPorMetodo[indice]["valorTotal"] +
          double.parse(listaPorMetodo[indice]["frete"].replaceAll(",", "."));
      List<Widget> produtoDentro = [];

      for (int indice2 = 0;
          indice2 < listaPorMetodo[indice]["produtos"].length;
          indice2++) {
        produtoDentro.add(Padding(
          padding: EdgeInsets.all(1),
          child: Row(
            children: [
              Flexible(
                child: Text(
                    "${listaPorMetodo[indice]["produtos"][indice2].nome} - Quantidade: ${listaPorMetodo[indice]["produtos"][indice2].quantidade} - Preço: R\$ ${formatter.format(double.parse(listaPorMetodo[indice]["produtos"][indice2].precoTotal.replaceAll(",", "."))).replaceAll(".", ",")}",
                    style:
                        ControllerCommon.estiloTexto("normal", Colors.black)),
              )
            ],
          ),
        ));
      }
      itens.add(Padding(
          padding: EdgeInsets.only(top: 20),
          child: Card(
            shadowColor: Colors.cyan,
            child: Column(
              children: [
                Text(
                  listaPorMetodo[indice]["produtos"][0].nomeVendedor,
                  style: ControllerCommon.estiloTextoNegrito(17),
                ),
                Divider(
                  color: Colors.black,
                ),
                Row(
                  children: [
                    Text(
                      "Frete: ",
                      style: ControllerCommon.estiloTextoNegrito(15),
                    ),
                    Text(
                      "${listaPorMetodo[indice]["frete"]}",
                      style: ControllerCommon.estiloTextoNormal(15),
                    ),
                  ],
                ),

                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: ClampingScrollPhysics(),
                //   itemCount: listaPorMetodo[indice]["produtos"].length,
                //   itemBuilder: (context2, indice2) {
                //     return Text(
                //         "${listaPorMetodo[indice]["produtos"][indice2].nome} - Quantidade: ${listaPorMetodo[indice]["produtos"][indice2].quantidade} - Preço: R\$ ${formatter.format(double.parse(listaPorMetodo[indice]["produtos"][indice2].precoTotal.replaceAll(",", "."))).replaceAll(".", ",")}",
                //         style: ControllerCommon.estiloTexto(
                //             "normal", Colors.black));
                //   },
                // ),

                Column(children: produtoDentro),
                Divider(
                  color: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("R\$ " + formatter.format(valorcomFrete),
                        style: ControllerCommon.estiloTexto(
                            "normal negrito", Colors.black))
                  ],
                ),
              ],
            ),
          )));
    }

    return Column(children: itens);

    return ListView.builder(
      itemCount: listaPorMetodo.length,
      itemBuilder: (context, indice) {
        double valorcomFrete = listaPorMetodo[indice]["valorTotal"] +
            double.parse(listaPorMetodo[indice]["frete"].replaceAll(",", "."));
        return Padding(
            padding: EdgeInsets.only(top: 20),
            child: Card(
              shadowColor: Colors.cyan,
              child: Column(
                children: [
                  Text(
                    listaPorMetodo[indice]["produtos"][0].nomeVendedor,
                    style: ControllerCommon.estiloTextoNegrito(17),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      Text(
                        "Frete: ",
                        style: ControllerCommon.estiloTextoNegrito(15),
                      ),
                      Text(
                        "${listaPorMetodo[indice]["frete"]}",
                        style: ControllerCommon.estiloTextoNormal(15),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: listaPorMetodo[indice]["produtos"].length,
                    itemBuilder: (context2, indice2) {
                      return Text(
                          "${listaPorMetodo[indice]["produtos"][indice2].nome} - Quantidade: ${listaPorMetodo[indice]["produtos"][indice2].quantidade} - Preço: R\$ ${formatter.format(double.parse(listaPorMetodo[indice]["produtos"][indice2].precoTotal.replaceAll(",", "."))).replaceAll(".", ",")}",
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black));
                    },
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("R\$ " + formatter.format(valorcomFrete),
                          style: ControllerCommon.estiloTexto(
                              "normal negrito", Colors.black))
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  ListViwerAninhadoItemCompra(List listaPorMetodo) {
    List<Widget> itens = [];

    for (int indice = 0; indice < listaPorMetodo.length; indice++) {

      String produtosCesta = "";
      if (listaPorMetodo[indice].containsKey("produtos")) {
        listaPorMetodo[indice]["produtos"].forEach((key, value) {
          produtosCesta += produtosCesta == "" ? "" : ",";
          produtosCesta += " " +
              value["nomeProduto"] +
              " - " +
              value["qtdPacote"] +
              value['unidadeMedida'];
        });
      }
        itens.add(
            Column(
              children: <Widget>[
                Align(
                  child: Row(children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Flexible(
                        child: Text(
                          "${listaPorMetodo[indice]["nome"]} ",
                          style: ControllerCommon.estiloTexto(
                              'titulo 2 negrito', Colors.black),
                        )),
                  ]),
                  //so big text
                  alignment: FractionalOffset.topLeft,
                ),
                Divider(
                  color: Colors.blue,
                ),
                Align(
                  child: Text(
                    listaPorMetodo[indice]["status"],
                    style: ControllerCommon.estiloTexto(
                        'normal negrito',
                        listaPorMetodo[indice]["status"].toString().contains("Cancelado")
                            ? Colors.redAccent
                            : listaPorMetodo[indice]["status"].toString().contains("Preparando")
                            ? Colors.green
                            : Colors.black),
                  ),
                  alignment: FractionalOffset.topLeft,
                ),
                Row(
                  children: [
                    Flexible(
                        child: Text(
                          "Pagamento: ${listaPorMetodo[indice]["metodoPagamento"]}",
                          style: ControllerCommon.estiloTexto('normal', Colors.black),
                        ))
                  ],
                ),
                Divider(
                  color: Colors.blue,
                ),
                Row(children: [
                  Flexible(
                    child: Text(
                      "Nome comprador: ${listaPorMetodo[indice]["nomeComprador"]}",
                      style: ControllerCommon.estiloTexto('normal', Colors.black),
                    ),
                  )
                ]),
                Divider(
                  color: Colors.blue,
                ),
                Row(children: [
                  Flexible(
                    child: Text(
                      listaPorMetodo[indice].containsKey("unidadeMedida")
                          ? "${listaPorMetodo[indice]["qtdPacote"]} ${listaPorMetodo[indice]["unidadeMedida"]} - "
                          : "" + "Pacotes comprados: ${listaPorMetodo[indice]["quantidade"]}",
                      style: ControllerCommon.estiloTexto('normal', Colors.black),
                    ),
                  )
                ]),
                Row(children: [
                  Flexible(
                    child: Text(
                      "Valor total: R\$${formatter.format(double.parse(listaPorMetodo[indice]["precoUnitario"].replaceAll(",", ".")) * listaPorMetodo[indice]["quantidade"])} ",
                      style: ControllerCommon.estiloTexto('normal', Colors.black),
                    ),
                  )
                ]),
                Divider(
                  color: Colors.blue,
                ),
                Text(
                  "${produtosCesta}",
                  style: ControllerCommon.estiloTexto("normal", Colors.black),
                ),
                Divider(
                  color: Colors.indigo,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      child: Text(
                        "Entregar em: ${listaPorMetodo[indice]["enderecoComprador"]}",
                        style: ControllerCommon.estiloTexto('normal', Colors.black),
                      ),
                    ),
                  ],
                )
              ],
            )
        );




    }

    return Column(children: itens);
  }



  static itemComprado(var itemComprado, double precoItem) {
    print("itemComprado");
    NumberFormat formatter = NumberFormat("0.00");
    String produtosCesta = "";
    if (itemComprado.containsKey("produtos")) {
      itemComprado["produtos"].forEach((key, value) {
        produtosCesta += produtosCesta == "" ? "" : ",";
        produtosCesta += " " +
            value["nomeProduto"] +
            " - " +
            value["qtdPacote"] +
            value['unidadeMedida'];
      });
    }
    return Column(children: [
      Align(
        child: Row(children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 10)),
          Flexible(
              child: Text(
            itemComprado["nome"],
            style: ControllerCommon.estiloTextoNegrito(17),
          ))
        ]),
        //so big text
        alignment: FractionalOffset.topLeft,
      ),
      Divider(
        color: Colors.blue,
      ),
      Text(
        "${itemComprado["nomeVendedor"]}",
        style: ControllerCommon.estiloTexto("normal", Colors.black),
      ),
      Divider(
        color: Colors.blue,
      ),
      Text("Status: ${itemComprado["status"]}",
          style: ControllerCommon.estiloTexto(
              "normal",
              itemComprado["status"].contains("Cancelado")
                  ? Colors.redAccent
                  : itemComprado["status"].contains("Preparando")
                      ? Colors.green
                      : itemComprado["status"].contains("final")
                          ? Colors.indigo
                          : Colors.black)),
      Text(
        "Pagamento: ${itemComprado["metodoPagamento"]}",
        style: ControllerCommon.estiloTexto("normal", Colors.black),
      ),
      itemComprado.containsKey("qtdPacote")
          ? Text(
              "${itemComprado["quantidade"]} x ${itemComprado["qtdPacote"]} ${itemComprado["unidadeMedida"]}",
              style: ControllerCommon.estiloTexto("normal", Colors.black),
            )
          : Text(
              "Quantidade: ${itemComprado["quantidade"]}",
              style: ControllerCommon.estiloTexto("normal", Colors.black),
            ),
      Divider(
        color: Colors.blue,
      ),
      Text(
        "${produtosCesta}",
        style: ControllerCommon.estiloTexto("normal", Colors.black),
      ),
      Text(
        "R\$ ${formatter.format(precoItem).replaceAll(".", ",")}",
        style: ControllerCommon.estiloTexto("normal negrito", Colors.black),
      ),
    ]);
  }
}

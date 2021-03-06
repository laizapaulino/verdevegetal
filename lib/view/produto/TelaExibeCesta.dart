import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/model/CestaCarrinho.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/compra/TelaCarrinhoCompras.dart';
import 'package:verde_vegetal_app/view/produto/TelaEditaCesta.dart';
import 'package:verde_vegetal_app/view/usuario/TelaLogin.dart';
import 'package:verde_vegetal_app/view/usuario/TelaPerfilPublico.dart';

class TelaExibeCesta extends StatefulWidget {
  var cesta;
  var usuario;

  TelaExibeCesta(this.cesta, this.usuario); //parametro opcional

  @override
  _TelaExibeCestaState createState() => _TelaExibeCestaState();
}

class _TelaExibeCestaState extends State<TelaExibeCesta> {
  ControllerProduto _ctrProduto = ControllerProduto();
  TextEditingController _quantidadeControl = TextEditingController();
  TextEditingController _descricaoControl = TextEditingController();
  Future<dynamic> _produtos;
  Future<dynamic> _cesta;
  ScrollController _controller = new ScrollController();
  String usernameCesta = "";

  _adicionarCarrinho() async {
    if (widget.usuario.runtimeType == Usuario) {
      NumberFormat formatter = NumberFormat("0.00");

      int quantidade = int.parse(_quantidadeControl.text);
      CestaCarrinho cestaCarrinho;

      try {
        double precoTotalDouble = double.parse(
                widget.cesta.preco.replaceAll(".", "").replaceAll(",", ".")) *
            quantidade;
        String precoTotal = formatter.format(precoTotalDouble);

        cestaCarrinho = CestaCarrinho(
            widget.cesta.idCesta,
            widget.cesta.imagePath,
            widget.cesta.nome,
            //nome cesta
            widget.usuario.nome,
            //nomeComprador
            widget.cesta.nomeVendedor,
            "${precoTotal.toString().replaceAll(".", ",")}",
            "${widget.cesta.preco}",
            int.parse(_quantidadeControl.text),
            widget.cesta.produtos,
            widget.usuario.username,
            widget.cesta.usernameVendedor);
      } catch (err) {
        double precoTotalDouble = double.parse(widget.cesta["preco"]
                .replaceAll(".", "")
                .replaceAll(",", ".")) *
            quantidade;
        String precoTotal = formatter.format(precoTotalDouble);

        cestaCarrinho = CestaCarrinho(
            widget.cesta["idCesta"],
            widget.cesta["imagePath"],
            widget.cesta["nome"],
            widget.usuario.nome,
            widget.cesta["nomeVendedor"],
            "${precoTotal.toString().replaceAll(".", ",")}",
            widget.cesta["preco"],
            int.parse(_quantidadeControl.text),
            widget.cesta["produtos"],
            widget.usuario.username,
            widget.cesta["usernameVendedor"]);
      }

      ControllerProduto ctrProduto = ControllerProduto();
      bool inseriu = await ctrProduto.insereCestaCarrinho(
          cestaCarrinho, widget.usuario.username);
      if (inseriu == true) {
        ElementosInterface.caixaDialogo(
            "Produto inserido com sucesso", context);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TelaCarrinhoCompras()));
      } else {
        ElementosInterface.caixaDialogo(
            "N??o foi possivel inserir o produto", context);
      }
      print("Usuario em exibe prod");
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TelaLogin()));
    }
  }

  _ativaDesativaProduto(String novoStatus) async {
    await _ctrProduto.atualizaDadosItem(
        {"status": novoStatus}, "cesta", "idCesta", widget.cesta["idCesta"]);
    await Future.delayed(Duration(seconds: 3), () {
      //Faz fun????o esperar um pouco para terminar de receber dados
      return 'Dados recebidos...';
    });

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TelaExibeCesta(widget.cesta, widget.usuario)));

    //Fechar tela
    //Abrir de novo
  }

  void initState() {
    try {
      _descricaoControl.text = widget.cesta["descricao"];

      _cesta = _ctrProduto.recuperaCestaPorId(widget.cesta["idCesta"]);
      usernameCesta = widget.cesta["usernameVendedor"];
    } catch (err) {
      _descricaoControl.text = widget.cesta.descricao;

      _cesta = _ctrProduto.recuperaCestaPorId(widget.cesta.idCesta);
      usernameCesta = widget.cesta.usernameVendedor;
    }

    print("init state");
    print(_descricaoControl.text.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _quantidadeControl.text = "1";
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              // _produtos =
              //     _ctrProduto.recuperaProdutoPorId(widget.produto.id_produto);
              // _descricaoControl.text = widget.produto.descricao;
            });
          },
          child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                  child: FutureBuilder(
                      future: _cesta,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data["message"] == "sucesso") {
                            Map produtos = snapshot.data["cesta"].produtos;
                            print("==============");
                            return Column(children: <Widget>[
                              // Image(
                              //   image: snapshot.data["produto.imagePath == ""
                              //       ? AssetImage("assets/images/sem-imagem.png")
                              //       : NetworkImage(snapshot.data["produto.imagePath),
                              //   fit: BoxFit.fitHeight,
                              //   //width: 350,
                              //   height: 300,
                              // ),
                              snapshot.data["cesta"].imagePath != ""
                                  ? FadeInImage(
                                      imageErrorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace stackTrace) {
                                        print('Error Handler');
                                        return Icon(Icons.error);
                                      },
                                      placeholder: AssetImage(
                                          'assets/images/desfoque.png'),
                                      image: NetworkImage(
                                          snapshot.data["cesta"].imagePath),
                                      fit: BoxFit.cover,
                                      height: 80.0,
                                      width: 80.0,
                                    )
                                  : Image(
                                      image:
                                          AssetImage("assets/images/cesta.png"),
                                      width: 80,
                                      height: 80,
                                    ),
                              Text(
                                snapshot.data["cesta"].nome,
                                style: ControllerCommon.estiloTexto(
                                    "titulo principal", Colors.black),
                              ),

                              // Padding(padding: EdgeInsets.only(top: 2)),

                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Bot??o Editar

                                    widget.usuario.runtimeType != Usuario
                                        ? Text("")
                                        : widget.usuario.username ==
                                                snapshot.data["cesta"]
                                                    .usernameVendedor
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
                                                  "Editar produto",
                                                  style: ControllerCommon
                                                      .estiloTexto(
                                                          "com cor",
                                                          Color.fromRGBO(
                                                              34, 192, 149, 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TelaEditaCesta(
                                                                  snapshot.data[
                                                                      "cesta"],
                                                                  widget
                                                                      .usuario)));
                                                })
                                            : Divider(),

                                    //Bot??o desativar

                                    widget.usuario.runtimeType != Usuario
                                        ? Text("")
                                        : widget.usuario.username ==
                                                snapshot.data["cesta"]
                                                    .usernameVendedor
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
                                                  "${snapshot.data["cesta"].status == "ativo" ? "Desativar" : "Ativar"} produto",
                                                  style: ControllerCommon
                                                      .estiloTexto(
                                                          "com cor",
                                                          snapshot.data["cesta"]
                                                                      .status ==
                                                                  "ativo"
                                                              ? Colors
                                                                  .deepOrange
                                                              : Colors.green),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                onPressed: () async {
                                                  _ativaDesativaProduto(snapshot
                                                              .data["cesta"]
                                                              .status ==
                                                          "ativo"
                                                      ? "inativo"
                                                      : "ativo");
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) => TelaEditaProduto(
                                                  //             widget.produto, widget.usuario)));
                                                })
                                            : Divider()
                                  ]),

                              Padding(padding: EdgeInsets.only(top: 20)),

                              //Descri????o
                              Column(children: [
                                Row(children: [
                                  // Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(
                                    "Descri????o",
                                    style: ControllerCommon.estiloTexto(
                                        "titulo", Colors.black),
                                    // TextStyle(fontWeight: FontWeight.bold, fontSize: 25 ),
                                  )
                                ]),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: TextField(
                                    //Define o campo de texto
                                    keyboardType: TextInputType.text,
                                    // decoration: InputDecoration(labelText: "Descri????o do produto"),
                                    enabled: false,
                                    maxLines:
                                        ((_descricaoControl.text.length / 48) +
                                                1)
                                            .round(),
                                    style: ControllerCommon.estiloTexto(
                                        "normal", Colors.black),
                                    obscureText: false,
                                    controller: _descricaoControl,
                                  ),
                                ),
                              ]),

                              Container(
                                  child: Row(
                                children: [
                                  ElementosInterface.childrenFormataTextSpan(
                                      snapshot.data["cesta"].produtos),
                                ],
                              )),

                              //Quantidade a comprar
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.only(left: 20)),
                                  Container(
                                      width: 100,
                                      child: TextField(
                                        //Define o campo de texto
                                        keyboardType: TextInputType.number,
                                        //Define  tipo de teclado
                                        decoration: InputDecoration(
                                            labelText: "Quantidade"),

                                        enabled: true,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.cyan),
                                        obscureText: false,

                                        onSubmitted: (String texto) {
                                          //Quando fecha o teclado
                                          print(texto);
                                        },
                                        controller: _quantidadeControl,
                                      )),
                                  Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(
                                      "Estoque: ${snapshot.data["cesta"].qtdEstoque}")
                                ],
                              ),

                              Padding(padding: EdgeInsets.only(top: 20)),

                              Divider(),
                              Padding(padding: EdgeInsets.only(top: 20)),

                              //Pre??o
                              Text(
                                "R\$ ${snapshot.data["cesta"].preco}",
                                style: TextStyle(fontSize: 30),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: SizedBox(
                                    width: 260,
                                    child: RaisedButton(
                                        onPressed: snapshot
                                                        .data["cesta"].status ==
                                                    "ativo" &&
                                                widget.usuario.runtimeType !=
                                                    Usuario
                                            ? _adicionarCarrinho
                                            : snapshot.data["cesta"].status ==
                                                        "ativo" &&
                                                    widget.usuario.username !=
                                                        snapshot.data["cesta"]
                                                            .usernameVendedor &&
                                                    snapshot.data["cesta"]
                                                            .qtdEstoque >
                                                        0
                                                ? () {
                                                    if (snapshot.data[
                                                            "entregaNaLocalidade"] ==
                                                        false) {
                                                      ElementosInterface
                                                          .caixaDialogo(
                                                              "Esse produto n??o pode ser entregue na sua localidade :(",
                                                              context);
                                                    } else {
                                                      if (snapshot.data["cesta"].qtdEstoque < int.parse( _quantidadeControl.text)) {
                                                        ElementosInterface
                                                            .caixaDialogo(
                                                            "Voc?? escolheu uma quantidade maior que o estoque. Escolha uma quantia menor.",
                                                                context);
                                                      } else {
                                                        _adicionarCarrinho();
                                                      }
                                                    }
                                                  }
                                                : null,
                                        color: Color.fromRGBO(34, 192, 149, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_shopping_cart),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20)),
                                              Text("Comprar"),
                                            ]))),
                              ),
                              Divider(),
                              Row(children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    print("-------------------------");
                                    print(snapshot.data);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TelaPerfilPublico(snapshot
                                                    .data["cesta"]
                                                    .usernameVendedor)));
                                  },
                                  child: Column(
                                    children: [
                                      Image(
                                        image: AssetImage(
                                            "assets/images/user.png"),
                                        width: 70,
                                        height: 70,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(snapshot
                                              .data["cesta"].nomeVendedor))
                                    ],
                                  ),
                                )
                              ])
                            ]);
                          } else {
                            return Text("");
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      })))),
      drawer: new NavDrawer(widget.usuario),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/compra/TelaCarrinhoCompras.dart';
import 'package:verde_vegetal_app/view/produto/TelaEditaProduto.dart';
import 'package:verde_vegetal_app/view/usuario/TelaLogin.dart';
import 'package:verde_vegetal_app/view/usuario/TelaPerfilPublico.dart';

class TelaExibeProduto extends StatefulWidget {
  Produto produto;
  var usuario;

  TelaExibeProduto(this.produto, this.usuario); //parametro opcional

  @override
  _TelaExibeProdutoState createState() => _TelaExibeProdutoState();
}

class _TelaExibeProdutoState extends State<TelaExibeProduto> {
  ControllerProduto _ctrProduto = ControllerProduto();
  TextEditingController _quantidadeControl = TextEditingController();
  TextEditingController _descricaoControl = TextEditingController();
  Future<dynamic> _produtos;

  _adicionarCarrinho() async {
    if (widget.usuario.runtimeType == Usuario) {
      NumberFormat formatter = NumberFormat("0.00");

      int quantidade = int.parse(_quantidadeControl.text);
      double precoTotalDouble = double.parse(
              widget.produto.preco.replaceAll(".", "").replaceAll(",", ".")) *
          quantidade;
      String precoTotal = formatter.format(precoTotalDouble);
      ProdutoCarrinho produtoCarrinho = ProdutoCarrinho(
          widget.produto.id_produto,
          widget.produto.imagePath,
          widget.produto.nome,
          widget.produto.nomeVendedor,
          "${precoTotal.toString().replaceAll(".", ",")}",
          widget.produto.preco,
          int.parse(_quantidadeControl.text),
          widget.produto.qtdPacote,
          widget.produto.unidadeMedida,
          widget.usuario.username,
          widget.produto.usernameVendedor);

      ControllerProduto ctrProduto = ControllerProduto();
      bool inseriu = await ctrProduto.insereCarrinho(
          produtoCarrinho, widget.usuario.username);
      if (inseriu == true) {
        ElementosInterface.caixaDialogo(
            "Produto inserido com sucesso", context);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TelaCarrinhoCompras()));
      } else {
        ElementosInterface.caixaDialogo(
            "Não foi possivel inserir o produto", context);
      }
      print("Usuario em exibe prod");
    } else {
      ElementosInterface.caixaDialogo("Para realizar compras é necessário estar logado", context);
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados
        return 'Dados recebidos...';
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TelaLogin()));
    }
  }

  _ativaDesativaProduto(String novoStatus) async {
    await _ctrProduto.atualizaDadosItem(
        {"status": novoStatus}, "produto", "id_produto", widget.produto.id_produto);

    await Future.delayed(Duration(seconds: 3), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TelaExibeProduto(widget.produto, widget.usuario)));

    //Fechar tela
    //Abrir de novo
  }

  void initState() {
    _descricaoControl.text = widget.produto.descricao;
    _produtos = _ctrProduto.recuperaProdutoPorId(widget.produto.id_produto);

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
              _produtos =
                  _ctrProduto.recuperaProdutoPorId(widget.produto.id_produto);
              _descricaoControl.text = widget.produto.descricao;
            });
          },
          child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                  child: FutureBuilder(
                      future: _produtos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data["message"] == "sucesso") {
                            return Column(children: <Widget>[
                              FadeInImage(
                                imageErrorBuilder: (BuildContext context,
                                    Object exception, StackTrace stackTrace) {
                                  print('Error Handler');
                                  return Icon(Icons.error);
                                },
                                placeholder:
                                    AssetImage('assets/images/desfoque.png'),
                                image: NetworkImage(
                                    snapshot.data["produto"].imagePath),
                                fit: BoxFit.cover,
                                height: 300.0,
                                width: 300.0,
                              ),
                              // Image(
                              //   image: snapshot.data["produto.imagePath == ""
                              //       ? AssetImage("assets/images/sem-imagem.png")
                              //       : NetworkImage(snapshot.data["produto.imagePath),
                              //   fit: BoxFit.fitHeight,
                              //   //width: 350,
                              //   height: 300,
                              // ),
                              Text(
                                snapshot.data["produto"].nome,
                                style: ControllerCommon.estiloTexto(
                                    "titulo principal", Colors.black),
                              ),

                              Padding(padding: EdgeInsets.only(top: 10)),

                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Botão Editar
                                    widget.usuario.runtimeType != Usuario
                                        ? Text("")
                                        : widget.usuario.username ==
                                                widget.produto.usernameVendedor
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
                                                              TelaEditaProduto(
                                                                  snapshot.data[
                                                                      "produto"],
                                                                  widget
                                                                      .usuario)));
                                                })
                                            : Divider(),

                                    //Botão desativar
                                    widget.usuario.runtimeType != Usuario
                                        ? Text("")
                                        : widget.usuario.username ==
                                                snapshot.data["produto"]
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
                                                  "${snapshot.data["produto"].status == "ativo" ? "Desativar" : "Ativar"} produto",
                                                  style: ControllerCommon
                                                      .estiloTexto(
                                                          "com cor",
                                                          snapshot.data["produto"]
                                                                      .status ==
                                                                  "ativo"
                                                              ? Colors.deepOrange
                                                              : Colors.green),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                onPressed: () async {
                                                  _ativaDesativaProduto(snapshot
                                                              .data["produto"]
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

                              //Descrição
                              Column(children: [
                                Row(children: [
                                  // Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(
                                    "Descrição",
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
                                    // decoration: InputDecoration(labelText: "Descrição do produto"),
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
                                      "Estoque: ${snapshot.data["produto"].qtdEstoque}")
                                ],
                              ),

                              Padding(padding: EdgeInsets.only(top: 20)),

                              //Cada pacote contem
                              RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: 'Cada pacote/unidade contém ',
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black)),
                                    new TextSpan(
                                        text:
                                            "${snapshot.data["produto"].qtdPacote} ${snapshot.data["produto"].unidadeMedida}",
                                        style:
                                            ControllerCommon.estiloTextoNegrito(
                                                15)),
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(padding: EdgeInsets.only(top: 20)),

                              //Preço
                              Text(
                                "R\$ ${widget.produto.preco}",
                                style: TextStyle(fontSize: 30),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: SizedBox(
                                    width: 260,
                                    child: RaisedButton(
                                        onPressed: snapshot.data["produto"]
                                                        .status ==
                                                    "ativo" &&
                                                widget.usuario.runtimeType !=
                                                    Usuario
                                            ? _adicionarCarrinho
                                            : snapshot.data["produto"].status ==
                                                        "ativo" &&
                                                    widget.usuario.username !=
                                                        snapshot.data["produto"]
                                                            .usernameVendedor && snapshot.data["produto"].qtdEstoque > 0
                                                ? () {
                                                    if (snapshot.data[
                                                            "entregaNaLocalidade"] ==
                                                        false) {
                                                      ElementosInterface
                                                          .caixaDialogo(
                                                              "Esse produto não pode ser entregue na sua localidade :(",
                                                              context);
                                                    } else {

                                                      if (snapshot.data["produto"].qtdEstoque < int.parse( _quantidadeControl.text)) {
                                                        ElementosInterface
                                                            .caixaDialogo(
                                                            "Você escolheu uma quantidade maior que o estoque. Escolha uma quantia menor.",
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
                                                    .data["produto"].usernameVendedor)));
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
                                              .data["produto"].nomeVendedor))
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

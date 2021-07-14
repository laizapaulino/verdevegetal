import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerProduto.dart';
import 'package:verde_vegetal_app/model/CestaCarrinho.dart';
import 'package:verde_vegetal_app/model/ProdutoCarrinho.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/compra/TelaEscolhaPagamento.dart';

class TelaCarrinhoCompras extends StatefulWidget {
  @override
  _TelaCarrinhoComprasState createState() => _TelaCarrinhoComprasState();
}

class _TelaCarrinhoComprasState extends State<TelaCarrinhoCompras> {
  ScrollController _controller = new ScrollController();

  ControllerProduto _ctrProduto = ControllerProduto();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

  String username = "";
  Future<dynamic> _produtosCarrinho;
  List todosProduto = [];
  Future<dynamic> _usuario;

  String valorTotal = "0,00";
  NumberFormat formatter = NumberFormat("0.00");
  bool botaoHabilitado = true;
  bool botaoQuantidadeHabilitado = true;

  _comprarProdutos() async {
    if (todosProduto.length > 0) {
      setState(() {
        botaoHabilitado = false;
      });
      print("desabilitei");
      //Verifica a disponibilidade de todos
      Map prod = {};
      int indice = 0;
      String produtosIndisponiveis = "";
      bool retireiAlgo = false;
      todosProduto.forEach((element) async {
        var resposta = await _ctrProduto.verificaDisponibilidade(
          element.runtimeType == CestaCarrinho
              ? element.idCesta
              : element.idProduto,
          element.quantidade,
          element.runtimeType == CestaCarrinho ? "Cesta" : "Produto",
        );

        if (resposta["mensagem"] == "Disponivel") {
          indice++;
        } else if (resposta["mensagem"] == "Indisponivel") {
          retireiAlgo = true;
          todosProduto.remove(element);
          await _ctrProduto.atualizaCarro("apagar", element);
          produtosIndisponiveis += "${element.nome},";
        }
      });
      await Future.delayed(Duration(seconds: 4), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });

      if (retireiAlgo) {
        ElementosInterface.caixaDialogo(
            "Alguns dos produtos selecionados estão indisponíveis e foram removidos do carrinho",
            context);
      }
      if (produtosIndisponiveis != "") {
        ElementosInterface.caixaDialogo(
            "Os produtos: ${produtosIndisponiveis.substring(0, produtosIndisponiveis.length - 1)} estão indisponiveis",
            context);
      }
      if (indice > 0) {
        setState(() {
          botaoHabilitado = true;
        });
        // Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TelaEscolhaPagamento()));
        // TelaConfirmaCompra(todosProduto[0].usernameComprador,todosProduto[0].nomeComprador, todosProduto)));
      } else {
        setState(() {
          botaoHabilitado = true;
        });
        print("OBSERVA");
        Navigator.pop(context);
        Navigator.pushNamed(context, "/carrinhoCompras");
      }
    }
  }

  _atualizaValorTotal(List listaProdutos, bool inicio) {
    double valorDouble = 0.0;
    listaProdutos.forEach((element) {
      valorDouble += double.parse(element.precoTotal.replaceAll(",", "."));
    });
    String valor = formatter.format(valorDouble);

    if (inicio == true) {
      this._memoizer.runOnce(() async {
        SchedulerBinding.instance
            .addPostFrameCallback((currentFrameTimeStamp) => setState(() {
                  setState(() {
                    valorTotal = valor;
                    todosProduto = listaProdutos as List;
                    if (listaProdutos.length > 0)
                      username = listaProdutos[0].usernameComprador;
                  });
                }));
      });
    } else {
      setState(() {
        valorTotal = valor;
        todosProduto = listaProdutos;
      });
    }
  }

  _mudaQuantidade(String operacao, var produto, List lista) async {
    setState(() {
      print("DESABILITA");
      botaoQuantidadeHabilitado = false;
    });

    if (operacao == "diminuir" && produto.quantidade - 1 == 0) {
      var retorno = await _ctrProduto.atualizaCarro("apagar", produto);
    }

    if ((operacao == "diminuir" && produto.quantidade - 1 > 0) ||
        operacao == "aumentar") {
      print(produto.toString());
      var retorno = await _ctrProduto.atualizaCarro(operacao, produto);

      if (retorno["erro"] != null) {
        ElementosInterface.caixaDialogo(retorno["erro"].toString(), context);
      } else if (retorno["quantidade"] == 0) {
        //----Não atualizou-----------------------------------------------------------------------------------
        ElementosInterface.caixaDialogo(retorno["mensagem"], context);
      } else if ((operacao == "diminuir" &&
              retorno["quantidade"] < produto.quantidade - 1) ||
          (operacao == "aumentar" &&
              retorno["quantidade"] < produto.quantidade + 1)) {
        //----Estoque menor que o desejado------------------------------------------------------
        //Nesse caso, se pedido 10 mas o estoque contém 7, atualiza para 7
        ElementosInterface.caixaDialogo(retorno["mensagem"], context);
        setState(() {
          double valorDouble = (produto.quantidade *
              double.parse(produto.precoUnitario.replaceAll(",", ".")));
          String valor = formatter.format(valorDouble);
          produto.quantidade = retorno["quantidade"];
          produto.precoTotal = valor.replaceAll(".", ",");
        });
      } else if ((operacao == "diminuir" &&
              retorno["quantidade"] == produto.quantidade - 1) ||
          (operacao == "aumentar" &&
              retorno["quantidade"] == produto.quantidade + 1)) {
        //----Tem estoque-------------------------------------------------------
        //Nesse caso, é retornado que foi atualizado para exatamente a quantia pedida

        print("TEM IGUAL");
        print(retorno["quantidade"]);
        print(produto.quantidade);

        Navigator.pop(context);
        Navigator.pushNamed(context, "/carrinhoCompras");

        // setState(() {
        //   double valorDouble = (produto.quantidade *
        //       double.parse(produto.precoUnitario.replaceAll(",", ".")));
        //   String valor = formatter.format(valorDouble);
        //   produto.quantidade = retorno["quantidade"];
        //   produto.precoTotal = valor.replaceAll(".", ",");
        // });

      }

      setState(() {
        botaoQuantidadeHabilitado = true;

        _atualizaValorTotal(
            lista, false); //Metodo chamado duas vezes pois uma só não atualiza
        _atualizaValorTotal(lista, false);
      });
    }
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  void initState() {
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _produtosCarrinho = _ctrProduto.recuperaCarrinho();
    botaoQuantidadeHabilitado = true;
    print(botaoQuantidadeHabilitado);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
        padding: EdgeInsets.all(20),
        child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _usuario = _ctrAutenticacao.recuperaLoginSalvo();
                _produtosCarrinho = _ctrProduto.recuperaCarrinho();
              });
            },
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Carrinho de compras",
                      //textAlign: TextAlign.center,
                      style:
                          ControllerCommon.estiloTexto("titulo", Colors.black)),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  FutureBuilder(
                      future: _produtosCarrinho,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data.length > 0) {
                            try {
                              _atualizaValorTotal(
                                  snapshot.data, true); //Roda na inicializacao
                              // if (snapshot.data[0]["erro"] == null) {
                              return Expanded(
                                  child: ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                controller: _controller,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, indice) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          child: Row(children: <Widget>[
                                            snapshot.data[indice].imagePath !=
                                                    ""
                                                ? FadeInImage(
                                                    imageErrorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace
                                                                stackTrace) {
                                                      print('Error Handler');
                                                      return Icon(Icons.error);
                                                    },
                                                    placeholder: AssetImage(
                                                        'assets/images/desfoque.png'),
                                                    image: NetworkImage(snapshot
                                                        .data[indice]
                                                        .imagePath),
                                                    fit: BoxFit.cover,
                                                    height: 70.0,
                                                    width: 70.0,
                                                  )
                                                : Image(
                                                    image: AssetImage(
                                                        'assets/images/cesta.png'),
                                                    width: 70,
                                                    height: 70,
                                                  ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10)),
                                            Text(
                                              snapshot.data[indice].nome,
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "titulo 2 negrito",
                                                      Colors.black),
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
                                            "Vendido por: " +
                                                snapshot
                                                    .data[indice].nomeVendedor,
                                            style: ControllerCommon.estiloTexto(
                                                "normal", Colors.black),
                                          ),
                                          alignment: FractionalOffset.topLeft,
                                        ),
                                        Divider(
                                          color: Colors.blue,
                                        ),
                                        snapshot.data[indice].runtimeType ==
                                                ProdutoCarrinho
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                    Flexible(
                                                      child: Text(
                                                          "Vendido a cada: ${snapshot.data[indice].qtdPacote} ${snapshot.data[indice].unidadeMedida}",
                                                          style: ControllerCommon
                                                              .estiloTexto(
                                                                  "normal",
                                                                  Colors
                                                                      .black)),
                                                    )
                                                  ])
                                            : Text(""),
                                        Align(
                                          child: Text(
                                            "Preço unitário: R\$" +
                                                snapshot
                                                    .data[indice].precoUnitario,
                                            style: ControllerCommon.estiloTexto(
                                                "normal", Colors.black),
                                          ),
                                          alignment: FractionalOffset.topLeft,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Quantidade: ",
                                              style:
                                                  ControllerCommon.estiloTexto(
                                                      "normal negrito",
                                                      Colors.black),
                                            ),
                                            Container(
                                              height: 20.0,
                                              width: 20.0,
                                              child: FittedBox(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    size: 50,
                                                    color:
                                                        botaoQuantidadeHabilitado ==
                                                                true
                                                            ? Colors.indigo
                                                            : Colors.black38,
                                                  ),
                                                  highlightColor: Colors.cyan,
                                                  onPressed:
                                                      botaoQuantidadeHabilitado ==
                                                              true
                                                          ? () {
                                                              _mudaQuantidade(
                                                                  "diminuir",
                                                                  snapshot.data[
                                                                      indice],
                                                                  snapshot
                                                                      .data);
                                                            }
                                                          : () {
                                                              print(
                                                                  "------------desabilitado--------");
                                                            },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10)),
                                            Text(
                                                "${snapshot.data[indice].quantidade}"),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 2)),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                size: 20,
                                                color:
                                                    botaoQuantidadeHabilitado ==
                                                            true
                                                        ? Colors.indigo
                                                        : Colors.black38,
                                              ),
                                              highlightColor: Colors.cyan,
                                              onPressed:
                                                  botaoQuantidadeHabilitado ==
                                                          true
                                                      ? () {
                                                          _mudaQuantidade(
                                                              "aumentar",
                                                              snapshot
                                                                  .data[indice],
                                                              snapshot.data);
                                                        }
                                                      : () {
                                                          print(
                                                              "------------desabilitado--------");
                                                        },
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5)),
                                          ],
                                        ),
                                        Align(
                                          child: Text(
                                            "Valor total: R\$" +
                                                snapshot
                                                    .data[indice].precoTotal,
                                            style: ControllerCommon.estiloTexto(
                                                "normal negrito", Colors.black),
                                          ),
                                          alignment: FractionalOffset.topLeft,
                                        ),
                                        Row(children: [
                                          Flexible(
                                              child: FlatButton(
                                                  onPressed: () async {
                                                    var resp =
                                                    await ElementosInterface
                                                        .caixaDialogoSimNao(
                                                        "Remover o produto do carrinho?",
                                                        context);

                                                    print(await resp);
                                                    if (await resp == true) {
                                                      await _ctrProduto
                                                          .atualizaCarro(
                                                          "apagar",
                                                          snapshot.data[
                                                          indice]);

                                                      setState(() {
                                                        snapshot.data
                                                            .removeAt(indice);
                                                        _atualizaValorTotal(
                                                            snapshot.data,
                                                            false); //Necessario chamar duas vezes
                                                        _atualizaValorTotal(
                                                            snapshot.data,
                                                            false);
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    "Remover",
                                                    style: ControllerCommon
                                                        .estiloTexto("normal",
                                                        Colors.redAccent),
                                                  )))

                                        ],)

                                      ],
                                    ),
                                  );
                                },
                              ));
                            } catch (err) {
                              return Card(
                                  child: ListTile(
                                      onTap: () {},
                                      onLongPress: () {},
                                      title: Text(snapshot.data[0]["erro"]),
                                      subtitle: Text("")));
                            }
                          } else {
                            return Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Seu carrinho está vazio.",
                                  style: ControllerCommon.estiloTextoNormal(20),
                                ));
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                  //Inicio - Caso não tenha produtos

                  //Fim sem produtos

                  //Inicio produtos carrinho

                  //Fim

                  Padding(padding: EdgeInsets.only(top: 15)),
                ])),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Total: R\$ " + (valorTotal).replaceAll(".", ","),
            style:
                ControllerCommon.estiloTexto("titulo 2 negrito", Colors.black),
          ),
          RaisedButton(
            color: Colors.blue,
            child: Text(
              "Comprar",
              style: ControllerCommon.estiloTexto("normal", Colors.white),
            ),
            onPressed: botaoHabilitado == true ? _comprarProdutos : null,
          )
        ],
      )),

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
          }), //Colocar dentro de um Future
    );
  }
}

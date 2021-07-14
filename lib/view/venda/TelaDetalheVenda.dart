import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ControllerVendas.dart';
import 'package:verde_vegetal_app/model/ItemComprado.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/MyTextFieldDatePicker.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaDetalheVenda extends StatefulWidget {
  String idCompra;
  String dataCompra;
  int qtdProd;
  int qtdCancelada;
  String status;
  String previsaoEntrega;
  double valorFrete;

  TelaDetalheVenda(this.idCompra, this.dataCompra, this.qtdProd,
      this.qtdCancelada, this.status, this.previsaoEntrega, this.valorFrete);

  @override
  _TelaDetalheVendaState createState() => _TelaDetalheVendaState();
}

class _TelaDetalheVendaState extends State<TelaDetalheVenda> {
  ScrollController _controller = new ScrollController();
  ElementosInterface _elementosInterface = new ElementosInterface();
  ControllerVenda _ctrVenda = ControllerVenda();
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
  NumberFormat formatter = NumberFormat("0.00");

  Future<Map> _vendas;
  Future<dynamic> _usuario;
  TextEditingController _timeController = TextEditingController();

  String _setTime;
  String _hour, _minute, _time;
  String dateTime;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  String dataString = "";
  bool confirmouPrevisaoEntrega = false;

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  Future<void> _askedToLead() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Informe a previsão de entrega',
                style: ControllerCommon.estiloTexto(
                    "normal negrito", Colors.blueAccent)),
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10)),
              MyTextFieldDatePicker(
                labelText: "Data",
                prefixIcon: Icon(Icons.date_range),
                suffixIcon: Icon(Icons.arrow_drop_down),
                lastDate: DateTime.now().add(Duration(days: 30)),
                firstDate: DateTime.now(),
                initialDate: DateTime.now().add(Duration(days: 1)),
                onDateChanged: (selectedDate) {
                  print(selectedDate);
                  dataString =
                      "${selectedDate.day.toString().length == 1 ? '0' + selectedDate.day.toString() : selectedDate.day}"
                      "/${selectedDate.month.toString().length == 1 ? '0' + selectedDate.month.toString() : selectedDate.month}"
                      "/${selectedDate.year}";

                  // Do something with the selected date
                },
              ),
              InkWell(
                onTap: () {
                  _selectTime(context);
                  print(_timeController.text);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  width: 70,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: TextFormField(
                    style: ControllerCommon.estiloTextoNormal(20),
                    textAlign: TextAlign.center,
                    onChanged: (val) {
                      _setTime = val;
                      print(_setTime);

                      print(_timeController.text);
                    },
                    onFieldSubmitted: (String val) {
                      print(val);
                    },
                    onSaved: (String val) {
                      _setTime = val;
                      print(_setTime);
                    },
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: "Hora",
                      labelStyle: ControllerCommon.estiloTextoNormal(5),
                      // labelText: 'Time',
                      // contentPadding: EdgeInsets.all(5)
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                child: Text('Salvar',
                    style: ControllerCommon.estiloTexto(
                        "normal negrito", Colors.blueAccent)),
                onPressed: () async {
                  Navigator.pop(context, "Salvar");
                },
              ),
            ],
          );
        })) {
      case "Salvar":
        confirmouPrevisaoEntrega = await ElementosInterface.caixaDialogoSimNao(
            "Previsão de entrega para: ${dataString} às ${_timeController.text}.\nConfirmar?",
            context);
        // dispose();

        break;
      case "null":
        // dialog dismissed
        break;
    }
  }

  _mudaStatusEntrega(String novoStatus) async {
    print("novo status: ${novoStatus}");
    bool confirmou = await ElementosInterface.caixaDialogoSimNao(
        'Deseja mudar o status do pedido para "${novoStatus}"?', context);

    String previsaoEntrega = "";
    if (confirmou == true) {
      if (novoStatus.contains("Preparando")) {
        await _askedToLead();
        previsaoEntrega = "${dataString} às ${_timeController.text}";
      }
    }

    if ((confirmouPrevisaoEntrega == true &&
            novoStatus.contains("Preparando")) ||
        novoStatus.contains(textoBotao[1])) {
      String mudaStatus = "none";
      mudaStatus = await _ctrVenda.mudaStatusCompraReferenciaVendedor(
          widget.idCompra, previsaoEntrega, novoStatus);

      while (mudaStatus == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      setState(() {
        if (confirmouPrevisaoEntrega == true &&
            novoStatus.contains("Preparando")) {
          widget.previsaoEntrega = previsaoEntrega;
        }
        widget.status = novoStatus;
        _vendas = _ctrVenda.recuperaVendaVendedorIdCompra(widget.idCompra);
      });
    }
  }

  _cancelaItem(String idProduto, String idItemComprado, String usernameVendedor) async {
    bool confirmou = await ElementosInterface.caixaDialogoSimNao(
        "Deseja cancelar a venda desse item?", context);

    if (confirmou == true) {
      String cancelamento = "none";
      //destiva botao de entrega
      setState(() {
        widget.qtdCancelada = widget.qtdCancelada + 1;
        if (widget.qtdCancelada == widget.qtdProd) {
          widget.status = "Cancelado";
        }
      });

      cancelamento = await _ctrVenda.cancelaItemCompra(
          idProduto, widget.idCompra, idItemComprado, "vendedor",usernameVendedor);
      while (cancelamento == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }
      setState(() {
        _vendas = _ctrVenda.recuperaVendaVendedorIdCompra(widget.idCompra);
      });
    }
  }

  @override
  void initState() {
    print("Cancelados ========> ${widget.qtdProd} ${widget.qtdCancelada}");
    _usuario = _ctrAutenticacao.recuperaLoginSalvo();
    _vendas = _ctrVenda.recuperaVendaVendedorIdCompra(widget.idCompra);
    _timeController.text = formatDate(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            DateTime.now().hour, DateTime.now().minute + 30),
        [hh, ':', nn, " ", am]).toString();
    dataString =
        "${DateTime.now().day.toString().length == 1 ? '0' + DateTime.now().day.toString() : DateTime.now().day}"
        "/${DateTime.now().month.toString().length == 1 ? '0' + DateTime.now().month.toString() : DateTime.now().month}"
        "/${DateTime.now().year}";

    super.initState();
  }

  List textoBotao = ["Preparando \nentrega", "Entrega finalizada"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
          padding: EdgeInsets.all(20),
          //padding: EdgeInsets.all(32),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text("Pedido ${widget.dataCompra}",
                    //textAlign: TextAlign.center,
                    style:
                        ControllerCommon.estiloTexto("titulo", Colors.black)),
                Column(
                  children: [
                    Row(children: [
                      Flexible(
                          child: Text(
                              "Status entrega atual: " +
                                  widget.status.replaceAll("\n", ""),
                              //textAlign: TextAlign.center,
                              style: ControllerCommon.estiloTexto(
                                  "normal negrito",
                                  widget.status.toString().contains("Cancelado")
                                      ? Colors.redAccent
                                      : widget.status
                                              .toString()
                                              .contains("Preparando")
                                          ? Colors.green
                                          : widget.status
                                                  .toString()
                                                  .contains("final")
                                              ? Colors.indigo
                                              : Colors.black)))
                    ]),
                    Row(
                      children: [
                        Flexible(
                            child: Text(
                                "Previsão entrega: ${widget.previsaoEntrega}",
                                //textAlign: TextAlign.center,
                                style: ControllerCommon.estiloTexto(
                                    "normal", Colors.black))),
                      ],
                    ),
                    widget.status.contains("Cancelado") ||
                            widget.status.contains("finalizada")
                        ? Text("")
                        : Row(
                            children: [
                              Flexible(
                                  child: Text("Mudar status entrega:",
                                      //textAlign: TextAlign.center,
                                      style: ControllerCommon.estiloTexto(
                                          "normal", Colors.black))),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                              ),
                              MaterialButton(
                                  onPressed: () {
                                    String status =
                                        widget.status.contains("Aguardando")
                                            ? textoBotao[0]
                                            : textoBotao[1];
                                    _mudaStatusEntrega(
                                        status.replaceAll("\n", ""));
                                  },
                                  color: Colors.greenAccent,
                                  child: Text(
                                      widget.status.contains("Aguardando")
                                          ? textoBotao[0]
                                          : widget.status.contains("Preparando")
                                              ? textoBotao[1]
                                              : "-",
                                      //textAlign: TextAlign.center,
                                      style:
                                          ControllerCommon.estiloTextoNegrito(
                                              10))),
                            ],
                          ),
                  ],
                ),
                Divider(
                  color: Colors.cyan,
                ),
                FutureBuilder(
                    future: _vendas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        try {
                          print("detalhe");
                          print(snapshot.data.keys.toString());
                          print(snapshot.data["itensComprados"].toString());
                          return
                              // Expanded(
                              //   child:

                              Column(children: [
                            //======Dados comprador=================================
                            Column(children: [
                              Row(children: [
                                Flexible(
                                    child: Text(
                                        (widget.qtdProd != widget.qtdCancelada
                                                ? "Valor a cobrar: R\$${formatter.format(snapshot.data['valorTotal'])} + R\$${formatter.format(widget.valorFrete)} (frete)\n"
                                                : "") +
                                            "Telefone do comprador: ${snapshot.data['celularComprador']}",
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black))),
                              ]),
                              Row(children: [
                                Flexible(
                                    child: Text(
                                        "Email do comprador: ${snapshot.data['emailComprador']}",
                                        style: ControllerCommon.estiloTexto(
                                            "normal", Colors.black))),
                              ]),
                              Divider(
                                color: Colors.indigo,
                              ),
                            ]),
                            //======================================================

                            ListViwerAninhadoItemCompra(
                                snapshot.data["itensComprados"]),
                            // Expanded(
                            //     child:

                            //=============OLD=============================
//                             ListView.builder(
//                                 physics: const BouncingScrollPhysics(
//                                     parent: AlwaysScrollableScrollPhysics()),
//                                 controller: _controller,
//                                 scrollDirection: Axis.vertical,
//                                 shrinkWrap: true,
//                                 itemCount:
//                                     snapshot.data["itensComprados"].length,
//                                 itemBuilder: (context, indice) {
//                                   return InkWell(
//                                       highlightColor: Colors.cyan,
//                                       hoverColor: Colors.cyan,
//                                       onTap: () {
//                                         // _verProduto(p);
//                                       }, // child: Card(
//                                       child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             vertical: 10.0,
//                                           ),
//                                           child: Column(
//                                             children: [
// ////
//
//                                               _elementosInterface
//                                                   .childrenCardVenda(snapshot
//                                                               .data[
//                                                           "itensComprados"]
//                                                       [indice]),
//
//                                               Row(
//                                                 children: [
//                                                   Padding(
//                                                       padding: EdgeInsets.only(
//                                                           left: 10)),
//                                                   snapshot.data["itensComprados"]
//                                                                   [indice]
//                                                                   ["status"]
//                                                               .contains(
//                                                                   "Cancelado") ||
//                                                           snapshot
//                                                               .data["itensComprados"]
//                                                                   [indice]
//                                                                   ["status"]
//                                                               .contains(
//                                                                   textoBotao[1])
//                                                       ? Divider()
//                                                       : MaterialButton(
//                                                           onPressed:
//                                                               snapshot.data["itensComprados"][indice]["status"].contains("Preparando") ||
//                                                                       snapshot
//                                                                           .data["itensComprados"]
//                                                                               [indice]
//                                                                               ["status"]
//                                                                           .contains("Cancelado")
//                                                                   ? null
//                                                                   : () {
//                                                                       _cancelaItem(
//                                                                           snapshot.data["itensComprados"][indice]
//                                                                               [
//                                                                               "idProduto"],
//                                                                           snapshot.data["itensComprados"][indice]
//                                                                               [
//                                                                               "idItemComprado"]);
//                                                                     },
//                                                           color: Colors.redAccent,
//                                                           child: Text("Cancelar pedido",
//                                                               //textAlign: TextAlign.center,
//                                                               style: ControllerCommon.estiloTextoNegrito(10)))
//                                                 ],
//                                               ),
//
//
//                                             ],
//                                           )));
//                                 })
                            //==================================================

                            // )
                          ]);
                        } catch (err) {
                          print(err);
                          return Text("Não foi possivel recuperar os produtos");
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ]))),
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
      itens.add(Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color:
                listaPorMetodo[indice]["status"].toString().contains("Cancel")
                    ? Colors.black12
                    : Colors.white,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child:

          Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(2)),
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
                      listaPorMetodo[indice]["status"]
                              .toString()
                              .contains("Cancelado")
                          ? Colors.redAccent
                          : listaPorMetodo[indice]["status"]
                                  .toString()
                                  .contains("Preparando")
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
                        : "" +
                            "Pacotes comprados: ${listaPorMetodo[indice]["quantidade"]}",
                    style: ControllerCommon.estiloTexto('normal', Colors.black),
                  ),
                )
              ]),
              Row(children: [
                Flexible(
                  child: Text(
                    "Valor total: R\$${formatter.format(double.parse(listaPorMetodo[indice]["precoUnitario"].replaceAll(",", ".")) * listaPorMetodo[indice]["quantidade"])}" +
                        (produtosCesta == "" ? "" : "\n${produtosCesta}"),
                    style: ControllerCommon.estiloTexto('normal', Colors.black),
                  ),
                )
              ]),

              // Text(
              //   "${produtosCesta}",
              //   style: ControllerCommon.estiloTexto("normal", Colors.black),
              // ),
              Divider(
                color: Colors.indigo,
              ),
              Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                    child: Text(
                      "Entregar em: ${listaPorMetodo[indice]["enderecoComprador"]}",
                      style:
                          ControllerCommon.estiloTexto('normal', Colors.black),
                    ),
                  ),
                ],
              ),
              //===========================================================

              Row(
                children: [
                  Padding(padding: EdgeInsets.only(left: 10)),
                  listaPorMetodo[indice]["status"].contains("Cancelado") ||
                          listaPorMetodo[indice]["status"]
                              .contains(textoBotao[1])
                      ? Divider()
                      : MaterialButton(
                          onPressed: listaPorMetodo[indice]["status"]
                                      .contains("Preparando") ||
                                  listaPorMetodo[indice]["status"]
                                      .contains("Cancelado")
                              ? null
                              : () {
                                  _cancelaItem(
                                      listaPorMetodo[indice]["idProduto"],
                                      listaPorMetodo[indice]["idItemComprado"],
                                      listaPorMetodo[indice]["usernameVendedor"]
                                  );
                                },
                          color: Colors.redAccent,
                          child: Text("Cancelar pedido",
                              //textAlign: TextAlign.center,
                              style: ControllerCommon.estiloTextoNegrito(10)))
                ],
              ),

              //===========================================================
            ],
          )

      ));
    }

    return Column(children: itens);
  }
}

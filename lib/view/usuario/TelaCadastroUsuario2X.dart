import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/model/DadosVendedor.dart';
import 'package:verde_vegetal_app/model/FreteVendedor.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';

class TelaCadastroUsuario2X extends StatefulWidget {
  Map usuario;

  TelaCadastroUsuario2X(this.usuario);

  @override
  _TelaCadastroUsuario2XState createState() => _TelaCadastroUsuario2XState();
}

TextEditingController _cepControl = TextEditingController();
TextEditingController _logradouroControl = TextEditingController();
TextEditingController _bairroControl = TextEditingController();
TextEditingController _numeroControl = TextEditingController();
TextEditingController _complementoControl = TextEditingController();
TextEditingController _cidadeControl = TextEditingController();
TextEditingController _estadoControl = TextEditingController();

class _TelaCadastroUsuario2XState extends State<TelaCadastroUsuario2X> {
  ValidacaoDados _validacao = ValidacaoDados();

  var retornoCep;

  bool apertouCadastrar = false;
  _concluirCadastro(BuildContext context) async {
    setState(() {
      apertouCadastrar = true;
    });
    String camposVazios = _validacao.validaCamposPreenchidos({
      "CEP": _cepControl.text,
      "Rua/Avenida": _logradouroControl.text,
      "Bairro": _bairroControl.text,
      "Numero do endereço": _numeroControl.text,
      "Cidade": _cidadeControl.text,
      "Estado": _estadoControl.text,
    });
    if (camposVazios != "") {
      camposVazios = camposVazios.substring(0, camposVazios.length-2);
      String aviso = "Os campos $camposVazios estão vazios";
      ElementosInterface.caixaDialogo(aviso, context);
      setState(() {
        apertouCadastrar = false;
      });
    } else {

      showDialog(
          context: context,
          builder: (BuildContext context) => Container(
              child: SimpleDialog(
                children: [
                  Center(
                    child: Container(
                      height: 70.0,
                      width: 70.0,
                      child: CircularProgressIndicator(
                        // backgroundColor: Colors.cyan,
                      ),
                    ),
                  )
                ], // The content inside the dialog
              )));

      var now = DateTime.now();
      String dataAgora =
          "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}${now.hour.toString()}-${now.minute.toString()}";
      String username = widget.usuario["email"].split("@")[0] + dataAgora;

      //Cadastra info usuario
      Usuario usuario = Usuario(
          _bairroControl.text,
          _cepControl.text,
          _cidadeControl.text,
          widget.usuario["cnpj"],
          _complementoControl.text,
          widget.usuario["cpf"],
          Timestamp.fromDate(DateTime.now()),
          widget.usuario["email"],
          _estadoControl.text,
          "",
          //imagePath
          _logradouroControl.text,
          widget.usuario["nome"],
          _numeroControl.text,
          widget.usuario["senha"],
          "ativo",
          widget.usuario["telefone"],
          widget.usuario["tipoConta"],
          username);
      ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
      String resultado = "";
      resultado = await ctrAutenticacao.cadastraUsuario(usuario);

      while (resultado == "") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      if (resultado == "falha") {
        ElementosInterface.caixaDialogo(
            "Sinto muito, não consegui te cadastrar. Por favor, tente novamente mais tarde",
            context);
      } else {
        print("Não falhei");
        print(widget.usuario["tipoConta"]);

        String resultadoVendedor = "";
        String resultadoFrete = "";

        //Cadastra info vendedor
        if (widget.usuario["tipoConta"] == "Vendedor") {
          FreteVendedor freteVendedor =
              FreteVendedor(username, widget.usuario["frete"]);

          resultadoFrete =
              await ctrAutenticacao.cadastraAtualizareteVendedor(freteVendedor);

          DadosVendedor dadosVendedor = DadosVendedor(
              username,
              widget.usuario["emailYapay"],
              widget.usuario["cpfYapay"],
              widget.usuario["cnpjYapay"],
              widget.usuario["pagamentoEntregaDinheiro"],
              widget.usuario["pagamentoEntregaCredito"],
              widget.usuario["pagamentoOnlineCredito"],
              {"Itajubá": 6.00});

          resultadoVendedor =
              await ctrAutenticacao.cadastraDadosVendedor(dadosVendedor);

          while (resultadoVendedor == "" && resultadoVendedor == "") {
            await Future.delayed(Duration(seconds: 2), () {
              //Faz função esperar um pouco para terminar de receber dados do forEach
              return 'Dados recebidos...';
            });
          }
          print("cadastrei");
        }
        await ctrAutenticacao.loginUsuario(widget.usuario["email"]);

        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }

      // TelaIntermediaria(usuario)));
    }
  }

  setaControllers(var dados) {
    print("setaControllers");
    print(_cepControl.text);

    if (_cepControl.text == "" && apertei == false) {
      _cepControl.text = dados.cep;
      _logradouroControl.text =
          dados.logradouro == null ? "" : dados.logradouro;
      _bairroControl.text = dados.bairro == null ? "" : dados.bairro;
      _numeroControl.text = dados.num == null ? "" : dados.num;
      _complementoControl.text =
          dados.complemento == null ? "" : dados.complemento;
      _cidadeControl.text = dados.cidade == null ? "" : dados.cidade;
      _estadoControl.text = dados.estado == null ? "" : dados.estado;
    }
  }

  bool apertei;

  buscaCep() async {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
              title:Text("Estou buscando o CEP...",
                  //textAlign: TextAlign.center,
                  style: ControllerCommon.estiloTexto(
                      "normal", Colors.black)));
        });
    await Future.delayed(Duration(seconds: 1), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });

    var retorno = await _validacao.buscaCep(_cepControl.text.toString());
    if (retorno == null || retorno.containsKey("erro")) {
      ElementosInterface.caixaDialogo("O CEP informado não é valido", context);
      return false;
    } else {
      setState(() {
        apertei == true;

        print(retorno["bairro"]);
        _bairroControl.text =
            retorno["bairro"] == null ? "" : retorno["bairro"];
        _cidadeControl.text =
            retorno["localidade"] == null ? "" : retorno["localidade"];
        _estadoControl.text = retorno["uf"] == null ? "" : retorno["uf"];
        _logradouroControl.text =
            retorno["logradouro"] == null ? "" : retorno["logradouro"];
      });
      return true;
    }
  }

  void initState() {
    super.initState();
    apertouCadastrar = false;

    _logradouroControl.text = "";
    _estadoControl.text = "";
    _cidadeControl.text = "";
    _bairroControl.text = "";
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
                    Text("Cadastro de usuário - Endereço",
                        //textAlign: TextAlign.center,
                        style: ControllerCommon.estiloTextoNegrito(25)),
                    Row(children: [
                      Flexible(
                          child: Text(
                              "• Pesquise pelo seu CEP para que os dados sejam preenchidos.",
                              //textAlign: TextAlign.center,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black))),
                    ]),
                    Row(children: [
                      Flexible(
                          child: Text(
                              "• Caso a cidade possua um CEP geral, você poderá completar as informações",
                              //textAlign: TextAlign.center,
                              style: ControllerCommon.estiloTexto(
                                  "normal", Colors.black))),
                    ]),


                    //CEP
                    Row(
                      children: [
                        Flexible(
                            child: TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.number,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "CEP"),
                          enabled: true,
                          maxLength: 8,
                          maxLengthEnforced: false,
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black),
                          obscureText: false,

                          controller: _cepControl,
                              onChanged: (String text) {
                                _logradouroControl.text = "";
                                _estadoControl.text = "";
                                _cidadeControl.text = "";
                                _bairroControl.text = "";
                              },
                        )),
                        RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            "Busca CEP",
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.white),
                          ),
                          onPressed: () async {
                            bool _resposta = await buscaCep();
                            if (_resposta == false) {
                              setState(() {
                                apertei = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        //Campo Logradouro (rua/avenida)
                        TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.text,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "Logradouro (rua/avenida)"),
                          enabled: _logradouroControl.text == "" ? true : false,
                          maxLengthEnforced: false,
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black),
                          obscureText: false,

                          onSubmitted: (String texto) {
                            //Quando fecha o teclado
                            print(texto);
                          },
                          controller: _logradouroControl,
                        ),

                        //Bairro
                        TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.text,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "Bairro"),
                          enabled: _bairroControl.text == "" ? true : false,
                          maxLengthEnforced: false,
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black),
                          obscureText: false,
                          onSubmitted: (String texto) {
                            //Quando fecha o teclado
                            print(texto);
                          },
                          controller: _bairroControl,
                        ),

                        //Campo Cidade
                        TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.number,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "Cidade"),
                          enabled: false,
                          maxLengthEnforced: false,
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black),
                          obscureText: false,
                          onSubmitted: (String texto) {
                            //Quando fecha o teclado
                            print(texto);
                          },
                          controller: _cidadeControl,
                        ),

                        //Campo Estado
                        TextField(
                          //Define o campo de texto
                          keyboardType: TextInputType.number,
                          //Define  tipo de teclado
                          decoration: InputDecoration(labelText: "Estado"),
                          enabled: false,
                          maxLengthEnforced: false,
                          style: ControllerCommon.estiloTexto(
                              "normal", Colors.black),
                          obscureText: false,
                          onSubmitted: (String texto) {
                            //Quando fecha o teclado
                            print(texto);
                          },
                          controller: _estadoControl,
                        ),
                      ],
                    ),

                    //Campo Número
                    TextField(
                      //Define o campo de texto
                      keyboardType: TextInputType.number,
                      //Define  tipo de teclado
                      decoration: InputDecoration(labelText: "Número"),
                      enabled: true,
                      maxLengthEnforced: false,
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
                      obscureText: false,

                      controller: _numeroControl,
                    ),

                    //Campo Complemento
                    TextField(
                      //Define o campo de texto
                      keyboardType: TextInputType.text,
                      //Define  tipo de teclado
                      decoration: InputDecoration(labelText: "Complemento"),
                      enabled: true,
                      maxLengthEnforced: false,
                      style:
                          ControllerCommon.estiloTexto("normal", Colors.black),
                      obscureText: false,

                      controller: _complementoControl,
                    ),

                    Padding(padding: EdgeInsets.only(top: 10)),
                    //Botão proximo
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      RaisedButton(
                          color: Color.fromRGBO(34, 192, 149, 1),
                          child: Text(
                            "Concluir cadastro",
                            style: ControllerCommon.estiloTexto(
                                "normal negrito", Colors.white),
                          ),
                          padding: EdgeInsets.all(15),
                          onPressed:
                          apertouCadastrar == false?
                              () {
                            _concluirCadastro(context);
                          }: null)
                    ])
                  ]),
            )
            //    )
            ));
  }
}

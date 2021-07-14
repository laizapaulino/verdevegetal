
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:verde_vegetal_app/controllers/AutenticacaoFirebase.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';
import 'package:verde_vegetal_app/view/usuario/TelaPerfilLogado.dart';

class TelaConfiguracoes extends StatefulWidget {
  @override
  _TelaConfiguracoesState createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

  bool modoEdicao = false;
  Color cor = Colors.black54;
  String nomeBotao = "Editar dados";
  Color corBotao = Colors.blueAccent;
  String username;
  TextEditingController _nomecontrol = TextEditingController();
  TextEditingController _emailcontrol = TextEditingController();
  TextEditingController telefone =
      new MaskedTextController(mask: "(00)00000000");

  TextEditingController _telefoneControl = TextEditingController();

  Future<dynamic> _usua;

  String processei = "não";

  void initState() {
    _usua = _ctrAutenticacao.recuperaLoginSalvo();

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
                Text("Configurações",
                    textAlign: TextAlign.start,
                    style:
                        ControllerCommon.estiloTexto("titulo", Colors.black)),
                Padding(padding: EdgeInsets.only(top: 20)),

                MaterialButton(
                  color: Color.fromRGBO(34, 192, 149, 1),
                  child: Text("Editar perfil",
                      //textAlign: TextAlign.center,
                      style: ControllerCommon.estiloTexto(
                          "normal negrito", Colors.white)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TelaPerfilLogado()));
                  },
                ),
                OutlinedButton(
                    child: Text("Desativar conta",
                        //textAlign: TextAlign.center,
                        style: ControllerCommon.estiloTexto(
                            "normal", Colors.redAccent)),
                    onPressed: () async {
                      String retorno = "none";
                      retorno = await _ctrAutenticacao.desativaUsuario();
                      while (retorno == "none") {
                        await Future.delayed(Duration(seconds: 2), () {
                          //Faz função esperar um pouco para terminar de receber dados do forEach
                          return 'Dados recebidos...';
                        });
                      }
                      if (retorno.contains("vendas")) {
                        ElementosInterface.caixaDialogo(
                            "Não foi possível desativar sua conta, pois você ainda possui vendas em andamento.",
                            context);
                      } else if (retorno.contains("compras")) {
                        ElementosInterface.caixaDialogo(
                            "Não foi possível desativar sua conta, pois você ainda possui compras em andamento.",
                            context);
                      } else if (retorno.contains("erro")) {
                        ElementosInterface.caixaDialogo(
                            "Não foi possível desativar sua conta, nesse momento.",
                            context);
                      } else if (retorno.contains("sucesso")) {
                        String retorno = "";
                        retorno = await AutenticacaoLogin.signOut(context);

                        while (retorno == "") {
                          await Future.delayed(Duration(seconds: 4), () {
                            //Faz função esperar um pouco para terminar de receber dados do forEach
                            return 'Dados recebidos...';
                          });
                        }
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false);
                        ElementosInterface.caixaDialogo(
                            "Sua conta foi desativada!\nPara reativá-la basta realizar um novo login.\n\nAté logo...",
                            context);
                      }
                    }),
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

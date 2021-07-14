
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/controllers/SignInScreen.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/common/NavDrawer.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  ElementosInterface elementosInterface =
      new ElementosInterface(); //servicelocator<ElementosInterface>();//new ElementosInterface();
  TextEditingController _email = TextEditingController();
  TextEditingController _senha = TextEditingController();
  ControllerAutenticao ctrAutenticacao = ControllerAutenticao();
  ControllerUsuario _ctrUsuario = ControllerUsuario();

  ValidacaoDados _validacao = ValidacaoDados();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 40)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("assets/images/icon-app.png"),
                      height: 300.0,
                      width: 300.0,
                    ),
                  ],
                ),
                Text(
                  "Verde Vegetal",
                  style: TextStyle(fontFamily: "HachiMaruPop", fontSize: 30),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: GoogleSignInButton(),
                )
              ]))),

      drawer: NavDrawer(null), //Colocar dentro de um Future
    );
  }
}

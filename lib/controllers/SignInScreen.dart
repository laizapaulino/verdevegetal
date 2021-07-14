import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/AutenticacaoFirebase.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';
import 'package:verde_vegetal_app/view/usuario/TelaCadastroUsuario1.dart';

import 'ControllerCommon.dart';

/*
* Essa classe é a responsavel pelo botão de login do google e parte da autenticação
* */

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  _botaoLogin() async {
    setState(() {
      _isSigningIn = true;
    });

    User user = await AutenticacaoLogin.signInWithGoogle(context);


    setState(() {
      _isSigningIn = false;
    });

    if (user != null) {
      ControllerUsuario controllerUsuario = ControllerUsuario();
      ControllerAutenticao controllerAutenticao = ControllerAutenticao();
      Map resposta = null;
      resposta = await controllerUsuario.recuperaUsuarioPorEmail(user.email);
      while (resposta == null) {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      if (resposta["message"] == "Vazio") {
        //Usuario sem cadastro
        // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => TelaCadastroUsuario(user.email,
                  user.displayName, user.photoURL, user.phoneNumber)),
        );
      } else {
        //Usuario cadastrado
        Map loginSis = null;
        loginSis = await controllerAutenticao.loginUsuario(user.email);
        while (resposta == null) {
          await Future.delayed(Duration(seconds: 2), () {
            //Faz função esperar um pouco para terminar de receber dados
            return 'Dados recebidos...';
          });
        }

        if (loginSis["message"] == "Falha") {
          String aviso =
              "Não foi possivel fazer seu login, tente novamente mais tarde";
          AutenticacaoLogin.signOut(context);
        } else {
          //Verifica se o usuário estava desativado
          if (resposta["usuario"].statusConta == "inativo") {
            String retorno = "none";
            retorno = await ControllerAutenticao.ativaUsuario();
            while (retorno == "none") {
              await Future.delayed(Duration(seconds: 2), () {
                //Faz função esperar um pouco para terminar de receber dados do forEach
                return 'Dados recebidos...';
              });
            }

            loginSis = null;
            loginSis = await controllerAutenticao.loginUsuario(user.email);

            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

            ElementosInterface.caixaDialogo(
                "Bem-vindo de volta!\n\nSua conta foi reativada!", context);
          } else {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: _botaoLogin,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/images/google_logo.png"),
                      height: 25.0,
                      width: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Entrar com Google',
                        style: ControllerCommon.estiloTextoNormal(20),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';

/*
* Essa classe é a responsavel pela logica por trás da autenticação pelo google
* */

class AutenticacaoLogin {
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = null;
    firebaseApp = await Firebase.initializeApp();

    while (firebaseApp == null) {
      await Future.delayed(Duration(seconds: 2), () {
        //Faz função esperar um pouco para terminar de receber dados do forEach
        return 'Dados recebidos...';
      });
    }
    return firebaseApp;
  }

  static Future<User> signInWithGoogle(BuildContext context) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        print(21);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print(21);
          print(e.code);
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here

          print(e.code);
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

  static Future<String> signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();

        ControllerAutenticao controllerAutenticao = ControllerAutenticao();
        controllerAutenticao.deslogar();
      }
      var retorno = null;

      await FirebaseAuth.instance.signOut();
      retorno = await FirebaseAuth.instance.signInAnonymously();

      return "pronto";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        ElementosInterface.customSnackBar(
          content: 'Conecte-se a uma rede.',
        ),
      );
      return "falhei";
    }
  }
}

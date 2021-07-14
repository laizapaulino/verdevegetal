import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/view/categoria/TelaCadastroCategoria.dart';
import 'package:verde_vegetal_app/view/compra/TelaCarrinhoCompras.dart';
import 'package:verde_vegetal_app/view/compra/TelaMinhasCompras.dart';
import 'package:verde_vegetal_app/view/home/TelaInicial2.dart';
import 'package:verde_vegetal_app/view/usuario/TelaConfiguracoes.dart';
import 'package:verde_vegetal_app/view/usuario/TelaLogin.dart';
import 'package:verde_vegetal_app/view/usuario/TelaPerfilLogado.dart';

import 'controllers/AutenticacaoFirebase.dart';
import 'view/categoria/TelaSelecaoCategorias.dart';
import 'view/produto/TelaPesquisa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseApp _initialization = null;
  _initialization = await AutenticacaoLogin.initializeFirebase();

  while (_initialization == null) {
    await Future.delayed(Duration(seconds: 2), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });
  }

  FirebaseAuth auth = null;
  auth = await FirebaseAuth.instance;
  await Future.delayed(Duration(seconds: 3), () {
    //Faz função esperar um pouco para terminar de receber dados do forEach
    return 'Dados recebidos...';
  });

  if (auth.currentUser == null) {
    await auth.signInAnonymously();

    await Future.delayed(Duration(seconds: 3), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });
  }

  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      // "/cadastrarUsuario": (context) => TelaCadastroUsuario(),
      "/cadastroCategoria": (context) => TelaCadastroCategoria(),
      "/login": (context) => TelaLogin(),
      "/pesquisa": (context) => TelaPesquisa(),
      "/selecaoCategorias": (context) => TelaSelecaoCategorias(),
      "/carrinhoCompras": (context) => TelaCarrinhoCompras(),
      "/meuperfil": (context) => TelaPerfilLogado(),
      "/minhascompras": (context) => TelaMinhasCompras(),
      "/configuracao": (context) => TelaConfiguracoes(),
    },
    home: TelaInicial2(),
    debugShowCheckedModeBanner: false,
  ));
}

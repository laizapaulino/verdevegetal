import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/model/Produto.dart';
import 'package:verde_vegetal_app/model/Usuario.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeCesta.dart';
import 'package:verde_vegetal_app/view/produto/TelaExibeProduto.dart';

class funcoesComumWidget{

  static verCesta(var cesta, BuildContext context) async {
    ControllerAutenticao _controllerAutenticao = ControllerAutenticao();
    var usu = await _controllerAutenticao.recuperaLoginSalvo();
    try {
      Usuario user = usu;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeCesta(cesta, user)));
    } catch (err) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeCesta(cesta, null)));
    }
  }

  static verProduto(Produto produto, BuildContext context) async {
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();

    var usu = await _ctrAutenticacao.recuperaLoginSalvo();
    try {
      Usuario user = usu;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, user)));
    } catch (err) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaExibeProduto(produto, null)));
    }
  }

}
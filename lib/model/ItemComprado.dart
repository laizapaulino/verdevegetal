import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class ItemComprado {
  Timestamp data;
  String enderecoComprador;
  String idCompra;
  String idItemComprado;
  String idProduto;
  String imagePath;
  String nome;
  String nomeComprador;
  String nomeVendedor;
  String metodoPagamento;
  String precoUnitario;
  String status;
  int quantidade;
  int qtdPacote;
  String tokenPagamentoYapay;
  String unidadeMedida;
  String usernameComprador;
  String usernameVendedor;

  ItemComprado(
    this.data,
    this.enderecoComprador,
    this.idCompra,
    this.idItemComprado,
    this.idProduto,
    this.imagePath,
    this.nome,
    this.nomeComprador,
    this.nomeVendedor,
    this.metodoPagamento,
    this.precoUnitario,
    this.status,
    this.quantidade,
    this.qtdPacote,
    this.tokenPagamentoYapay,
    this.unidadeMedida,
    this.usernameComprador,
    this.usernameVendedor,
  );

  getItemJson() {
    return {
      "data": this.data,
      "enderecoComprador": this.enderecoComprador,
      "idCompra": this.idCompra,
      "idItemComprado": this.idItemComprado,
      "idProduto": this.idProduto,
      "imagePath": this.imagePath,
      "nome": this.nome,
      "nomeComprador": this.nomeComprador,
      "nomeVendedor": this.nomeVendedor,
      "metodoPagamento": this.metodoPagamento,
      "tokenPagamentoYapay": this.tokenPagamentoYapay,
      "precoUnitario": this.precoUnitario,
      "quantidade": this.quantidade,
      "qtdPacote": this.qtdPacote,
      "status": this.status,
      "unidadeMedida": this.unidadeMedida,
      "usernameComprador": this.usernameComprador,
      "usernameVendedor": this.usernameVendedor,
    };
  }
}

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Compra {
  //compraReferencia
  Timestamp dataCompra;
  String idCompra;
  String usernameComprador;
  String usernameVendedor;
  double valorFrete;
  int qtdProdutosComprados;
  int qtdProdutosCancelados;
  String previsaoEntrega;
  String status;

  Compra(
      this.dataCompra,
      this.idCompra,
      this.usernameComprador,
      this.usernameVendedor,
      this.valorFrete,
      this.qtdProdutosComprados,
      this.qtdProdutosCancelados,
      this.previsaoEntrega,
      this.status);

  getCompraJson() {
    return {
      "dataCompra": this.dataCompra,
      "idCompra": this.idCompra,
      "usernameComprador": this.usernameComprador,
      "usernameVendedor": this.usernameVendedor,
      "valorFrete": this.valorFrete,
      "qtdProdutosComprados": this.qtdProdutosComprados,
      "qtdProdutosCancelados": this.qtdProdutosCancelados,
      "previsaoEntrega": this.previsaoEntrega,
      "status": this.status
    };
  }
}

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  String categoria;
  String descricao;
  String id_produto;
  String imagePath;
  String nome;
  String nomeVendedor;
  String preco;
  int qtdEstoque;
  String qtdPacote;
  String status;
  String unidadeMedida;
  String usernameVendedor;
  String frete;

  Produto(
      this.categoria,
      this.descricao,
      this.id_produto,
      this.imagePath,
      this.nome,
      this.nomeVendedor,
      this.preco,
      this.qtdEstoque,
      this.qtdPacote,
      this.status,
      this.unidadeMedida,
      this.usernameVendedor);

  getProdutoJson() {
    return {
      "dataCadastro": Timestamp.fromDate(DateTime.now()),
      "categoria": this.categoria,
      "descricao": this.descricao,
      "id_produto": this.id_produto,
      "imagePath": this.imagePath,
      "filtro": this.nome.toLowerCase().split(" "),
      "nome": this.nome,
      "nomeVendedor": this.nomeVendedor,
      "preco": this.preco,
      "qtdEstoque": this.qtdEstoque,
      "qtdPacote": this.qtdPacote,
      "status": this.status,
      "unidadeMedida": this.unidadeMedida,
      "usernameVendedor": this.usernameVendedor,
    };
  }
}

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Cesta {
  String categoria;
  String descricao;
  String imagePath;
  String idCesta;
  String nome;
  String nomeVendedor;
  String preco;
  int qtdEstoque;
  String status;
  Map produtos;
  String usernameVendedor;


  Cesta(
      this.categoria,
      this.descricao,
      this.imagePath,
      this.idCesta,
      this.nome,
      this.nomeVendedor,
      this.preco,
      this.qtdEstoque,
      this.status,
      this.produtos,
      this.usernameVendedor);

  geraFiltro(){
    List filtro = [];
    filtro.addAll(this.nome.toLowerCase().split(" "));
    produtos.forEach((key, value) {print(value.toString());
      filtro.addAll(value["nomeProduto"].toLowerCase().split(" "));
    });
    return filtro;
  }

  getCestaJson() {
    return{
      "dataCadastro": Timestamp.fromDate(DateTime.now()),
      "categoria": "Cesta",
      "descricao": this.descricao,
      "idCesta":this.idCesta,
      "imagePath": this.imagePath,
      "filtro": geraFiltro(),
      "nome": this.nome,
      "nomeVendedor": this.nomeVendedor,
      "preco": this.preco,
      "produtos": this.produtos,
      "qtdEstoque": this.qtdEstoque,
      "status": this.status,
      "usernameVendedor": this.usernameVendedor

    };
  }
}

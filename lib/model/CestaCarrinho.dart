import 'dart:core';

class CestaCarrinho {
  String idCesta;
  String imagePath;
  String nome;
  String nomeComprador;
  String nomeVendedor;
  String precoTotal;
  String precoUnitario;
  int quantidade;
  Map produtos;
  String usernameComprador;
  String usernameVendedor;


  CestaCarrinho(
      this.idCesta,
      this.imagePath,
      this.nome,
      this.nomeComprador,
      this.nomeVendedor,
      this.precoTotal,
      this.precoUnitario,
      this.quantidade,
      this.produtos,
      this.usernameComprador,
      this.usernameVendedor);

  getCestaCarrinhoJson() {
    return {
      "idCesta": this.idCesta,
      "imagePath": this.imagePath,
      "nome": this.nome,
      "nomeVendedor": this.nomeVendedor,
      "precoTotal": this.precoTotal,
      "precoUnitario": this.precoUnitario,
      "quantidade": this.quantidade,
      "produtos":this.produtos,
      "usernameComprador": this.usernameComprador,
      "usernameVendedor": this.usernameVendedor,
    };
  }
}

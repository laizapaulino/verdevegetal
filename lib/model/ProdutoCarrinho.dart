import 'dart:core';

class ProdutoCarrinho {
  String idProduto;
  String imagePath;
  String nome;
  String nomeComprador;
  String nomeVendedor;
  String precoTotal;
  String precoUnitario;
  int quantidade;
  String qtdPacote;
  String unidadeMedida;
  String usernameComprador;
  String usernameVendedor;

  ProdutoCarrinho(
      this.idProduto,
      this.imagePath,
      this.nome,
      this.nomeVendedor,
      this.precoTotal,
      this.precoUnitario,
      this.quantidade,
      this.qtdPacote,
      this.unidadeMedida,
      this.usernameComprador,
      this.usernameVendedor);

  getProdutoCarrinhoJson() {
    return {
      "idProduto": this.idProduto,
      "imagePath": this.imagePath,
      "nome": this.nome,
      "nomeVendedor": this.nomeVendedor,
      "precoTotal": this.precoTotal,
      "precoUnitario": this.precoUnitario,
      "quantidade": this.quantidade,
      "qtdPacote": this.qtdPacote,
      "unidadeMedida": this.unidadeMedida,
      "usernameComprador": this.usernameComprador,
      "usernameVendedor": this.usernameVendedor,
    };
  }
}

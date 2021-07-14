import 'dart:core';

class ProdutoCesta {
  String idCesta;
  String id_produto;
  String imagePath;
  String nome;
  String nomeVendedor;
  // String preco;
  String qtdPacote;
  String unidadeMedida;
  String usernameVendedor;


  ProdutoCesta(
      this.idCesta,
      this.id_produto,
      this.imagePath,
      this.nome,
      this.nomeVendedor,
      // this.preco,
      this.qtdPacote,
      this.unidadeMedida,
      this.usernameVendedor);

  getProdutoJson() {
    return {

      "id_produto": this.id_produto,
      "idCesta": this.idCesta,
      "imagePath": this.imagePath,
      // "filtro": this.nome.toLowerCase().split(" "),
      "nome": this.nome,
      "nomeVendedor": this.nomeVendedor,
      // "preco": this.preco,
      "qtdPacote": this.qtdPacote,
      "unidadeMedida": this.unidadeMedida,
      "usernameVendedor": this.usernameVendedor,
    };
  }
}

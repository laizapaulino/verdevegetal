import 'dart:core';

class Categoria {
  String nome;
  String descricao;
  String imagem;

  Categoria(this.nome, this.descricao, this.imagem); //String imagem;

  getProdutoJson() {
    return {
      "nome": this.nome,
      "descricao": this.descricao,
      "imagem": this.imagem
    };
  }
}

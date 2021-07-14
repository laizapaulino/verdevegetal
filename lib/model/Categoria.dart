import 'dart:core';

class Categoria {
  String nome;
  String descricao;
  String imagePath;

  Categoria(this.nome, this.descricao, this.imagePath); //String imagePath;

  getProdutoJson() {
    return {
      "nome": this.nome,
      "descricao": this.descricao,
      "imagePath": this.imagePath
    };
  }
}

import 'dart:core';

class Carrinho {
  Map produtosAdicionados;
  Carrinho(this.produtosAdicionados);

  getCarrinhoJson() {
    return {"produtosAdicionados": this.produtosAdicionados};
  }
}

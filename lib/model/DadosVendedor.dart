import 'dart:core';

class DadosVendedor {
  String usernameVendedor;
  String emailYapay;
  String cpfYapay;
  String cnpjYapay;
  bool pagamentoEntregaDinheiro;
  bool pagamentoEntregaCartao;
  bool pagamentoOnline;
  Map frete;

  DadosVendedor(
      this.usernameVendedor,
      this.emailYapay,
      this.cpfYapay,
      this.cnpjYapay,
      this.pagamentoEntregaDinheiro,
      this.pagamentoEntregaCartao,
      this.pagamentoOnline,
      this.frete);

  bool getTemAoMenos1Metodo() {
    if (this.pagamentoEntregaCartao == true ||
        this.pagamentoEntregaDinheiro == true ||
        this.pagamentoOnline == true) {
      return true;
    } else {
      return false;
    }
  }

  getDadosPagamento(String tipo) {
    if (tipo == "entrega") {
      return "${this.pagamentoEntregaCartao == true && this.pagamentoEntregaDinheiro == true ? "Cartão de crédito e dinheiro" : this.pagamentoEntregaCartao == true && this.pagamentoEntregaDinheiro == false ? "Cartão de crédito" : this.pagamentoEntregaCartao == false && this.pagamentoEntregaDinheiro == true ? "Dinheiro" : "Não perimitido"}";
    }
    if (tipo == "online") {
      return "${this.pagamentoOnline == true ? "Cartão de crédito" : "Não permitido"}";
    }
    return "";
  }

  getListaOpcoesPagamento() {
    List lista = [];
    if (this.pagamentoEntregaDinheiro) {
      lista.add("Entrega - Dinheiro");
    }
    if (this.pagamentoEntregaCartao) {
      lista.add("Entrega - Cartão de crédito");
    }
    if (this.pagamentoOnline) {
      lista.add("Pagamento online - Yapay");
    }
    return lista;
  }

  getDadosVendedorJson() {
    return {
      "usernameVendedor": this.usernameVendedor,
      "emailYapay": this.emailYapay,
      "cpfYapay": this.cpfYapay,
      "cnpjYapay": this.cnpjYapay,
      "pagamentoEntregaDinheiro": this.pagamentoEntregaDinheiro,
      "pagamentoEntregaCartao": this.pagamentoEntregaCartao,
      "pagamentoOnline": this.pagamentoOnline,
      "frete": this.frete,
    };
  }
}

import 'dart:core';

class FreteVendedor {
  // Exemplo de localidade
  // var a = {
  //   "MG": {
  //     "Itajubá": {"padrão": 5.00, "Cruzeiro": 7.00}
  //   }
  // };

  String usernameVendedor;
  Map localidades;

  FreteVendedor(this.usernameVendedor, this.localidades);

  getLocalidadeFormatada() {
    String fretes = "";
    localidades.forEach((key, value) {
      fretes += "${key}:";
      localidades[key].forEach((key2, value) {
        fretes += "\n  • ${key2} - R\$${value}";
      });
      fretes += "\n";
    });

    return fretes;
  }

  getFreteVendedorJson() {
    return {
      "usernameVendedor": this.usernameVendedor,
      "localidades": this.localidades
    };
  }
}

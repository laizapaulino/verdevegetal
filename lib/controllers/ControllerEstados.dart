import 'package:verde_vegetal_app/model/Estados.dart';
/*
* Essa classe serve para gerar a lista de estados e lista de cidades de um estados
* para serem selecionados na escolha do frete
* */

class ControllerEstados {
  static List<String> formataListaEstados() {
    List<String> estados = [""];
    Estados.estados_cidades.forEach((element) {
      estados.add(element["sigla"]);
    });
    return estados;
  }

  static List<String> formataListaCidades(String estado) {
    List<String> cidades = [""];
    for (final element in Estados.estados_cidades) {
      if (element["sigla"] == estado) {
        cidades.addAll(element["cidades"]);

        break;
      }
    }
    return cidades;
  }
}

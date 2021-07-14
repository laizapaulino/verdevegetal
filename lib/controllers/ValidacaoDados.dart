import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';

class ValidacaoDados {
  bool cpfCnpjValidator(String numberId, String _cpfCnpj, bool _validador) {
    double primeiro_valor = 0;
    double segundo_valor = 0;
    int decrescente = 0;
    print(numberId);
    //Validação de cpf
    if (_cpfCnpj == "cpf" && numberId.length == 11) {
      decrescente = numberId.length - 1;

      //valida primeiro digito
      for (int i = 0; i < 9; i++) {
        //print("${numberId[i]} * $decrescente");
        primeiro_valor += int.parse(numberId[i]) * decrescente;
        decrescente--;
      }
      primeiro_valor = primeiro_valor * 10 % 11;
      primeiro_valor = primeiro_valor == 10 ? 0 : primeiro_valor;
      //print( primeiro_valor == double.parse(numberId[9])? 'cpf valido $primeiro_valor ${numberId[9]}' :'cpf não valido $primeiro_valor ${numberId[9]}');

      //valida segundo digito
      decrescente = numberId.length;
      for (int i = 0; i < 10; i++) {
        segundo_valor += int.parse(numberId[i]) * decrescente;
        decrescente--;
      }

      segundo_valor = segundo_valor * 10 % 11;
      segundo_valor = segundo_valor == 10 ? 0 : segundo_valor;
      //print( segundo_valor == double.parse(numberId[10])? 'cpf valido $segundo_valor ${numberId[10]}' :'cpf não valido $segundo_valor ${numberId[10]}');

      if (primeiro_valor == numberId[9] && segundo_valor == numberId[10]) {
        _validador = true;
      }
      //4[0]5[1]4[2].4[3]6[4]2[5].7[6]9[7]8[8]-9[9]9[10]
    }

    if (_cpfCnpj == "cnpj" && numberId.length == 14) {
      decrescente = 9;

      for (int i = 4; i < 13; i++) {
        //print("${numberId[i]} * $decrescente");
        primeiro_valor += int.parse(numberId[i]) * decrescente;
        if (decrescente <= 5) {
          primeiro_valor += int.parse(numberId[5 - decrescente]) * decrescente;
        }

        decrescente--;
      }
      primeiro_valor = 11 - primeiro_valor % 11;
      if (primeiro_valor == double.parse(numberId[12])) {
        _validador = true;
      }
      print(" $primeiro_valor ${numberId[12]}");
    }
    //Validação de cnpj

    return _validador;
  }

  var retornoCep;

  Future<Map> buscaCep(String cep) async {
    String _url = 'https://viacep.com.br/ws/${cep}/json';
    try {
      http.Response response = await http.get(_url);
      this.retornoCep = json.decode(response.body);

      return json.decode(response.body);
    } catch (err) {
      return null;
    }
  }

  Future<dynamic> validaVendedorYapay(String email) async {
    print("validaVendedorYapay");
    String _url =
        'https://api.intermediador.yapay.com.br/v1/people/get_person_by_cpf_and_email';
    Map body = {'email': email};
    try {
      http.Response response = await http.post(_url, body: body);
      final myTransformer = Xml2Json();
      myTransformer.parse(response.body);

      print(myTransformer.toGData().runtimeType);
      var resp = json.decode(myTransformer.toGData());

      Map<String, String> respostaAPI = {
        "message": resp["people"]["message_response"]["message"]["\$t"],
      };

      if (resp["people"]["message_response"]["message"]["\$t"] == "success") {
        respostaAPI.addAll({
          "email": resp["people"]["data_response"]["email"]["\$t"],
          "nome": resp["people"]["data_response"]["name"]["\$t"],
          "cpf": resp["people"]["data_response"]["cpf"]["\$t"],
          "cnpj": resp["people"]["data_response"]["cnpj"]["\$t"]
        });
      }

      print(respostaAPI);
      return respostaAPI;
    } catch (err) {
      print(err);
      return {"message": err};
    }
  }

  requistaCep(String cep) {
    var response = buscaCep(cep);
    print(retornoCep.toString());
    return retornoCep;
  }

  validaCamposPreenchidos(Map<String, String> campos) {
    String camposNaoPreenchidos = "";
    int i = 0;
    campos.forEach((key, value) {
      if (value == "") {
        i++;
        camposNaoPreenchidos += "${key}";
        camposNaoPreenchidos += i == campos.length ? " " : ", ";
      }
    });
    return camposNaoPreenchidos;
  }

  recuperaDadosLogado() async {
    final prefs = await SharedPreferences.getInstance();
    // [0]:nome
    // [1]:email
    // [2]:tipoConta
    // [3]:cpf
    // [4]:cnpj
    // [5]:"",
    // [6]:cep
    // [7]:logradouro
    // [8]:num
    // [9]:cidade
    // [10]:estado
    // [11]:complemento
    // [12]:username
    final usu = prefs.getStringList("usuario");
    // if (usu == null) {
    //   Usuario usuario = Usuario(usu[0], usu[1], usu[2], usu[3], usu[4], "",
    //       usu[6], usu[7], usu[8], usu[9], usu[10], usu[11], usu[12]);
    //   print(usuario.getUsuarioJson().toString());
    // }
  }
}

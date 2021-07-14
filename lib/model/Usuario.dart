import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String bairro;
  String cep;
  String cidade;
  String cnpj;
  String complemento;
  String cpf;
  Timestamp dataCadastro;
  String email;
  String estado;
  String imagePath;
  String logradouro;
  String nome;
  String num;
  String senha; //criptografada
  String telefone;
  String tipoConta;
  String statusConta;
  String username;

  Usuario(
      this.bairro,
      this.cep,
      this.cidade,
      this.cnpj,
      this.complemento,
      this.cpf,
      this.dataCadastro,
      this.email,
      this.estado,
      this.imagePath,
      this.logradouro,
      this.nome,
      this.num,
      this.senha,
      this.statusConta,
      this.telefone,
      this.tipoConta,
      this.username);

  String getEndereco() {
    return "${this.logradouro} - ${this.num} \n${this.bairro}, ${this.cidade} - ${this.estado}\n${this.complemento}";
  }

  String getEnderecoDiscreto() {
    return "${this.bairro}, ${this.cidade} - ${this.estado}";
  }

  getUsuarioJson() {
    return {
      "bairro": this.bairro,
      "cep": this.cep,
      "cidade": this.cidade,
      "cnpj": this.cnpj,
      "complemento": this.complemento,
      "cpf": this.cpf,
      "dataCadastro": this.dataCadastro,
      "email": this.email,
      "estado": this.estado,
      "imagePath": this.imagePath,
      "logradouro": this.logradouro,
      "nome": this.nome,
      "num": this.num,
      "senha": this.senha,
      "statusConta": this.statusConta,
      "telefone": this.telefone,
      "tipoConta": this.tipoConta,
      "username": this.username
    };
  }
}

import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/AutenticacaoFirebase.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/view/venda/TelaMinhaLoja.dart';

class NavDrawer extends StatelessWidget {
  var _logado;
  List _opcoes;

  _menuNavDrawer(String escolha, BuildContext context) {
    switch (escolha) {
      case 'Login/Cadastrar':
        Navigator.pushNamed(context, "/login");
        break;

      case 'Meu Perfil':
        Navigator.pushNamed(context, "/meuperfil");
        break;

      case 'Inicio':
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        break;

      case 'Minha Loja':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TelaMinhaLoja()));
        break;

      case 'Categorias':
        Navigator.pushNamed(context, "/selecaoCategorias");

        break;
      case 'Meus Pedidos':
        Navigator.pushNamed(context, "/minhascompras");

        break;
      case 'Configurações':
        Navigator.pushNamed(context, "/configuracao");
        break;

      case 'Cadastrar categoria':
        Navigator.pushNamed(context, "/cadastroCategoria");
        break;

      case 'Sair':
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        break;
    }
    print(escolha);
  }

  NavDrawer(var logado) {
    _logado = logado;
    try {
      // print("Essa conta é: ${_logado.tipoConta}");
      if (logado.username.contains("admin")) {
        _opcoes = [
          {""},
          {"nome": "Inicio", "icon": Icon(Icons.home)},
          {"nome": "Cadastrar categoria", "icon": Icon(Icons.add_box_sharp)},
          {
            "nome": "Meu Perfil",
            "icon": Icon(
              Icons.account_circle,
              color: Colors.cyan,
            )
          },
          {"nome": "Minha Loja", "icon": Icon(Icons.account_balance_outlined)},
          {
            "nome": "Meus Pedidos",
            "icon": Icon(
              Icons.attach_money_sharp,
              color: Colors.yellow,
            )
          },
          {
            "nome": "Categorias",
            "icon": Icon(
              Icons.storage,
              color: Colors.teal,
            )
          },
          {
            "nome": "Configurações",
            "icon": Icon(
              Icons.settings,
              color: Colors.black54,
            )
          },
          {
            "nome": "Sair",
            "icon": Icon(
              Icons.exit_to_app,
              color: Colors.indigo,
            )
          }
        ];
      } else if (logado.tipoConta == "Vendedor") {
        print("Sou vendedor");
        _opcoes = [
          {""},
          {
            "nome": "Inicio",
            "icon": Icon(
              Icons.home,
              color: Colors.green,
            )
          },
          {
            "nome": "Meu Perfil",
            "icon": Icon(
              Icons.account_circle,
              color: Colors.cyan,
            )
          },
          {
            "nome": "Minha Loja",
            "icon": Icon(
              Icons.account_balance_outlined,
              color: Colors.lightGreen,
            )
          },
          {
            "nome": "Meus Pedidos",
            "icon": Icon(
              Icons.attach_money_sharp,
              color: Colors.yellow,
            )
          },
          {
            "nome": "Categorias",
            "icon": Icon(
              Icons.storage,
              color: Colors.teal,
            )
          },
          {
            "nome": "Configurações",
            "icon": Icon(
              Icons.settings,
              color: Colors.black54,
            )
          },
          {
            "nome": "Sair",
            "icon": Icon(
              Icons.exit_to_app,
              color: Colors.indigo,
            )
          }
        ];
      } else {
        print("Sou cliente");
        _opcoes = [
          {""},
          {
            "nome": "Inicio",
            "icon": Icon(
              Icons.home,
              color: Colors.green,
            )
          },
          {
            "nome": "Meu Perfil",
            "icon": Icon(
              Icons.account_circle,
              color: Colors.cyan,
            )
          },
          {
            "nome": "Meus Pedidos",
            "icon": Icon(
              Icons.attach_money_sharp,
              color: Colors.yellow,
            )
          },
          {
            "nome": "Categorias",
            "icon": Icon(
              Icons.storage,
              color: Colors.teal,
            )
          },
          {
            "nome": "Configurações",
            "icon": Icon(
              Icons.settings,
              color: Colors.black54,
            )
          },
          {
            "nome": "Sair",
            "icon": Icon(
              Icons.exit_to_app,
              color: Colors.indigo,
            )
          }
        ];
      }
    } catch (err) {
      print("Sou deslogado");
      print(err.toString());

      _opcoes = [
        {
          "nome": "Login/Cadastrar",
          "icon": Icon(
            Icons.verified_user,
            color: Colors.indigo,
          )
        },
        {
          "nome": "Inicio",
          "icon": Icon(
            Icons.home,
            color: Colors.green,
          )
        },
        {
          "nome": "Categorias",
          "icon": Icon(
            Icons.storage,
            color: Colors.teal,
          )
        },
        {
          "nome": "Sair",
          "icon": Icon(
            Icons.exit_to_app,
            color: Colors.indigo,
          )
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView.builder(
            itemCount: _opcoes.length,
            itemBuilder: (context, indice) {
              if (_opcoes[indice].toString() == "{}") {
                return DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text("Olá, ${_logado.nome} ",
                              style: ControllerCommon.estiloTexto(
                                  "titulo", Colors.white)),
                        )
                      ],
                    ));
              }
              // print(_opcoes[0].toString());
              else {

                return ListTile(
                    onTap: () async {
                      if (_opcoes[indice]["nome"] == "Sair") {
                        String retorno = "";

                        retorno = await AutenticacaoLogin.signOut(context);

                        while (retorno == "") {
                          await Future.delayed(Duration(seconds: 4), () {
                            //Faz função esperar um pouco para terminar de receber dados do forEach
                            return 'Dados recebidos...';
                          });
                        }
                      }
                      _menuNavDrawer(
                          _opcoes[indice]["nome"].toString(), context);
                    },
                    onLongPress: () {},
                    title: Text(
                      " ${_opcoes[indice]["nome"].toString()}",
                      style: ControllerCommon.estiloTexto(
                          "normal negrito", Colors.black),
                    ),
                    leading: _opcoes[indice]["icon"]);
              }
            }));
  }
}

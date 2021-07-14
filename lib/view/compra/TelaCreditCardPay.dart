import 'package:credit_card/credit_card_form.dart';
import 'package:credit_card/credit_card_model.dart';
import 'package:credit_card/flutter_credit_card.dart';
import 'package:flutter/material.dart';
import 'package:verde_vegetal_app/controllers/ControllerAutenticacao.dart';
import 'package:verde_vegetal_app/controllers/ControllerCommon.dart';
import 'package:verde_vegetal_app/controllers/ValidacaoDados.dart';
import 'package:verde_vegetal_app/view/common/ElementosInterface.dart';

import 'TelaMinhasCompras.dart';

/*
* Essa tela serve para preenchimento dos dados do cartão de crédito,
* deve ser usada em conjunto com a integração da API de pagamentos online
* */

class TelaCreditCardPay extends StatefulWidget {
  List listaProdutos;
  double valorTotal;
  var usuario;
  String endereco;
  DateTime now;
  String idCompra;

  TelaCreditCardPay(this.listaProdutos, this.valorTotal, this.usuario,
      this.endereco, this.now, this.idCompra);

  @override
  State<StatefulWidget> createState() {
    return TelaCreditCardPayState();
  }
}

class TelaCreditCardPayState extends State<TelaCreditCardPay> {
  ValidacaoDados _validacaoDados = ValidacaoDados();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool botaoAtivado = true;

  finalizaCompraOnline() async {
    ControllerAutenticao _ctrAutenticacao = ControllerAutenticao();
    var _usuario = await _ctrAutenticacao.recuperaLoginSalvo();
    String camposVazios = _validacaoDados.validaCamposPreenchidos({
      "Número do cartão": cardNumber,
      "Data de vencimento": expiryDate,
      "Nome do titular": cardHolderName,
      "CVV": cvvCode,
    });

    if (camposVazios != "") {
      String aviso = "Preencha $camposVazios";
      ElementosInterface.caixaDialogo(aviso, context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => Container(
                  child: SimpleDialog(
                children: [
                  Center(
                    child: Container(
                      height: 70.0,
                      width: 70.0,
                      child: CircularProgressIndicator(
                          // backgroundColor: Colors.cyan,
                          ),
                    ),
                  )
                ], // The content inside the dialog
              )));

      List mesAno = expiryDate.split("/");
      Map pagamento = {
        "payment_method_id": "3",
        "card_name": cardHolderName,
        "card_number": cardNumber.replaceAll(" ", ""),
        "card_expdate_month": mesAno[0],
        "card_expdate_year": "20" + mesAno[1].toString(),
        "card_cvv": cvvCode,
        "split": "1"
      };
      String retorno = "none";

      // retorno = await ControllerVenda().cadastraCompraOnline(
      //     widget.listaProdutos,
      //     widget.endereco,
      //     widget.valorTotal,
      //     widget.now,
      //     pagamento,
      //     _usuario,
      //     widget.idCompra);

      while (retorno == "none") {
        await Future.delayed(Duration(seconds: 2), () {
          //Faz função esperar um pouco para terminar de receber dados do forEach
          return 'Dados recebidos...';
        });
      }

      if (retorno == "FALHOU") {
        ElementosInterface.caixaDialogo(
            "Não consegui finalizar a compra, sinto muito", context);
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TelaMinhasCompras()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElementosInterface.barra(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              // cardBgColor: Colors.grey,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: CreditCardForm(
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
            ),
            TextButton(
                onPressed: botaoAtivado == true
                    ? () {
                        setState(() {
                          print("----------------------");
                          print("desativa");
                          botaoAtivado = false;
                        });

                        finalizaCompraOnline();
                      }
                    : null, //_comprarProdutos

                child: Text(
                  "Finalizar compra",
                  style: ControllerCommon.estiloTexto("normal negrito",
                      botaoAtivado == true ? Colors.black : Colors.grey),
                ))
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName.toUpperCase();
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

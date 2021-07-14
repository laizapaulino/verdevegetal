import 'package:verde_vegetal_app/controllers/ControllerUsuario.dart';

class Email {
  static sendRegistrationNotification(
      String assunto, String body, String username) async {
    var usuario =
        await ControllerUsuario().recuperaUsuarioPorUsername(username);
    await Future.delayed(Duration(seconds: 5), () {
      //Faz função esperar um pouco para terminar de receber dados do forEach
      return 'Dados recebidos...';
    });

    try {
      Map<String, String> headers = new Map();
      headers["Authorization"] = "Bearer ";
      headers["Content-Type"] = "application/json";

      var url = 'https://api.sendgrid.com/v3/mail/send';
      //Nessa parte realiza-se a chamada a API de envio de email - sendgrid
      //Deve-se passar o email institucional que foi previamente cadastrado na plataforma
      /*
      var response = await http.post(url,
          headers: headers,
          body:
              '{"personalizations": [{"to": [{"email": "${usuario.email}"}]}],"from": {"email": "seuemail@dominio.gov"},"subject": "${assunto}","content": [{"type": "text/html", "value": "${body}"}]}');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    */
    } catch (err) {
      print(err);
    }
  }
}

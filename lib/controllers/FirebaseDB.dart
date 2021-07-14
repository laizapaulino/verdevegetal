import 'package:cloud_firestore/cloud_firestore.dart';
/*
* Essa classe é uma "facilitadora" para caso a sintaxe do firebase mude
* a refatoração seja centralizada.
* Além de que facilitou para saber o tipo de consulta que cada parte faz
* */
class FirebaseDB {
  static Future<QuerySnapshot> findQuery(
      String nomeColection, String parametro, String valorParametro) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro, isEqualTo: valorParametro)
        .get();

    return querySnapshot;
  }

  static Future<QuerySnapshot> findQueryFiltroContains(
      String nomeColection,
      String parametro1,
      String valorParametro1,
      String parametro2,
      List valorParametroArray) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro1, isEqualTo: valorParametro1)
        .where(parametro2, arrayContainsAny: valorParametroArray)
        .get();

    return querySnapshot;
  }

  static Future<QuerySnapshot> findQueryLimit(String nomeColection,
      String parametro, String valorParametro, int limit) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro, isEqualTo: valorParametro)
        .limit(limit)
        .get();

    return querySnapshot;
  }

  static Future<QuerySnapshot> findQueryLimit2Where(
      String nomeColection,
      String parametro1,
      String valorParametro1,
      String parametro2,
      String valorParametro2,
      int limit) async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro1, isEqualTo: valorParametro1)
        .where(parametro2, isEqualTo: valorParametro2)
        .limit(limit)
        .get();

    return querySnapshot;
  }

  static Future<QuerySnapshot> findQuery2Where(
      String nomeColection,
      String parametro1,
      String valorParametro1,
      String parametro2,
      String valorParametro2) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro1, isEqualTo: valorParametro1)
        .where(parametro2, isEqualTo: valorParametro2)
        .get();

    return querySnapshot;
  }

  static Future<QuerySnapshot> findQuery2WhereOrderBy(
      String nomeColection,
      String parametro1,
      String valorParametro1,
      String parametro2,
      String valorParametro2,
      String orderParam,
      bool descending) async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(nomeColection)
        .where(parametro1, isEqualTo: valorParametro1)
        .where(parametro2, isEqualTo: valorParametro2)
        .get();

    return querySnapshot;
  }

  static Future save(String nomeColection, Map dadoJson) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(nomeColection);
    await collectionReference.add(dadoJson);
  }

  static Future delete(
      String nomeColection, String idDocumento) async {

    await FirebaseFirestore.instance
        .collection(nomeColection)
        .doc(idDocumento)
        .delete();
  }

  static Future update(
      String nomeColection, String idDocumento, Map dadoAtualizaJson) async {
    await FirebaseFirestore.instance
        .collection(nomeColection)
        .doc(idDocumento)
        .update(dadoAtualizaJson);
  }
}

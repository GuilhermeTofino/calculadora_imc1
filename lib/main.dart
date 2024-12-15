// ignore_for_file: prefer_const_constructors

import 'package:calculadora_imc/database_helper.dart';
import 'package:flutter/material.dart';

class PesoApp extends StatefulWidget {
  const PesoApp({super.key});

  @override
  _PesoAppState createState() => _PesoAppState();
}

class _PesoAppState extends State<PesoApp> {
  TextEditingController pesoController = TextEditingController();
  TextEditingController alturaController = TextEditingController();

  void _calcularIMC() async {
    double peso = double.tryParse(pesoController.text) ?? 0.0;
    double altura = double.tryParse(alturaController.text) ?? 0.0;

    if (peso <= 0 || altura <= 0) {
      _mostrarErro("Peso e altura devem ser maiores que zero.", context);
      return;
    }
    double imc = peso / (altura * altura);
    String classificacao = _classificarIMC(imc);

    try {
      await DatabaseHelper.instance.insert({
        DatabaseHelper.columnPeso: peso,
        DatabaseHelper.columnAltura: altura,
        DatabaseHelper.columnImc: imc,
        DatabaseHelper.columnClassificacao: classificacao,
      });

      pesoController.clear();
      alturaController.clear();

      setState(() {});
    } catch (e) {
      print("Erro ao salvar os dados.: $e");
      _mostrarErro("Erro ao salvar os dados.", context);
    }
  }

  String _classificarIMC(double imc) {
    if (imc < 16) {
      return "Magreza grave";
    } else if (imc < 17) {
      return "Magreza moderada";
    } else if (imc < 18.5) {
      return "Magreza leve";
    } else if (imc < 25) {
      return "Saudável";
    } else if (imc < 30) {
      return "Sobrepeso";
    } else if (imc < 35) {
      return "Obesidade Grau 1";
    } else if (imc < 40) {
      return "Obesidade Grau 2 (Severa)";
    } else {
      return "Obesidade Grau 3 (Mórbida)";
    }
  }

  void _mostrarErro(String mensagem, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erro"),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Peso (kg)"),
            ),
            TextField(
              controller: alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Altura (m)"),
            ),
            ElevatedButton(
              onPressed: _calcularIMC,
              child: const Text("Calcular"),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.instance.queryAllRows(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              "Peso: ${snapshot.data![index][DatabaseHelper.columnPeso].toStringAsFixed(2)} kg, Altura: ${snapshot.data![index][DatabaseHelper.columnAltura].toStringAsFixed(2)} m"),
                          subtitle: Text(
                              "IMC: ${snapshot.data![index][DatabaseHelper.columnImc].toStringAsFixed(2)} - ${snapshot.data![index][DatabaseHelper.columnClassificacao]}"),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("Erro: ${snapshot.error}");
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

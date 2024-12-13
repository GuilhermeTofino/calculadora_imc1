// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: PesoApp(),
  ));
}

class PesoApp extends StatefulWidget {
  const PesoApp({super.key});

  @override
  _PesoAppState createState() => _PesoAppState();
}

class _PesoAppState extends State<PesoApp> {
  List<Peso> pesos = [];
  TextEditingController pesoController = TextEditingController();
  TextEditingController alturaController = TextEditingController();

  void _calcularIMC() {
    double peso = double.tryParse(pesoController.text) ?? 0.0;
    double altura = double.tryParse(alturaController.text) ?? 0.0;

    if (peso <= 0 || altura <= 0) {
      _mostrarErro("Peso e altura devem ser maiores que zero.");
      return;
    }
    double imc = peso / (altura * altura);  
    String classificacao = _classificarIMC(imc);

    setState(() {
      pesos.add(Peso(peso: peso, altura: altura, imc: imc, classificacao: classificacao));
      pesoController.clear();
      alturaController.clear();
    });
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

  void _mostrarErro(String mensagem) {
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
              child: ListView.builder(
                itemCount: pesos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Peso: ${pesos[index].peso.toStringAsFixed(2)} kg, Altura: ${pesos[index].altura.toStringAsFixed(2)} m"),
                    subtitle: Text("IMC: ${pesos[index].imc.toStringAsFixed(2)} - ${pesos[index].classificacao}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Peso {
  double peso;
  double altura;
  double imc;
  String classificacao;

  Peso({required this.peso, required this.altura, required this.imc, required this.classificacao});
}

import 'package:despesa_digital/database/gasto_db.dart';
import 'package:despesa_digital/model/gasto_fixo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:despesa_digital/controller/utils.dart';

class AdicionarGastoPage extends StatefulWidget {
  @override
  _AdicionarGastoPageState createState() => _AdicionarGastoPageState();
}

class _AdicionarGastoPageState extends State<AdicionarGastoPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Gasto'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto e data selecionada
            String titulo = _tituloController.text;
            double valor = double.parse(_valorController.text);

            // Criando a nova meta no banco de dados
            await GastoDB().create(
              titulo: titulo,
              valor: valor,
            );
            // Fechando o AlertDialog após adicionar a meta
            Navigator.of(context).pop(true);
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}

class GastoController {
  final GastoDB _gastoDB = GastoDB();

  // Método para exibir os detalhes da meta em uma caixa de diálogo
  void mostrarDetalhesGasto(BuildContext context, GastoFixo gasto, VoidCallback atualizarGastos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _gastoDB.getPaymentDetails(gasto.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text(gasto.titulo),
                content: Center(child: CircularProgressIndicator()),
              );
            }

            bool paymentMade = snapshot.data?['paymentMade'] ?? false;
            DateTime? paymentDate = snapshot.data?['paymentDate'];
            String formattedDate = paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate) : '';

            return AlertDialog(
              title: Text(gasto.titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Valor: R\$${gasto.valor.toStringAsFixed(2)}'),
                  if (paymentMade)
                    Text('Já houve um pagamento desta conta no dia $formattedDate'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    // Chamar a função de excluir meta e atualizar a lista de metas
                    await _gastoDB.delete(gasto.id);
                    // Fechar a caixa de diálogo
                    Navigator.of(context).pop();
                    // Atualizar a lista de metas na página
                    atualizarGastos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gasto excluído com sucesso!')),
                    );
                  },
                  child: Text('Excluir'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fechar a caixa de diálogo
                  },
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para construir um ListTile para exibir uma meta
  Widget construirGastoListTile(BuildContext context, GastoFixo gasto, VoidCallback atualizarGastos) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesGasto(context, gasto, atualizarGastos);
      },
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<bool>(
            future: _gastoDB.isPaymentMadeThisMonth(gasto.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              bool paymentMade = snapshot.data ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      gasto.titulo.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('R\$${gasto.valor.toStringAsFixed(2)}'),
                      paymentMade
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.error, color: Colors.red),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

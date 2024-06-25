import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/conta_db.dart';
import '../model/conta.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class AdicionarContaPage extends StatefulWidget {

  final VoidCallback onAdd;
  AdicionarContaPage({required this.onAdd});

  @override
  _AdicionarContaPageState createState() => _AdicionarContaPageState();
}

class _AdicionarContaPageState extends State<AdicionarContaPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Conta'),
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
            // Obtendo os valores dos campos de texto
            String titulo = _tituloController.text;
            double valor = double.parse(_valorController.text);

            // Criando o novo gasto no banco de dados
            await ContaDB().create(
              titulo: titulo,
              valor: valor,
            );
            // Fechando o AlertDialog após adicionar a conta
            widget.onAdd(); // Chama o callback para atualizar a lista
            Navigator.of(context).pop(true);
          },
          child: Text('Adicionar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
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

class ContaController {
  final ContaDB _contaDB = ContaDB();

  // Método para exibir os detalhes da meta em uma caixa de diálogo
  void mostrarDetalhesGasto(BuildContext context, Conta conta, VoidCallback atualizarGastos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _contaDB.getPaymentDetails(conta.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text(conta.titulo),
                content: Center(child: CircularProgressIndicator()),
              );
            }

            bool paymentMade = snapshot.data?['paymentMade'] ?? false;
            DateTime? paymentDate = snapshot.data?['paymentDate'];
            String formattedDate = paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate) : '';

            return AlertDialog(
              title: Text(conta.titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Valor: R\$${NumberFormat("#,##0.00", "pt_BR").format(conta.valor)}'),
                  if (paymentMade)
                    Text('Esse mês já houve um pagamento desta conta no dia $formattedDate'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    // Chamar a função de excluir meta e atualizar a lista de metas
                    await _contaDB.delete(conta.id);
                    // Fechar a caixa de diálogo
                    Navigator.of(context).pop();
                    // Atualizar a lista de metas na página
                    atualizarGastos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conta excluída com sucesso!')),
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
  Widget construirGastoListTile(BuildContext context, Conta conta, VoidCallback atualizarGastos) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesGasto(context, conta, atualizarGastos);
      },
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.purplelightMain, width: 2.0),
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: AppColors.white,
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _contaDB.getPaymentDetails(conta.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  title: Text(conta.titulo),
                  content: Center(child: CircularProgressIndicator()),
                );
              }
              bool paymentMade = snapshot.data?['paymentMade'] ?? false;
              DateTime? paymentDate = snapshot.data?['paymentDate'];
              String formattedDate = paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate) : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conta.titulo.toUpperCase(),
                          style: AppTextStyles.cardheaderText,
                        ),
                      ),
                      Text(
                        'R\$${NumberFormat("#,##0.00", "pt_BR").format(conta.valor)}',
                        style: AppTextStyles.cardheaderText,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paymentMade
                                  ? 'Já houve um pagamento para esta conta no dia $formattedDate'
                                  : 'Não houve pagamento para esta conta esse mês',
                            ),
                          ],
                        ),
                      ),
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

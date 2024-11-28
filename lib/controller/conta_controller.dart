import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/controller/real.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/conta_db.dart';
import '../database/database_service.dart';
import '../model/conta.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/moeda_formatter.dart';

Real _real = Real();
var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Permite apenas números e ponto decimal
                MoedaTextInputFormatter(), // Permite apenas números e ponto decimal
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto
            String titulo = _tituloController.text;
            String valorTexto = _valorController.text;

            // Verificar se o título foi inserido
            if (titulo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título da conta.')),
              );
              return;
            }

            try {
              // Remove o prefixo "R$" e outros caracteres não numéricos
              String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
              print(valorTexto);
              print(valorLimpo);

              // Parse do valor
              double valor = _real.parseValor(valorLimpo);

              // Criando o novo gasto no banco de dados (sem await)
              ContaDB().create(
                titulo: titulo,
                valor: valor,
              );

              if (connectivityResult != ConnectivityResult.none) {
                // Faz a sincronização se estiver online
                await databaseService.syncContaToFB();
              } else {
              }

              // Fechando o AlertDialog após adicionar a conta
              widget.onAdd(); // Chama o callback para atualizar a lista
              Navigator.of(context).pop(true);
            } catch (e) {
              print('Erro ao adicionar a conta: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar a conta. Verifique os valores inseridos.')),
              );
            }
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
                  onPressed: () {
                    excluirConta(context, conta, atualizarGastos);
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

  void excluirConta(BuildContext context, Conta conta, VoidCallback atualizarGastos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Conta'),
          content: Text(
            'Você tem certeza que deseja excluir a conta "${conta.titulo}"? Essa ação não poderá ser desfeita.',
          ),
          actions: <Widget>[

            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o modal antes de iniciar a exclusão
                try {
                  // Chama o método de exclusão da conta
                  ContaDB().delete(conta.id);

                  // Atualiza a lista de contas
                  atualizarGastos();

                  // Exibe mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Conta "${conta.titulo}" excluída com sucesso!')),
                  );
                } catch (e) {
                  // Exibe mensagem de erro em caso de falha
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir a conta: $e')),
                  );
                }
              },
              child: Text('Excluir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal de confirmação
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }


}

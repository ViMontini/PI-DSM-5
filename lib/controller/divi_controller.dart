import 'package:flutter/material.dart';

// Função para abrir um modal para adicionar uma nova movimentação monetária
typedef void AdicionarMovimentacaoCallback(double valor, String descricao);

void abrirModalAdicionarDivida(BuildContext context, AdicionarMovimentacaoCallback onAdicionarMovimentacao) {
  TextEditingController valorController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adicionar Dívida',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor',
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                double valor = double.tryParse(valorController.text) ?? 0.0;
                String descricao = descricaoController.text;
                if (valor != 0.0 && descricao.isNotEmpty) {
                  Navigator.pop(context);
                  onAdicionarMovimentacao(valor, descricao);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, preencha todos os campos.'),
                    ),
                  );
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        ),
      );
    },
  );
}
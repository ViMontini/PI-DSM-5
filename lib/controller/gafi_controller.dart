

// Função para abrir um modal para adicionar uma nova meta
import 'package:flutter/material.dart';

typedef void AdicionarMetaCallback(String titulo, String descricao);

void abrirModalAdicionarGastoFixo(BuildContext context, AdicionarMetaCallback onAdicionarMeta) {
  TextEditingController tituloController = TextEditingController();
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
              'Adicionar Gasto Fixo',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
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
                String titulo = tituloController.text;
                String descricao = descricaoController.text;
                if (titulo.isNotEmpty && descricao.isNotEmpty) {
                  Navigator.pop(context);
                  onAdicionarMeta(titulo, descricao);
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
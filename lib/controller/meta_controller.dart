import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/controller/real.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_service.dart';
import '../database/meta_db.dart';
import 'package:intl/intl.dart';
import '../model/meta.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../utils/moeda_formatter.dart';

Real _real = Real();
var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

class AdicionarMetaPage extends StatefulWidget {

  final VoidCallback onAdd;
  AdicionarMetaPage({required this.onAdd});

  @override
  _AdicionarMetaPageState createState() => _AdicionarMetaPageState();
}

class _AdicionarMetaPageState extends State<AdicionarMetaPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  DateTime _dataLimite = DateTime.now();

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataLimite = dataSelecionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Meta'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor Total'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Permite apenas números e ponto decimal
                MoedaTextInputFormatter(), // Permite apenas números e ponto decimal
              ],
            ),
            ListTile(
              title: Text('Data Limite'),
              subtitle: Text('${_dataLimite.day}/${_dataLimite.month}/${_dataLimite.year}'),
              onTap: () => _selecionarData(context),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto e data selecionada
            String titulo = _tituloController.text;
            String descricao = _descricaoController.text;
            String valorTotalTexto = _valorController.text;
            String dataLimite = DateFormat('yyyy-MM-dd').format(_dataLimite); // Use o formato desejado aqui

            // Verificar se título e valor total foram inseridos
            if (titulo.isEmpty && valorTotalTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título e o valor total.')),
              );
              return;
            }

            // Verificar se o título foi inserido
            if (titulo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título.')),
              );
              return;
            }

            // Verificar se o valor total foi inserido
            if (valorTotalTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o valor total.')),
              );
              return;
            }

            try {
              // Remove o prefixo "R$" e outros caracteres não numéricos
              String valorLimpo = valorTotalTexto.replaceAll(RegExp(r'[^\d,]'), '');
              double valorTotal = _real.parseValor(valorLimpo);

              // Criando a nova meta no banco de dados
              MetaDB().create(
                titulo: titulo,
                descricao: descricao,
                valor_total: valorTotal,
                data_limite: dataLimite,
              );

              if (connectivityResult != ConnectivityResult.none) {
                // Faz a sincronização se estiver online
                await databaseService.syncMetaToFB();
              } else {
              }

              // Fechando o AlertDialog após adicionar a meta
              widget.onAdd(); // Chama o callback para atualizar a lista
              Navigator.of(context).pop(true);
            } catch (e) {
              print('Erro ao adicionar a meta: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar a meta. Verifique os valores inseridos.')),
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
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}

class MetaController {
  final MetaDB _metaDB = MetaDB();

  // Método para exibir os detalhes da meta em uma caixa de diálogo
  void mostrarDetalhesMeta(BuildContext context, Meta meta, VoidCallback atualizarMetas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        DateTime? data;
        String dataFormatada = 'Data não disponível';

        // Verificar se meta.data_limite não é nula
        if (meta.data_limite != null) {
          data = DateTime.parse(meta.data_limite!);
          dataFormatada = DateFormat('dd/MM/yyyy').format(data);
        }

        return AlertDialog(
          title: Text(meta.titulo),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descrição: ${meta.descricao}'),
              Text('Valor Total: R\$${NumberFormat("#,##0.00", "pt_BR").format(meta.valor_total)}'),
              Text('Valor Guardado: R\$${NumberFormat("#,##0.00", "pt_BR").format(meta.valor_guardado)}'),
              Text('Data Limite: $dataFormatada'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                excluirMeta(context, meta, atualizarMetas);
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
  }

  // Método para construir um ListTile para exibir uma meta
  Widget construirMetaListTile(BuildContext context, Meta meta, VoidCallback atualizarMetas) {
    double progresso = meta.valor_guardado / meta.valor_total;  // Calcule o progresso da meta

    if (progresso > 1.0) {
      progresso = 1.0;
    }

    return GestureDetector(
      onTap: () {
        mostrarDetalhesMeta(context, meta, atualizarMetas);
      },
      child: Card.outlined(
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: AppColors.purplelightMain, width: 2.0),
            borderRadius: BorderRadius.circular(25.0)),
        color: AppColors.white,
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                    meta.titulo.toUpperCase(),
                    style: AppTextStyles.cardheaderText
                ),
              ),
              SizedBox(height: 8.0),
              Text(meta.descricao),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('R\$${NumberFormat("#,##0.00", "pt_BR").format(meta.valor_guardado)}'),
                  Text('R\$${NumberFormat("#,##0.00", "pt_BR").format(meta.valor_total)}'),
                ],
              ),
              SizedBox(height: 8.0),
              LinearPercentIndicator(
                lineHeight: 18.0,
                percent: progresso,
                backgroundColor: Colors.grey,
                progressColor: Colors.green,
                barRadius: Radius.circular(10),
                center: Text(('${(progresso * 100).toStringAsFixed(1)}%'),
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.black87,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void excluirMeta(BuildContext context, Meta meta, VoidCallback atualizarMetas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Meta'),
          content: Text(
            'Deseja realmente excluir a meta "${meta.titulo}"? Todo o saldo guardado será retornado ao saldo total.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o modal antes de iniciar a exclusão
                try {
                  // Exclui a meta
                  MetaDB().delete(meta.id);

                  // Atualiza a lista de metas
                  atualizarMetas();

                  // Exibe mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meta "${meta.titulo}" excluída com sucesso!')),
                  );
                } catch (e) {
                  // Exibe mensagem de erro em caso de falha
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir a meta: $e')),
                  );
                }
              },
              child: Text('Excluir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Apenas fecha o modal
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }


}





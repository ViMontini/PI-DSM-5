import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';

class Metas extends StatefulWidget {
  @override
  _Metas createState() => _Metas();
}

class _Metas extends State<Metas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Metas"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Stack(
        children: [
          // Conteúdo da página
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  // Insira o número de itens da sua lista de metas aqui
                  itemCount: 3, // Exemplo com 3 itens
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 4.0,
                        child: ListTile(
                          title: Text('Título da Meta'),
                          subtitle: Text('Descrição da Meta'),
                          trailing: Text('Progresso'), // Exemplo de um trailing genérico
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Botão flutuante
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Função para abrir o modal de adicionar meta (similar a movimentacoes.dart)
                abrirModalAdicionarMeta(context, (titulo, descricao) {
                  // Lógica para adicionar a nova meta (arrume depois)
                  // ...
                  setState(() {}); // Atualizar a lista de metas (se necessário)
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}


// Função para abrir um modal para adicionar uma nova meta
typedef void AdicionarMetaCallback(String titulo, String descricao);

void abrirModalAdicionarMeta(BuildContext context, AdicionarMetaCallback onAdicionarMeta) {
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
              'Adicionar Meta',
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

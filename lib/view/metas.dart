// metas.dart
import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/meta_controller.dart';
import 'package:despesa_digital/database/meta_db.dart';
import 'package:despesa_digital/model/meta.dart';

class Metas extends StatefulWidget {
  @override
  _Metas createState() => _Metas();
}

class _Metas extends State<Metas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Meta>>? futureMetas;
  final MetaController metaController = MetaController(); // Instância do MetaController

  @override
  void initState() {
    super.initState();
    futureMetas = MetaDB().fetchAll(); // Fetch metas on initialization
  }

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
                child: FutureBuilder<List<Meta>>(
                  future: futureMetas,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Meta> metas = snapshot.data!;
                      return ListView.builder(
                        itemCount: metas.length,
                        itemBuilder: (context, index) {
                          final meta = metas[index];
                          // Substituição da construção do ListTile pelo método do MetaController
                          return metaController.construirMetaListTile(context, meta);
                        },
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text('Erro ao carregar metas'));
                    }
                    // Display a loading indicator while data is being fetched
                    return Center(child: CircularProgressIndicator());
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarMetaPage(); // Abre o modal para adicionar uma nova meta
                  },
                ).then((value) {
                  // Atualiza a lista de metas se uma nova meta foi adicionada
                  if (value == true) {
                    setState(() {
                      futureMetas = MetaDB().fetchAll();
                    });
                  }
                });
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

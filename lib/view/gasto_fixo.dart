import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/gafi_controller.dart';

class GastoFixo extends StatefulWidget {
  @override
  _GastoFixo createState() => _GastoFixo();
}

class _GastoFixo extends State<GastoFixo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Gastos Fixos"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Stack(
        children: [
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Função para abrir o modal de adicionar meta (similar a movimentacoes.dart)
                abrirModalAdicionarGastoFixo(context, (titulo, descricao) {
                  // Lógica para adicionar a nova meta (arrume depois)
                  // ...
                  setState(() {}); // Atualizar a lista de metas (se necessário)
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



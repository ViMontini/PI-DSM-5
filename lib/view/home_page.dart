import 'package:flutter/material.dart';
import 'package:despesa_digital/controller/utils.dart'; // Importa o arquivo utils.dart
import 'package:despesa_digital/view/saldo.dart'; // Importe as páginas para as quais deseja navegar
import 'package:despesa_digital/view/movimentacoes.dart'; // Importe as páginas para as quais deseja navegar
import 'package:despesa_digital/view/dividas.dart'; // Importe as páginas para as quais deseja navegar
import 'package:despesa_digital/view/metas.dart'; // Importe as páginas para as quais deseja navegar
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Obtendo a data atual
    DateTime now = DateTime.now();
    String formattedDate = '${now.day} de ${getMonthName(now.month)}';

    String greeting = getGreeting(now.hour); // Obtém a saudação de acordo com a hora do dia

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: formattedDate),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.5), // Cor do background da HomePage com opacidade reduzida
      body: Column(
        children: [
          SizedBox(height: 20), // Espaçamento acima da frase
          Text(
            'Olá Pedro, $greeting!',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 20), // Espaçamento abaixo da frase
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 colunas
              childAspectRatio: 1.0, // Relação de aspecto para os quadrados
              children: <Widget>[
                _buildSquare(context, Colors.red, 'Saldo', Saldo()),
                _buildSquare(context, Colors.blue, 'Movimentações', Movimentacoes()),
                _buildSquare(context, Colors.green, 'Dívidas', Dividas()),
                _buildSquare(context, Colors.yellow, 'Metas', Metas()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquare(BuildContext context, Color color, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        margin: EdgeInsets.all(10), // Adiciona margem ao redor dos quadrados
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 40, color: Colors.white), // Ícone
            SizedBox(height: 5), // Espaçamento
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ), // Título
          ],
        ),
      ),
    );
  }
}

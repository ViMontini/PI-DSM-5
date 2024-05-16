import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/divi_controller.dart';
import 'package:despesa_digital/model/divida.dart'; // Importe a classe Divida
import 'package:despesa_digital/database/divida_db.dart'; // Importe a classe DividaDB

class Dividas extends StatefulWidget {
  @override
  _Dividas createState() => _Dividas();
}

class _Dividas extends State<Dividas> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Divida>> futureDividas; // Futuro de lista de dívidas
  final DividaController dividaController = DividaController();

  @override
  void initState() {
    super.initState();
    futureDividas = DividaDB().fetchAll(); // Inicialização do futuro de lista de dívidas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Dívidas"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Oculta o botão de formato
                  titleCentered: true, // Centraliza o título
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  setState(() {});
                },
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Dívidas para ${_focusedDay.month}/${_focusedDay.year}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder<List<Divida>>(
                  future: futureDividas,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Divida> dividas = snapshot.data!;
                      return ListView.builder(
                        itemCount: dividas.length,
                        itemBuilder: (context, index) {
                          final divida = dividas[index];
                          // Substituição da construção do ListTile pelo método do MetaController
                          return dividaController.construirDividaListTile(context, divida);
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
          // Botão flutuante para adicionar dívida
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarDividaPage(); // Abre o modal para adicionar uma nova meta
                  },
                ).then((value) {
                  // Atualiza a lista de metas se uma nova meta foi adicionada
                  if (value == true) {
                    setState(() {
                      futureDividas = DividaDB().fetchAll();
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

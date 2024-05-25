import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/divi_controller.dart';
import 'package:despesa_digital/model/divida.dart'; // Importe a classe Divida
import 'package:despesa_digital/database/divida_db.dart'; // Importe a classe DividaDB
import 'package:intl/intl.dart';

class Dividas extends StatefulWidget {
  @override
  _Dividas createState() => _Dividas();
}

class _Dividas extends State<Dividas> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Divida>> futureDividas;
  final DividaController dividaController = DividaController();

  @override
  void initState() {
    super.initState();
    futureDividas = DividaDB().fetchByDatas(DateFormat('yyyy-MM-dd').format(_focusedDay));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      futureDividas = DividaDB().fetchByDatas(DateFormat('yyyy-MM-dd').format(_focusedDay));
    });
  }

  void _refreshDividas() {
    setState(() {
      futureDividas = DividaDB().fetchByDatas(DateFormat('yyyy-MM-dd').format(_focusedDay));
    });
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
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
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
                          return dividaController.construirDividaListTile(context, divida, _refreshDividas);
                        },
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text('Erro ao carregar dívidas'));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarDividaPage();
                  },
                ).then((value) {
                  if (value == true) {
                    _refreshDividas();
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
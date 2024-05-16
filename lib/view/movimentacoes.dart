import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/movi_controller.dart';
import 'package:despesa_digital/model/movimentacao.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';

class Movimentacoes extends StatefulWidget {
  @override
  _Movimentacoes createState() => _Movimentacoes();
}

class _Movimentacoes extends State<Movimentacoes> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Movimentacao>>? futureMovi;
  final MoviController moviController = MoviController();

  @override
  void initState() {
    super.initState();
    futureMovi = MovimentacaoDB().fetchAll(); // Fetch metas on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Movimentações"),
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
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
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
              SizedBox(height: 20.0),
              SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder<List<Movimentacao>>(
                  future: futureMovi,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Movimentacao> movis = snapshot.data!;
                      return ListView.builder(
                        itemCount: movis.length,
                        itemBuilder: (context, index) {
                          final movi = movis[index];
                          // Substituição da construção do ListTile pelo método do MetaController
                          return moviController.construirMoviListTile(context, movi);
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
          // Botão flutuante para adicionar movimentação
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarMoviPage(selectedDay: _selectedDay); // Abre o modal para adicionar uma nova meta
                  },
                ).then((value) {
                  // Atualiza a lista de metas se uma nova meta foi adicionada
                  if (value == true) {
                    setState(() {
                      futureMovi = MovimentacaoDB().fetchAll();
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
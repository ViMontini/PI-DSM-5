import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/movi_controller.dart';
import 'package:despesa_digital/model/movimentacao.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:intl/intl.dart';

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
  bool _isVisible = false; // Estado para controlar a visibilidade dos botões

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
      });
    }
  }

  void _refreshMovis() {
    setState(() {
      futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_focusedDay));
    });
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
                          return moviController.construirMoviListTile(context, movi , _refreshMovis);
                        },
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text('Erro ao carregar movimentações'));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isVisible) // Exibe os botões se isVisible for true
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AdicionarMoviPage(selectedDay: _selectedDay);
                        },
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
                          });
                        }
                      });
                      // Após clicar, torna os botões invisíveis novamente
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Text('Adicionar Movimentação',
                        style: TextStyle(color: Colors.black)),
                  ),
                SizedBox(height: 10), // Adicione um espaço entre os botões flutuantes
                if (_isVisible) // Exibe os botões se isVisible for true
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return GuardarSaldo(selectedDay: _selectedDay);
                        },
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
                          });
                        }
                      });
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Text('Guardar saldo',
                        style: TextStyle(color: Colors.black)),
                  ),
                SizedBox(height: 10),
                if (_isVisible) // Exibe os botões se isVisible for true
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PagarConta(selectedDay: _selectedDay);
                        },
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
                          });
                        }
                      });
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Text('Pagar Conta',
                        style: TextStyle(color: Colors.black)),
                  ),
                SizedBox(height: 10),
                if (_isVisible) // Exibe os botões se isVisible for true
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PagarDivida(selectedDay: _selectedDay);
                        },
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            futureMovi = MovimentacaoDB().fetchByData(DateFormat('yyyy-MM-dd').format(_selectedDay!));
                          });
                        }
                      });
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Text('Pagar Dívida',
                        style: TextStyle(color: Colors.black)),
                  ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible; // Alterna a visibilidade dos botões
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

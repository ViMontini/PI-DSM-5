import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/divi_controller.dart';

class Dividas extends StatefulWidget {
  @override
  _Dividas createState() => _Dividas();
}

class _Dividas extends State<Dividas> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  String _eventoSalvo = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                child: ListView.builder(
                  //itemCount: _listaDividas.dividas.length, // Comment out if not currently used
                  itemBuilder: (context, index) {
                    //var divida = _listaDividas.dividas[index]; // Comment out if not currently used
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 4.0,
                        child: ListTile(
                          title: Text('Valor:'), // Replace with actual value display
                          subtitle: Text('Vencimento:'), // Replace with actual due date display
                          trailing: Text('Status'), // Replace with actual status display
                        ),
                      ),
                    );
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
                abrirModalAdicionarDivida(context, (valor, descricao) {

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
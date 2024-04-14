import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/utils.dart';
import 'package:despesa_digital/model/movimentacao.dart'; // Importe sua classe MovimentacaoMonetaria aqui

class Movimentacoes extends StatefulWidget {
  @override
  _Movimentacoes createState() => _Movimentacoes();
}

class _Movimentacoes extends State<Movimentacoes> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _eventoSalvo = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ListaMovimentacoes _listaMovimentacoes = ListaMovimentacoes();

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
              Expanded(
                child: TableCalendar(
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
              ),
              SizedBox(height: 20.0),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _listaMovimentacoes.movimentacoes.length,
                  itemBuilder: (context, index) {
                    var movimentacao = _listaMovimentacoes.movimentacoes[index];
                    if (isSameDay(movimentacao.data, _selectedDay)) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Valor: ${movimentacao.valor}'),
                            subtitle: Text('Descrição: ${movimentacao.descricao}'),
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Retorna um container vazio se a movimentação não for para o dia selecionado
                    }
                  },
                ),
              ),
            ],
          ),
          // Botão flutuante para adicionar movimentação
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Chame a função do utils.dart para abrir o modal de adicionar movimentação
                abrirModalAdicionarMovimentacao(context, (valor, descricao) {
                  // Aqui você pode adicionar a lógica para adicionar a movimentação com o valor e a descrição fornecidos
                  _listaMovimentacoes.adicionarMovimentacao(data: _selectedDay!, valor: valor, descricao: descricao);
                  setState(() {}); // Atualizar o estado para refletir a adição da movimentação
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
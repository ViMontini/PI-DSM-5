import 'package:flutter/cupertino.dart';
import 'home_state.dart';

class HomeController extends ChangeNotifier {

HomeState _state = HomeStateInitial();

HomeState get state => _state;

void _changeState(HomeState newState) {
  _state = newState;
  notifyListeners();
}
}

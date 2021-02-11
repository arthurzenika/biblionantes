import 'package:biblionantes/pages/accountpage.dart';
import 'package:biblionantes/repositories/account_repository.dart';
import 'package:biblionantes/repositories/search.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'pages/searchpage.dart';

BaseOptions options = new BaseOptions(
  baseUrl: "https://catalogue-bm.nantes.fr/in/rest/api/",
  connectTimeout: 5000,
  receiveTimeout: 3000,
);
Dio dio = new Dio(options);

/// This is the stateful widget that the main application instantiates.
class AppWidget extends StatefulWidget {
  AppWidget({Key key}) : super(key: key);

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AppWidgetState extends State<AppWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    SearchPageStateful(
      searchRepository: SearchRepository(
        client: dio
      ),
    ),
    Text(
      'Mes livres empruntés',
      style: optionStyle,
    ),
    AccountPageStateful(
      accountRepository: AccountRepository(
        client: dio,
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_contacts),
            label: 'Livres empruntés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Mes cartes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

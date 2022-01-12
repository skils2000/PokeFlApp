import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeFlApp',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PokeApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PokemonResponse {
  final int count;
  final List results;
  //final String next;
  //final String previous;

  PokemonResponse({this.count, this.results /*, this.next, this.previous*/});

  factory PokemonResponse.fromJson(Map<String, dynamic> json) {
    return PokemonResponse(count: json['count'], results: json['results']);
  }
}

class Pokemon {
  String name;
  String url;
}

class SortSelect {
  int value;
  String name;

  SortSelect({this.value, this.name});
}

class _MyHomePageState extends State<MyHomePage> {
  List pokemons;
  List pokemonsBy6;
  List pokemonsSorted;
  int numberOfAdded = 6;
  int sortTypeId = 0;
  List sortReversed;
  List<String> sortTypes = [
    "not sorted",
    "sort by name (up)",
    "sort by name (down)"
  ];

  Future<String> getPokemons() async {
    var resp = await http.get(
        Uri.encodeFull("https://pokeapi.co/api/v2/pokemon"),
        headers: {/*"Accept": "application/json"*/});
    print(resp.body);
    PokemonResponse temporary =
        PokemonResponse.fromJson(json.decode(resp.body));
    print(temporary.results);
    setState(() {
      pokemons = temporary.results;
      pokemonsBy6 = temporary.results.sublist(0, 6);
      numberOfAdded = 6;
    });
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    getPokemons();
  }

  void expandList() {
    print(pokemons.sublist(0, numberOfAdded));
    print(pokemonsBy6);
    switch (sortTypeId) {
      case 0:
        {
          pokemonsBy6
              .addAll(pokemons.sublist(numberOfAdded, numberOfAdded + 6));
          break;
        }
      case 1:
        {
          pokemonsBy6
              .addAll(pokemonsSorted.sublist(numberOfAdded, numberOfAdded + 6));
          break;
        }
      case 2:
        {
          pokemonsBy6
              .addAll(sortReversed.sublist(numberOfAdded, numberOfAdded + 6));
          break;
        }
    }
    setState(() {
      numberOfAdded = numberOfAdded + 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.sort), onPressed: () => {onSort()}),
        ],

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title:
            Text(widget.title + "                   " + sortTypes[sortTypeId]),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: getList()
        /*
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20, right: 20.0),
            padding: EdgeInsets.all(12.0),
            height: 70,
            color: Colors.white,
            child: DropdownButton<String>(
              value: dropdownValue,
              style: const TextStyle(color: Colors.black87, fontSize: 20.0),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              isExpanded: true,
              items: <String>['One', 'Two', 'Free', 'Four']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          */
        ,

        /*Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
        */
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getPokemons,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget getList() {
    if (pokemons == null || pokemons.length < 1) {
      return Container(
        child: Center(
          child: Text("Пожалуйста подождите..."),
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.extentAfter == 0) {
            expandList();
            print("The End");
            print(pokemonsBy6);
            return true;
          }
          return false;
        },
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return getListItem(index);
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: pokemonsBy6.length));
  }

  Widget getListItem(int i) {
    if (pokemons == null || pokemons.length < 1) return null;

    return Container(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: new Row(
          children: [
            new Image.network(
              width: 200.0,
              height: 100.0,
            ),
            new Expanded(
                child: new Text(
              pokemonsBy6[i]['name'].toString(),
              style: TextStyle(fontSize: 18),
            ))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MaterialApp(home: DiamondApp(), debugShowCheckedModeBanner: false));

class DiamondApp extends StatefulWidget {
  @override
  _DiamondAppState createState() => _DiamondAppState();
}

class _DiamondAppState extends State<DiamondApp> {
  bool _isLoading = true;
  List<List<String>> _coloresDMC = [];
  List<List<String>> _filtrados = [];

  @override
  void initState() {
    super.initState();
    _procesarBaseDeDatos();
  }

  Future<void> _procesarBaseDeDatos() async {
    try {
      // Lee tu archivo CSV de 447 colores [cite: 2026-01-03]
      final String datosBrutos = await rootBundle.loadString('assets/dmc.csv');
      List<String> lineas = datosBrutos.split('\n');
      
      List<List<String>> temporal = [];
      // Empezamos en i=1 para saltar la cabecera: Floss#,Description,Red...
      for (int i = 1; i < lineas.length; i++) {
        List<String> c = lineas[i].split(',');
        if (c.length >= 6) { temporal.add(c); }
      }

      setState(() {
        _coloresDMC = temporal;
        _filtrados = temporal;
      });

      // Mantenemos tu logo rectangular 3 segundos [cite: 2026-01-02]
      await Future.delayed(Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        child: _isLoading ? _buildSplash() : _buildMainScreen(),
      ),
    );
  }

  // PANTALLA 1: TU LOGO RECTANGULAR [cite: 2026-01-02]
  Widget _buildSplash() {
    return SizedBox.expand(
      key: ValueKey('splash'),
      child: Image.asset(
        'assets/Pantalla_Logo.jpg', 
        fit: BoxFit.cover, // Llena toda la pantalla del móvil
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildMainScreen() {
    return Scaffold(
      key: ValueKey('main'),
      appBar: AppBar(
        title: Text("DIAMOND PRINT - BUSCADOR DMC"),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar por número o nombre...",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.cyan),
              ),
              onChanged: (val) {
                setState(() {
                  _filtrados = _coloresDMC.where((c) => 
                    c[0].contains(val) || c[1].toLowerCase().contains(val.toLowerCase())).toList();
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filtrados.length,
        itemBuilder: (context, index) {
          final col = _filtrados[index];
          // Usamos las columnas Red(2), Green(3) y Blue(4) de tu CSV
          final colorReal = Color.fromARGB(255, int.parse(col[2]), int.parse(col[3]), int.parse(col[4]));
          return ListTile(
            leading: CircleAvatar(backgroundColor: colorReal, radius: 25),
            title: Text("DMC ${col[0]}", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(col[1]),
            trailing: Text("#${col[5]}"), // Código Hexadecimal
          );
        },
      ),
    );
  }
}

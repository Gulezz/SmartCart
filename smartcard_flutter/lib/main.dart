import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SmartGroceryApp());
}

class SmartGroceryApp extends StatelessWidget {
  const SmartGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MenuScherm(),
    );
  }
}

class MenuScherm extends StatefulWidget {
  const MenuScherm({super.key});

  @override
  State<MenuScherm> createState() => _MenuSchermState();
}

class _MenuSchermState extends State<MenuScherm> {
  // Controller om de tekst uit het invoerveld te lezen
  final TextEditingController _menuController = TextEditingController();
  bool _isLoading = false; // Houdt bij of we aan het laden zijn
  
  Future<void> _calculateList() async {
    if (_menuController.text.isEmpty) return;

  bool _isLaden = false;
  Map<String, dynamic>? _apiResultaat;

  // De HTTP-functie die we eerder hebben opgezet
  Future<void> fetchBerekening(String ingevoerdMenu) async {
    setState(() {
      _isLaden = true;
    });

    // Het adres van de Python Flask server via de Android Emulator
    final url = Uri.parse('http://10.0.2.2:5000/api/calculate');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'menu': ingevoerdMenu,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _apiResultaat = jsonDecode(response.body);
          _isLaden = false;
        });
      } else {
        print('Fout: Server gaf code ${response.statusCode}');
        setState(() {
          _isLaden = false;
        });
      }
    } catch (e) {
      print('Fout bij het verbinden met de server: $e');
      setState(() {
        _isLaden = false;
      });
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slimme Boodschappenlijst'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Het invoerveld voor het menu
            TextField(
              controller: _menuController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Typ hier je weekmenu (bijv. Spaghetti Bolognese voor 4 personen)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // De knop om de actie te starten
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLaden
                    ? null
                    : () {
                        if (_menuController.text.isNotEmpty) {
                          FocusScope.of(context).unfocus(); // Sluit het toetsenbord na het klikken
                          fetchBerekening(_menuController.text);
                        }
                      },
                child: _isLaden
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Bereken Boodschappenlijst', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Resultaten of welkomsttekst weergeven
            Expanded(
              child: _apiResultaat == null
                  ? const Center(child: Text('Voer een menu in om de AI te starten.', style: TextStyle(fontSize: 16)))
                  : _bouwResultatenLijst(),
            ),
          ],
        ),
      ),
    );
  }

  // Aparte widget-functie om de UI netjes te houden
  Widget _bouwResultatenLijst() {
    // We halen veilig de lijsten uit de JSON, met fallbacks als er iets mist
    final items = _apiResultaat!['items'] as List<dynamic>? ?? [];
    final routeInfo = _apiResultaat!['route_info'] ?? 'Vertrek Bierbeek -> Route wordt later berekend';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Algemeen overzicht (Route & Prijs)
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overzicht', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text('Route: $routeInfo', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text('Totale geschatte prijs: ${_apiResultaat!['total_price']}', style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Ingrediënten:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        
        // De lijst met gegenereerde ingrediënten
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_basket, color: Colors.green),
                  title: Text(item['name'] ?? 'Onbekend', style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Winkel: ${item['store']}'),
                  trailing: Text(item['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
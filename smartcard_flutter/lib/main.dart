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
      title: 'Slim Boodschappen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MenuInputScreen(),
    );
  }
}

// SCHERM 1: Het invoeren van het weekmenu
class MenuInputScreen extends StatefulWidget {
  const MenuInputScreen({super.key});

  @override
  State<MenuInputScreen> createState() => _MenuInputScreenState();
}

class _MenuInputScreenState extends State<MenuInputScreen> {
  final TextEditingController _menuController = TextEditingController();
  bool _isLoading = false; // Houdt bij of we aan het laden zijn

  Future<void> _calculateList() async {
    if (_menuController.text.isEmpty) return;

    setState(() {
      _isLoading = true; // Start de laad-animatie
    });

    try {
      // BELANGRIJK: 10.0.2.2 is het IP-adres waarmee een Android-emulator
      // contact kan maken met de 'localhost' (je eigen computer) waar de server straks draait.
      final url = Uri.parse('http://10.0.2.2:5000/api/calculate');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'menu': _menuController.text}),
      );

      if (response.statusCode == 200) {
        // Succes! Converteer de JSON-tekst naar een werkbaar Dart-object
        final responseData = jsonDecode(response.body);
        
        // Navigeer naar het volgende scherm en geef de data mee
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(resultData: responseData),
            ),
          );
        }
      } else {
        _showError('Server gaf een foutcode: ${response.statusCode}');
      }
    } catch (e) {
      // Als de server nog niet bestaat of niet bereikbaar is, laten we een test-resultaat zien
      // zodat je de app toch kunt blijven testen tijdens het bouwen!
      print('Netwerkfout (Draait de server al?): $e');
      _showMockResult();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop de laad-animatie
        });
      }
    }
  }

  void _showMockResult() {
    final mockData = {
      "route_info": "Colruyt (3.2 km) -> Aldi (1.5 km)",
      "travel_cost": "€0.70",
      "total_price": "€ 9.53",
      "items": [
        {"name": "Aardappelen (2kg) (Fictief)", "store": "Aldi", "price": "€ 2.49"},
        {"name": "Gehakt (500g) (Fictief)", "store": "Colruyt", "price": "€ 4.15"},
      ]
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(resultData: mockData),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Weekmenu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Wat wil je eten deze week?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _menuController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Bijv: Dinsdag lasagne, woensdag stoofvlees...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _calculateList, // Deactiveer knop tijdens laden
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator() // Toon laad-wiel
                  : const Text('Bereken Boodschappen & Route', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// SCHERM 2: De resultaten (Boodschappenlijst & Route)
class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData; // Ontvangt dynamische data in plaats van vaste tekst

  const ResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    // Haal de lijst met producten uit de data
    final List<dynamic> items = resultData['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jouw Route & Lijst'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text('Optimale Route'),
                subtitle: Text(resultData['route_info'] ?? 'Geen route info'),
                trailing: Text('${resultData['travel_cost']} reiskost'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Boodschappenlijst',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // ListView.builder is geoptimaliseerd voor het bouwen van (lange) dynamische lijsten
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['name'] ?? 'Onbekend'),
                      subtitle: Text(item['store'] ?? 'Onbekend'),
                      trailing: Text(item['price'] ?? '€0.00'),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Totale geschatte kostprijs:', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                resultData['total_price'] ?? '€0.00', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
            )
          ],
        ),
      ),
    );
  }
}
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
        // De donkergroene kleur uit het design
        primaryColor: const Color(0xFF0F4D2A),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const HoofdNavigatie(),
    );
  }
}

// --- HOOFDNAVIGATIE (Bottom Navigation Bar) ---
class HoofdNavigatie extends StatefulWidget {
  const HoofdNavigatie({super.key});

  @override
  State<HoofdNavigatie> createState() => _HoofdNavigatieState();
}

class _HoofdNavigatieState extends State<HoofdNavigatie> {
  int _huidigeIndex = 0;

  // De verschillende schermen van de app
  final List<Widget> _schermen = [
    const VandaagScherm(),
    const PlaceholderScherm(titel: 'Jouw week'),
    const PlaceholderScherm(titel: 'Boodschappen'),
    const RouteScherm(), // Dit is nu het grijze scherm
  ];

  void _onItemTapped(int index) {
    setState(() {
      _huidigeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _schermen[_huidigeIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _huidigeIndex,
        selectedItemColor: const Color(0xFF0F4D2A),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Vandaag'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Weekplan'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: 'Lijst'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Route'),
        ],
      ),
    );
  }
}

// --- TAB 1: VANDAAG SCHERM (Design nagemaakt) ---
class VandaagScherm extends StatefulWidget {
  const VandaagScherm({super.key});

  @override
  State<VandaagScherm> createState() => _VandaagSchermState();
}

class _VandaagSchermState extends State<VandaagScherm> {
  final TextEditingController _menuController = TextEditingController();
  bool _isLaden = false;
  Map<String, dynamic>? _apiResultaat;

  Future<void> fetchBerekening(String ingevoerdMenu) async {
    setState(() {
      _isLaden = true;
    });

    final url = Uri.parse('http://192.168.2.55:5000/api/calculate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'menu': ingevoerdMenu}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _apiResultaat = jsonDecode(response.body);
          _isLaden = false;
        });
      } else {
        setState(() {
          _isLaden = false;
        });
      }
    } catch (e) {
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header met begroeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Goedemorgen\nWard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0F4D2A),
                      child: const Text('W', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.notifications_outlined, size: 28),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            
            // Invoerveld "Wat wil je deze week eten?"
            const Text(
              'Wat wil je deze week eten?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _menuController,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (waarde) {
                  if (waarde.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    fetchBerekening(waarde);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Vertel wat je lekker vindt, hoeveel je wilt uitgeven of wat je nog in huis hebt...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: _isLaden 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF0F4D2A)),
                          onPressed: () {
                            if (_menuController.text.isNotEmpty) {
                              FocusScope.of(context).unfocus();
                              fetchBerekening(_menuController.text);
                            }
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Knoppen sturen data via HTTP verzoek indien ingevuld
            if (_apiResultaat != null) ...[
              // Groene Overzichtskaarten
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4D2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _bouwStatRow(Icons.local_offer_outlined, '€${_apiResultaat!['total_price'] ?? '0.00'} totaal'),
                    const Divider(color: Colors.white24, height: 32),
                    _bouwStatRow(Icons.eco_outlined, 'Route: ${_apiResultaat!['route_info'] ?? 'Berekend'}'),
                    const Divider(color: Colors.white24, height: 32),
                    _bouwStatRow(
                      Icons.storefront_outlined, 
                      '${(_apiResultaat!['items'] as List?)?.length ?? 0} producten gevonden',
                      onTap: () => _toonProductenLijst(context, _apiResultaat!['items'] as List?),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Actieknop
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4D2A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    _toonProductenLijst(context, _apiResultaat!['items'] as List?);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text('Bekijk mijn plan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- NIEUWE FUNCTIES (binnen de State klasse) ---

  Widget _bouwStatRow(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text, 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                softWrap: true,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _toonProductenLijst(BuildContext context, List<dynamic>? items) {
    if (items == null || items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Boodschappenlijst', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_basket, color: Color(0xFF0F4D2A)),
                        title: Text(item['name'] ?? 'Onbekend', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Winkel: ${item['store']}'),
                        trailing: Text(item['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- TAB 4: ROUTE SCHERM (Zonder Maps, Grijs scherm) ---
class RouteScherm extends StatelessWidget {
  const RouteScherm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300, // Maakt de achtergrond grijs
      appBar: AppBar(
        title: const Text('Jouw Route', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Kaart is tijdelijk uitgeschakeld.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TIJDELIJKE SCHERMEN VOOR NAVIGATIE ---
class PlaceholderScherm extends StatelessWidget {
  final String titel;
  const PlaceholderScherm({super.key, required this.titel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(titel, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
from flask import Flask, request, jsonify

app = Flask(__name__)

# Dit is het 'eindpunt' (endpoint) waar je Flutter-app naartoe stuurt
@app.route('/api/calculate', methods=['POST'])
def calculate():
    # 1. Ontvang de data (het weekmenu) vanuit de Flutter app
    data = request.get_json()
    menu_text = data.get('menu', 'Geen menu ingevuld')
    
    print(f"\n--- Nieuw verzoek ontvangen vanuit de app! ---")
    print(f"De gebruiker wil eten: {menu_text}")
    print(f"----------------------------------------------\n")

    # Hier komt in de volgende fases de ECHTE logica:
    # - OpenAI API aanspreken om ingrediënten uit 'menu_text' te halen
    # - Scrapers (BeautifulSoup) draaien voor prijzen
    # - OpenRouteService aanspreken voor afstanden

    # 2. Stuur voor nu een perfect gestructureerd antwoord terug 
    # Dit is exact het formaat dat de Flutter-app verwacht te krijgen.
    response_data = {
        "route_info": "Vertrek Bierbeek -> Colruyt (3.2 km) -> Aldi (1.5 km)",
        "travel_cost": "€0.70",
        "total_price": "€ 14.88",
        "items": [
            # We sturen een stukje van de ingevoerde tekst terug om te bewijzen 
            # dat de server echt naar de app heeft "geluisterd".
            {"name": f"Gerecht basis voor: {menu_text[:15]}...", "store": "Systeem", "price": "€ 0.00"},
            {"name": "Aardappelen (2kg)", "store": "Aldi", "price": "€ 2.49"},
            {"name": "Gehakt (500g)", "store": "Colruyt", "price": "€ 4.15"},
            {"name": "Tomatensaus", "store": "Colruyt", "price": "€ 1.20"},
            {"name": "Prei (3 stuks)", "store": "Colruyt", "price": "€ 1.89"},
            {"name": "Wortelen (1kg)", "store": "Aldi", "price": "€ 0.99"}
        ]
    }

    # Stuur het terug naar de app als een JSON-bestand
    return jsonify(response_data)

if __name__ == '__main__':
    # host='0.0.0.0' is heel belangrijk! Hierdoor kan de Android Emulator
    # vanaf zijn eigen virtuele netwerk (10.0.2.2) bij jouw lokale server.
    app.run(host='0.0.0.0', port=5000, debug=True)
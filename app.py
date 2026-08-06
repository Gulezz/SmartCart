from flask import Flask, request, jsonify
from openai import OpenAI
import groq
import json
import os

app = Flask(__name__)

# Initialiseer de OpenAI client. 
# PLAK HIER JOUW API SLEUTEL (Tussen de aanhalingstekens)
client = groq.Groq(api_key=os.environ.get("GROQ_API_KEY"))

@app.route('/api/calculate', methods=['POST'])
def calculate():
    data = request.get_json()
    menu_text = data.get('menu', '')
    
    print(f"\n--- OpenAI aan het nadenken over: {menu_text} ---")

    # 1. De instructies voor ChatGPT
    system_prompt = """
    Jij bent een culinair assistent die een boodschappenlijst maakt. 
    De gebruiker geeft een weekmenu. Jij antwoordt UITSLUITEND met een valide JSON object.
    Geef absoluut geen andere tekst buiten de JSON.
    Gebruik dit exacte formaat:
    {
      "ingredients": [
        {"name": "Aardappelen", "amount": "2 kg"},
        {"name": "Gehakt", "amount": "500 gram"}
      ]
    }
    """
    
    items_list = []
    
    try:
        # 2. We sturen de data naar OpenAI (we gebruiken het snelle en goedkope gpt-4o-mini model)
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            response_format={ "type": "json_object" }, # Dit dwingt OpenAI om geldige JSON terug te geven
           messages=[
                {
                    "role": "system",
                    "content": """Je bent een uiterst nauwkeurige, no-nonsense boodschappen-assistent voor een Vlaamse supermarkt. Je verzint NOOIT ingrediënten en baseert je uitsluitend op authentieke, bestaande recepten.

            Volg deze STRIKTE regels om hallucinaties te voorkomen:
            1. Geen Fantasie (Anti-Hallucinatie): Gebruik uitsluitend ingrediënten die daadwerkelijk bestaan en algemeen verkrijgbaar zijn in een standaard supermarkt in Vlaanderen. Verzin geen onlogische smaakcombinaties. Nogmaals, je verzint geen ingrediënten die niet bij het gerecht horen.
            2. Gekozen Gerecht: Bij een vage term (zoals 'boerenkost' of 'iets gezonds'), kies jij een specifiek, bestaand klassiek gerecht en benoem je dit.
            3. Strikte Pantry-regel: Negeer basisartikelen. Zet NOOIT de volgende producten op de lijst: bloem, boter, suiker, zout, peper, water, melk (als scheutje), en standaard olie of azijn.
            4. Realistische Porties: Reken standaard voor 2 tot 4 personen, tenzij anders aangegeven. Gebruik logische supermarktverpakkingen (bijv. '1 netje ajuinen', '800g varkensstoofvlees').
            5. Categorisatie: Deel de ingrediënten in per supermarktafdeling.

            Je MOET antwoorden in dit exacte JSON-formaat, zonder enige extra tekst of uitleg:
            {
            "gekozen_gerecht": "Naam van het gerecht",
            "ingredienten": {
                "Groenten & Fruit": [
                "1 bussel witte selder",
                "1 kg vastkokende aardappelen"
                ],
                "Vlees, Vis & Vega": [
                "800g varkensstoofvlees"
                ],
                "Zuivel & Gekoeld": [],
                "Kruidenierswaren": [
                "1 flesje donker tafelbier",
                "1 potje mosterd"
                ]
            }
            }"""
                },
                {
                    "role": "user",
                    "content": f"{user_input}"
                }
            ]
        )
        
        # 3. Ontvang het antwoord en lees de JSON
        ai_output = response.choices[0].message.content
        print("\nRuwe output van OpenAI:\n", ai_output)
        
        parsed_data = json.loads(ai_output)
        ingredients = parsed_data.get("ingredients", [])
        
        # 4. Zet de ingrediënten om naar het formaat voor je Flutter-app
        for item in ingredients:
            items_list.append({
                "name": f"{item.get('name', 'Onbekend')} ({item.get('amount', '')})",
                "store": "Wordt nog gezocht", 
                "price": "€ --"              
            })
            
    except Exception as e:
        print("\nFout bij OpenAI:", e)
        items_list = [{"name": "Fout bij inladen AI", "store": "", "price": ""}]

    # 5. Stuur het antwoord terug naar de telefoon
    response_data = {
        "route_info": "Vertrek Bierbeek -> Route wordt later berekend",
        "travel_cost": "€ --",
        "total_price": "€ --",
        "items": items_list
    }

    return jsonify(response_data)

if __name__ == '__main__':
    # Cloud-platformen zoals Render bepalen zelf de poort, 
    # we vertellen Flask hier om te luisteren naar wat Render doorgeeft.
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
from flask import Flask, request, jsonify
from openai import OpenAI
import json

app = Flask(__name__)

# Initialiseer de OpenAI client. 
# PLAK HIER JOUW API SLEUTEL (Tussen de aanhalingstekens)
client = OpenAI(api_key="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")

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
            model="gpt-4o-mini",
            response_format={ "type": "json_object" }, # Dit dwingt OpenAI om geldige JSON terug te geven
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": menu_text}
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
    app.run(host='0.0.0.0', port=5000, debug=True)
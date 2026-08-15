import os
from dotenv import load_dotenv
from google import genai

# Laad de API sleutel uit je lokale .env bestand
load_dotenv()

# Verbind met de Google servers
client = genai.Client(api_key=AQ.Ab8RN6LSRixZ82BG9OLd3se9MobwsjPLKCuuizOLqtOjaLU90A)

print("Beschikbare modellen voor jouw API-sleutel:")
print("-" * 40)

# Vraag de live lijst op en print alle namen
try:
    for model in client.models.list():
        print(model.name)
except Exception as e:
    print(f"Fout bij het ophalen van de lijst: {e}")
import re

with open('scripts/level_builder.gd', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r'if theme == "Cave":.*?elif theme == "Cave Boss":', text, re.DOTALL)
if m:
    print(m.group(0))

m_forest = re.search(r'if theme == "Forest":.*?elif theme == "Rice Field":', text, re.DOTALL)
if m_forest:
    print("\n--- FOREST LAYOUT ---")
    print(m_forest.group(0))

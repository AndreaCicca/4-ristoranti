import csv
import json

input_file = '/Users/andrea/git-stuff/github/4-ristoranti/Programma_Televisivo_con_Stagioni_clean.csv'
output_file = '/Users/andrea/git-stuff/github/4-ristoranti/Programma_Televisivo_con_Stagioni_clean.json'

data = []

with open(input_file, mode='r', encoding='utf-8') as csvfile:
    csvreader = csv.DictReader(csvfile)
    for row in csvreader:
        # Rimuovi la colonna vuota
        if 'Unnamed: 9' in row:
            del row['Unnamed: 9']
        data.append(row)

with open(output_file, mode='w', encoding='utf-8') as jsonfile:
    json.dump(data, jsonfile, indent=4, ensure_ascii=False)

print(f"File JSON salvato come {output_file}")
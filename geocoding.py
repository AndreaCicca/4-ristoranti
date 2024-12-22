import json
import requests
import time
import os

def fetch_coordinates(location, api_key):
    """Fetch latitude and longitude for a given location using OpenCageData API."""
    url = f"https://api.opencagedata.com/geocode/v1/json?q={location}&key={api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if data['results']:
            lat = data['results'][0]['geometry']['lat']
            lng = data['results'][0]['geometry']['lng']
            return lat, lng
        else:
            print(f"No coordinates found for location: {location}")
            return None, None
    else:
        print(f"Error fetching data for {location}: {response.status_code}")
        return None, None

def load_existing_data(output_file):
    """Load existing data from the output file if it exists."""
    if os.path.exists(output_file):
        with open(output_file, 'r', encoding='utf-8') as outfile:
            return json.load(outfile)
    return []

def save_data_incrementally(output_file, updated_data):
    """Save data incrementally to avoid data loss."""
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(updated_data, outfile, ensure_ascii=False, indent=4)

def add_coordinates_to_json(input_file, output_file, api_key):
    """Read JSON, fetch coordinates for each location, and save to a new JSON file."""
    try:
        with open(input_file, 'r', encoding='utf-8') as infile:
            data = json.load(infile)

        existing_data = load_existing_data(output_file)
        existing_locations = {item.get("Location"): item for item in existing_data}

        for item in data:
            location = item.get("Location")
            if location and location not in existing_locations:
                lat, lng = fetch_coordinates(location, api_key)
                if lat is not None and lng is not None:
                    item["Latitude"] = lat
                    item["Longitude"] = lng
                else:
                    item["Latitude"] = None
                    item["Longitude"] = None

                # Add new data to existing data
                existing_data.append(item)

                # Save incrementally
                save_data_incrementally(output_file, existing_data)

                # Sleep to avoid hitting API rate limits
                time.sleep(1)

        print(f"Updated JSON saved to {output_file}")

    except FileNotFoundError:
        print(f"File {input_file} not found.")
    except json.JSONDecodeError:
        print("Error decoding JSON from input file.")

if __name__ == "__main__":
    api_key = "8b78ca7fc3df440a96e4c64c416a4bf3"
    input_file = "Programma_Televisivo_con_Stagioni_clean.json"
    output_file = "Programma_Televisivo_con_Stagioni_with_coordinates.json"
    add_coordinates_to_json(input_file, output_file, api_key)

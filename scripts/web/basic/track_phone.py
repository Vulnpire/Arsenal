import phonenumbers
from phonenumbers import geocoder, carrier
from opencage.geocoder import OpenCageGeocode
import folium

phone_number = "+123123123123"  # Replace this with the actual phone number

pep_number = phonenumbers.parse(phone_number)

# Get location information
location = geocoder.description_for_number(pep_number, "en")
print("Location:", location)

# Get service provider information
service_provider = carrier.name_for_number(pep_number, "en")
print("Service Provider:", service_provider)

# Use OpenCage Geocoder to get detailed location information
key = '' # Your API Key
geocoder = OpenCageGeocode(key)
query = str(location)
results = geocoder.geocode(query)
print("Geocoding Results:", results)

# Check if results are empty before accessing elements
if results:
    # Extract latitude and longitude from geocoding results
    lat = results[0]['geometry']['lat']
    lng = results[0]['geometry']['lng']
    print("Latitude:", lat)
    print("Longitude:", lng)

    # Create a map and add a marker
    my_map = folium.Map(location=[lat, lng], zoom_start=9)
    folium.Marker([lat, lng], popup=location).add_to(my_map)

    # Save the map as an HTML file
    my_map.save("track.html")
else:
    print("No geocoding results found for the location:", location)
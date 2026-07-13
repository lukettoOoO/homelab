import time
import requests

API_URL = "https://olympus-luca.online"

print("Starting Network Monitor Service...")

while True:
    try:
        response = requests.get(API_URL, timeout=5)
        print(cls_name := f"Check successful: {API_URL} returned HTTP {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Alert! Connection failed: {e}")
    
    time.sleep(5)

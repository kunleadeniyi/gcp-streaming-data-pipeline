
import json
import random
import datetime
import uuid
# import numpy
import requests

url = "http://localhost:8080/publish"

platforms = ['XBox', 'PC', 'PlayStation', 'Android', 'iOS', 'PS5']

login_event = {
    'platform': random.choice(platforms),
    'last_login_time': int((datetime.datetime.now().timestamp() * 1e6) - (random.randint(30, 86400) * 1e6)),
    'event_type': 'login'
}

def generate_event(event):
    event['event_id'] = str(uuid.uuid4())
    event['event_version'] = '1.0.0'
    event['app_version'] = 'v2.0'
    event['event_timestamp'] = int(datetime.datetime.now().timestamp() * 1e6)

    return event

def wrap_data(table_name, data):
    return {
        "table_name": table_name,
        "data": data
    }

def send(event):
    payload = json.dumps(event)
    headers = {'Content-Type': 'application/json'}
    print(payload)
    response = requests.request("POST", url, headers=headers, data=payload)
    print(response.text)


if __name__ == "__main__":
    print("calling main")

    # overwrite fields
    def overwrite_login_fields(e):
        e['platform'] = random.choice(platforms)
        e['last_login_time'] = int((datetime.datetime.now().timestamp() * 1e6) - (random.randint(30, 86400) * 1e6))

        return e

    for i in range(30):
        e = overwrite_login_fields(login_event)
        # print(e)
        e = generate_event(e)
        e = wrap_data("player_login", e)
        send(e)



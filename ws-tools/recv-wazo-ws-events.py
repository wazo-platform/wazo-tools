import json
import pprint
import ssl
import sys
import websocket

from getpass import getpass
from wazo_auth_client import Client

host = sys.argv[1]
username = sys.argv[2]
events = sys.argv[3].split(',')
password = getpass('Password for {0}: '.format(username))

auth = Client(
    host, 443, username=username, password=password, verify_certificate=False
)
token = auth.token.new(backend='wazo_user')['token']


def on_message(ws, message):
    pprint.pprint(json.loads(message))


def on_error(ws, error):
    print(error)


def on_close(ws):
    print("### closed ###")


def on_open(ws):
    for event in events:
        ws.send(json.dumps({"op": "subscribe", "data": {"event_name": event}}))
    ws.send(json.dumps({"op": "start"}))


ws = websocket.WebSocketApp(
    "wss://{host}:443/api/websocketd/?token={token}".format(host=host, token=token),
    on_message=on_message,
    on_error=on_error,
    on_close=on_close,
)
ws.on_open = on_open
ws.run_forever(sslopt={'cert_reqs': ssl.CERT_NONE})

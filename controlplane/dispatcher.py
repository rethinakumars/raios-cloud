import requests
import random
import yaml

ROUTES_FILE = "controlplane/routes/routes-aws.yaml"

def load_routes():
    with open(ROUTES_FILE, "r") as f:
        return yaml.safe_load(f)

def select_dataplane(nodes):
    healthy = [n for n in nodes if n["healthy"]]
    return random.choice(healthy)

def dispatch(service_name, action, region_state):
    routes = load_routes()
    service = routes["services"].get(service_name)

    if not service:
        return {"error": "not_found"}

    node = select_dataplane(region_state["nodes"])
    url = f"http://{node['ip']}{service['path']}?action={action}"

    try:
        resp = requests.get(url)
        return resp.json()
    except Exception:
        return {"error": "dataplane_unreachable"}


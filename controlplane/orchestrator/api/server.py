import json
from http.server import BaseHTTPRequestHandler, HTTPServer

# Import region model
from models.region import region


class RequestHandler(BaseHTTPRequestHandler):

    def _send_json(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        # Region status endpoint
        if self.path == "/region/status":
            data = {
                "region": region.name,
                "nodes": [n.to_dict() for n in region.nodes],
                "healthy": region.is_healthy(),
            }
            self._send_json(data)

        # Metadata endpoint: controlplane private IP
        elif self.path == "/metadata/controlplane-ip":
            import subprocess
            ip = subprocess.check_output("hostname -I", shell=True).decode().split()[0]
            self._send_json({"controlplane_ip": ip})

        # Default 404
        else:
            self._send_json({"error": "not_found"}, status=404)


def run_server(host="0.0.0.0", port=8080):
    server = HTTPServer((host, port), RequestHandler)
    print(f"[RAIOS] Orchestrator running on {host}:{port}")
    server.serve_forever()


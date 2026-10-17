from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from models.region import Region
from provider_aws.aws_driver import AwsDriver

region = Region()
aws_driver = AwsDriver()

class OrchestratorHandler(BaseHTTPRequestHandler):
    def _send_json(self, payload, status=200):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/region/status":
            data = {
                "region": region.name,
                "nodes": [n.to_dict() for n in region.nodes],
                "healthy": region.is_healthy(),
            }
            self._send_json(data)
        else:
            self._send_json({"error": "not_found"}, status=404)

    def do_POST(self):
        if self.path == "/register-node":
            length = int(self.headers.get("Content-Length", 0))
            raw = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                self._send_json({"error": "invalid_json"}, status=400)
                return

            node_id = payload.get("id")
            role = payload.get("role", "dataplane")
            ip = payload.get("ip")

            if not node_id or not ip:
                self._send_json({"error": "missing_fields"}, status=400)
                return

            region.add_node(node_id=node_id, role=role, ip=ip)
            self._send_json({"status": "registered", "node": node_id})
        else:
            self._send_json({"error": "not_found"}, status=404)

def run_server(host="0.0.0.0", port=8080):
    server = HTTPServer((host, port), OrchestratorHandler)
    print(f"[RAIOS] Orchestrator listening on {host}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


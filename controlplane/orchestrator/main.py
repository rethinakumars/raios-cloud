#!/usr/bin/env python3

import os
from api.server import run_server
from dispatcher import load_routes
from orchestrator.models.region import load_region_state

def main():
    # Load region topology (nodes, health, IPs)
    load_region_state()

    # Load AWS routing rules (S3, DynamoDB, SQS, Lambda)
    routes_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        "routes",
        "routes-aws.yaml"
    )
    load_routes(routes_path)

    # Start the orchestrator HTTP server
    run_server(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3

from api.server import run_server

def main():
    # In future: load config, region topology, etc.
    run_server(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()


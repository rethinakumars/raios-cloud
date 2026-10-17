class Node:
    def __init__(self, node_id, role, ip):
        self.node_id = node_id
        self.role = role
        self.ip = ip
        self.healthy = True

    def to_dict(self):
        return {
            "id": self.node_id,
            "role": self.role,
            "ip": self.ip,
            "healthy": self.healthy
        }


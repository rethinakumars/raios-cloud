from dataclasses import dataclass, field
from typing import List

@dataclass
class Node:
    id: str
    role: str
    ip: str
    healthy: bool = True

    def to_dict(self):
        return {
            "id": self.id,
            "role": self.role,
            "ip": self.ip,
            "healthy": self.healthy,
        }

@dataclass
class Region:
    name: str = "raios-region-1"
    nodes: List[Node] = field(default_factory=list)

    def add_node(self, node_id: str, role: str, ip: str):
        # Simple in‑memory registration
        existing = [n for n in self.nodes if n.id == node_id]
        if existing:
            existing[0].ip = ip
            existing[0].role = role
        else:
            self.nodes.append(Node(id=node_id, role=role, ip=ip))

    def is_healthy(self) -> bool:
        return all(n.healthy for n in self.nodes) if self.nodes else False


from dataclasses import dataclass, field
from typing import List
from models.node import Node


@dataclass
class Region:
    name: str = "raios-region-1"
    nodes: List[Node] = field(default_factory=list)

    def add_node(self, node: Node):
        # Simple in‑memory registration
        existing = [n for n in self.nodes if n.node_id == node.node_id]
        if existing:
            existing[0].ip = node.ip
            existing[0].role = node.role
        else:
            self.nodes.append(node)

    def is_healthy(self) -> bool:
        return all(n.healthy for n in self.nodes) if self.nodes else False


# Global region instance used by orchestrator
region = Region()


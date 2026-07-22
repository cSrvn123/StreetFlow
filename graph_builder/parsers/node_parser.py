import osmium
import sqlite3


class NodeParser(osmium.SimpleHandler):

    def __init__(self, db_path, routing_nodes_file):
        super().__init__()

        self.conn = sqlite3.connect(db_path)
        self.cur = self.conn.cursor()

        print("Loading routing nodes...")

        with open(routing_nodes_file, "r") as f:
            self.routing_nodes = set(int(line.strip()) for line in f)

        print(f"Loaded {len(self.routing_nodes):,} routing nodes.")

        self.node_count = 0

    def node(self, n):

        if n.id not in self.routing_nodes:
            return

        self.cur.execute(
            """
            INSERT OR IGNORE INTO nodes(id, lat, lon)
            VALUES (?, ?, ?)
            """,
            (n.id, n.location.lat, n.location.lon),
        )

        self.node_count += 1

        if self.node_count % 50000 == 0:
            print(f"Stored {self.node_count:,} nodes")

    def finish(self):
        self.conn.commit()
        self.conn.close()
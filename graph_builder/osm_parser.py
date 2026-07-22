import osmium
import sqlite3
import math

DB_PATH = "output/streetflow_graph.db"
PBF_FILE = "input/bengaluru.osm.pbf"
ROUTING_FILE = "output/routing_nodes.txt"


def distance(lat1, lon1, lat2, lon2):
    R = 6371000

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)

    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(phi1)
        * math.cos(phi2)
        * math.sin(dlambda / 2) ** 2
    )

    return 2 * R * math.atan2(math.sqrt(a), math.sqrt(1 - a))


class GraphBuilder(osmium.SimpleHandler):

    def __init__(self):
        super().__init__()

        self.conn = sqlite3.connect(DB_PATH)
        self.cur = self.conn.cursor()

        self.nodes = {}

        print("Loading routing nodes...")

        with open(ROUTING_FILE, "r") as f:
            self.routing_nodes = {
                int(line.strip())
                for line in f
            }

        print(f"Loaded {len(self.routing_nodes):,} routing nodes.")

        self.node_count = 0
        self.edge_count = 0

    def node(self, n):

        if n.id not in self.routing_nodes:
            return

        if not n.location.valid():
            return

        self.nodes[n.id] = (
            n.location.lat,
            n.location.lon,
        )

        self.cur.execute(
            """
            INSERT OR IGNORE INTO nodes(
                id,
                lat,
                lon
            )
            VALUES(?,?,?)
            """,
            (
                n.id,
                n.location.lat,
                n.location.lon,
            ),
        )

        self.node_count += 1

        if self.node_count % 50000 == 0:
            print(f"Stored {self.node_count:,} nodes...")

    def way(self, w):

        if "highway" not in w.tags:
            return

        road_type = w.tags.get("highway", "")

        speed = w.tags.get("maxspeed", "")

        oneway = (
            w.tags.get("oneway", "").lower()
            in ("yes", "1", "true")
        )

        refs = [node.ref for node in w.nodes]

        for i in range(len(refs) - 1):

            from_id = refs[i]
            to_id = refs[i + 1]

            if from_id not in self.nodes:
                continue

            if to_id not in self.nodes:
                continue

            lat1, lon1 = self.nodes[from_id]
            lat2, lon2 = self.nodes[to_id]

            dist = distance(
                lat1,
                lon1,
                lat2,
                lon2,
            )

            # Forward edge
            self.cur.execute(
                """
                INSERT INTO edges(
                    from_node,
                    to_node,
                    distance,
                    road_type,
                    speed,
                    oneway
                )
                VALUES(?,?,?,?,?,?)
                """,
                (
                    from_id,
                    to_id,
                    dist,
                    road_type,
                    speed,
                    int(oneway),
                ),
            )

            self.edge_count += 1

            # Reverse edge for two-way roads
            if not oneway:

                self.cur.execute(
                    """
                    INSERT INTO edges(
                        from_node,
                        to_node,
                        distance,
                        road_type,
                        speed,
                        oneway
                    )
                    VALUES(?,?,?,?,?,?)
                    """,
                    (
                        to_id,
                        from_id,
                        dist,
                        road_type,
                        speed,
                        0,
                    ),
                )

                self.edge_count += 1

        if self.edge_count % 100000 == 0 and self.edge_count != 0:
            print(f"Created {self.edge_count:,} edges...")

    def finish(self):

        print("Saving database...")

        self.conn.commit()

        self.conn.close()

        print("=" * 50)
        print("StreetFlow Graph Created Successfully")
        print(f"Nodes : {self.node_count:,}")
        print(f"Edges : {self.edge_count:,}")
        print("=" * 50)


if __name__ == "__main__":

    builder = GraphBuilder()

    print("Reading Bengaluru OSM...")

    builder.apply_file(
        PBF_FILE,
        locations=True,
    )

    builder.finish()
import osmium

# Roads that vehicles can use
DRIVABLE_HIGHWAYS = {
    "motorway",
    "trunk",
    "primary",
    "secondary",
    "tertiary",
    "residential",
    "living_street",
    "service",
    "unclassified",
}

OUTPUT_FILE = "output/routing_nodes.txt"


class RoadCollector(osmium.SimpleHandler):

    def __init__(self):
        super().__init__()

        self.routing_nodes = set()
        self.road_count = 0

    def way(self, w):

        highway = w.tags.get("highway")

        if highway not in DRIVABLE_HIGHWAYS:
            return

        self.road_count += 1

        for node in w.nodes:
            self.routing_nodes.add(node.ref)


collector = RoadCollector()

print("Reading OSM file...")

collector.apply_file(
    "input/bengaluru.osm.pbf",
    locations=False,
)

print("Saving routing nodes...")

with open(OUTPUT_FILE, "w") as f:
    for node_id in collector.routing_nodes:
        f.write(f"{node_id}\n")

print("=" * 40)
print(f"Roads Found      : {collector.road_count}")
print(f"Routing Nodes    : {len(collector.routing_nodes)}")
print(f"Saved to         : {OUTPUT_FILE}")
print("=" * 40)
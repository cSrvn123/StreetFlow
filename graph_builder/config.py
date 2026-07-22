import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

PBF_FILE = os.path.join(
    BASE_DIR,
    "..",
    "assets",
    "maps",
    "bengaluru.osm.pbf"
)

OUTPUT_DIR = os.path.join(BASE_DIR, "output")

DATABASE_FILE = os.path.join(
    OUTPUT_DIR,
    "streetflow_graph.db"
)
import sqlite3
import os

OUTPUT_DIR = "output"
DB_PATH = os.path.join(OUTPUT_DIR, "streetflow_graph.db")

os.makedirs(OUTPUT_DIR, exist_ok=True)

if os.path.exists(DB_PATH):
    os.remove(DB_PATH)

conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# -----------------------------
# Nodes Table
# -----------------------------
cursor.execute("""
CREATE TABLE nodes(
    id INTEGER PRIMARY KEY,
    lat REAL NOT NULL,
    lon REAL NOT NULL
)
""")

# -----------------------------
# Edges Table
# -----------------------------
cursor.execute("""
CREATE TABLE edges(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_node INTEGER NOT NULL,
    to_node INTEGER NOT NULL,
    distance REAL NOT NULL,
    road_type TEXT,
    speed REAL,
    oneway INTEGER,

    FOREIGN KEY(from_node) REFERENCES nodes(id),
    FOREIGN KEY(to_node) REFERENCES nodes(id)
)
""")

conn.commit()
conn.close()

print("=" * 40)
print("StreetFlow Graph Database Created")
print(DB_PATH)
print("=" * 40)
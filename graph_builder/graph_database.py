import sqlite3
import os
from config import DATABASE_FILE

class GraphDatabase:

    def __init__(self):
        os.makedirs(os.path.dirname(DATABASE_FILE), exist_ok=True)

        self.conn = sqlite3.connect(DATABASE_FILE)
        self.cursor = self.conn.cursor()

    def create_tables(self):

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS nodes(
            id INTEGER PRIMARY KEY,
            lat REAL,
            lon REAL
        )
        """)

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS edges(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            from_node INTEGER,
            to_node INTEGER,
            distance REAL,
            road_type TEXT,
            speed REAL,
            oneway INTEGER
        )
        """)

        self.conn.commit()

    def close(self):
        self.conn.close()
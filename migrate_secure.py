import sqlite3
from pathlib import Path

DB = Path(__file__).with_name("banco.db")
conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row
cur = conn.cursor()

def cols(table):
    return {r["name"] for r in conn.execute(f"PRAGMA table_info({table})")}

migrations = {
    "chamados": [("status_compra", "TEXT DEFAULT ''"), ("codigo", "TEXT"), ("produto", "TEXT"), ("quantidade", "REAL"), ("unidade", "TEXT")],
    "anexos": [("mensagem_id", "INTEGER")],
    "conferencias": [("lote", "TEXT"), ("peso", "REAL"), ("pei", "TEXT"), ("area_m2", "REAL")],
    "status_conferencia": [("usuario_conferiu", "TEXT"), ("data_conferencia", "TEXT")],
}
for table, additions in migrations.items():
    existing = cols(table)
    for col, spec in additions:
        if col not in existing:
            cur.execute(f"ALTER TABLE {table} ADD COLUMN {col} {spec}")
for sql in [
    "CREATE INDEX IF NOT EXISTS idx_chamados_criado_por ON chamados(criado_por)",
    "CREATE INDEX IF NOT EXISTS idx_chamados_tecnico ON chamados(tecnico_id)",
    "CREATE INDEX IF NOT EXISTS idx_mensagens_chamado ON mensagens(chamado_id)",
    "CREATE INDEX IF NOT EXISTS idx_anexos_chamado ON anexos(chamado_id)",
    "CREATE INDEX IF NOT EXISTS idx_produtos_codpro ON produtos(codpro)",
    "CREATE INDEX IF NOT EXISTS idx_furo_status ON furo_estoque(status)",
]:
    cur.execute(sql)
conn.commit()
conn.close()
print("Migrações aplicadas com sucesso.")

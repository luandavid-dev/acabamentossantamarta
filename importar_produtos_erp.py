from app import get_db_connection, get_erp_connection


def importar_produtos_do_erp():
    erp_conn = get_erp_connection()
    erp_cur = erp_conn.cursor()

    print("✅ Conectado ao ERP (SQL Server)")

    erp_cur.execute("""
        SELECT
            RTRIM(CODPRO) AS codpro,
            RTRIM(DESCRICAOLONGA) AS descricao_longa
        FROM PRODUTOCAD_V
        WHERE
            CODPRO IS NOT NULL
            AND DESCRICAOLONGA IS NOT NULL
    """)

    rows = erp_cur.fetchall()
    print(f"📦 Produtos encontrados no ERP: {len(rows)}")

    sqlite_conn = get_db_connection()
    cur = sqlite_conn.cursor()

    inseridos = 0
    atualizados = 0

    for codpro, descricao_longa in rows:
        codpro = str(codpro).strip()
        descricao_longa = str(descricao_longa).strip()

        if not codpro or not descricao_longa:
            continue

        cur.execute("""
            INSERT INTO produtos (codpro, descricao_longa)
            VALUES (?, ?)
            ON CONFLICT(codpro) DO UPDATE SET
                descricao_longa = excluded.descricao_longa
        """, (codpro, descricao_longa))

        if cur.rowcount == 1:
            inseridos += 1
        else:
            atualizados += 1

    sqlite_conn.commit()
    sqlite_conn.close()
    erp_conn.close()

    print("✅ Importação finalizada com sucesso")
    print(f"🟢 Inseridos: {inseridos}")
    print(f"🟡 Atualizados: {atualizados}")


if __name__ == "__main__":
    importar_produtos_do_erp()

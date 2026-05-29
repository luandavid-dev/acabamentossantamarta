import os
import sys

def testar():
    print("--- DIAGNÓSTICO DE CONEXÃO ERP ---")
    
    # Tentar carregar .env
    try:
        from dotenv import load_dotenv
        dotenv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env')
        if os.path.exists(dotenv_path):
            print(f"[OK] Arquivo .env encontrado em: {dotenv_path}")
            load_dotenv(dotenv_path)
        else:
            print(f"[AVISO] Arquivo .env NÃO encontrado em: {dotenv_path}")
    except ImportError:
        print("[ERRO] Biblioteca 'python-dotenv' não instalada. Rode: pip install python-dotenv")

    # Verificar variáveis
    vars_erp = {
        "ERP_DB_SERVER": os.environ.get("ERP_DB_SERVER"),
        "ERP_DB_NAME": os.environ.get("ERP_DB_NAME"),
        "ERP_DB_USER": os.environ.get("ERP_DB_USER"),
        "ERP_DB_PASSWORD": os.environ.get("ERP_DB_PASSWORD")
    }

    tudo_ok = True
    for k, v in vars_erp.items():
        if v:
            # Mostra apenas o primeiro e último caractere da senha por segurança
            display = v if "PASSWORD" not in k else f"{v[0]}***{v[-1]}" if len(v) > 2 else "***"
            print(f"[OK] {k} está definida como: {display}")
        else:
            print(f"[FALHA] {k} NÃO está definida no ambiente ou no .env")
            tudo_ok = False

    if not tudo_ok:
        print("\n[RESUMO] O sistema não vai funcionar porque faltam as variáveis acima.")
        return

    # Tentar importar pyodbc
    try:
        import pyodbc
        print("[OK] Biblioteca 'pyodbc' está instalada.")
    except ImportError:
        print("[ERRO] Biblioteca 'pyodbc' não instalada. O sistema precisa dela para o ERP.")
        return

    # Tentar conexão real
    print("\nTentando conectar ao banco de dados SQL Server...")
    try:
        driver = os.environ.get("ERP_ODBC_DRIVER", "ODBC Driver 17 for SQL Server")
        conn_str = (
            f"DRIVER={{{driver}}};"
            f"SERVER={vars_erp['ERP_DB_SERVER']};"
            f"DATABASE={vars_erp['ERP_DB_NAME']};"
            f"UID={vars_erp['ERP_DB_USER']};"
            f"PWD={vars_erp['ERP_DB_PASSWORD']};"
            "TrustServerCertificate=yes;"
            "Connection Timeout=10;"
        )
        conn = pyodbc.connect(conn_str)
        print("[SUCESSO] Conexão com o ERP realizada com sucesso!")
        conn.close()
    except Exception as e:
        print(f"[ERRO DE CONEXÃO] Não foi possível conectar ao SQL Server.")
        print(f"Detalhes do erro: {str(e)}")
        print("\nDica: Verifique se o IP está correto, se o SQL Server aceita conexões remotas e se o Driver ODBC está instalado no seu Windows/Linux.")

if __name__ == "__main__":
    testar()

import os
from sqlalchemy import create_engine, text

try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

DB_URL = os.getenv("DB_URL", "postgresql+psycopg2://postgres:santa2005@localhost:5432/olistdb")

ECHO = os.getenv("ECHO", "0") in {"1", "true", "True", "YES", "yes"}

def get_engine():
    engine = create_engine(
        DB_URL,
        echo=ECHO,
        future=True,
        pool_pre_ping=True,
        pool_recycle=1800,    
    )
    return engine

def ping(engine=None) -> bool:
    eng = engine or get_engine()
    try:
        with eng.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception as e:
        print(f"[config.py] DB ping failed: {e}")
        return False

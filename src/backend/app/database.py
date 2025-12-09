# app/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT") or "5432"
DB_NAME = os.getenv("DB_NAME")

print("DEBUG: Loaded environment variables:")
print("DB_USER =", repr(DB_USER))
print("DB_PASSWORD =", repr(DB_PASSWORD))
print("DB_HOST =", repr(DB_HOST))
print("DB_PORT =", repr(DB_PORT))
print("DB_NAME =", repr(DB_NAME))

if not all([DB_USER, DB_PASSWORD, DB_HOST, DB_NAME]):
    raise ValueError(f"Missing required DB config: USER={bool(DB_USER)}, PASS={bool(DB_PASSWORD)}, HOST={bool(DB_HOST)}, NAME={bool(DB_NAME)}")

SQLALCHEMY_DATABASE_URL = (
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require"
)
engine = create_engine(SQLALCHEMY_DATABASE_URL, echo=True)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

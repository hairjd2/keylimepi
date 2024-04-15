import sqlite3
import uuid
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

def getKey(password):
    bytePassword = password.encode()
    salt = b'deadbeefdeadbeef'
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=480000,
    )
    return base64.urlsafe_b64encode(kdf.derive(bytePassword))

if __name__ == "__main__":
    user_table_def = """
    CREATE TABLE users (
        domain TEXT,
        username TEXT,
        password TEXT
    )"""
    add_user_sql = "INSERT INTO users VALUES ('{}','{}','{}')"

    connection = sqlite3.connect("./keylimepi.db")
    cursor = connection.cursor()

    # cursor.execute(user_table_def)
    username = "testuser"
    password = "password"
    domain = "google"
    cursor.execute(add_user_sql.format(domain, username, password))

    row = cursor.execute("SELECT * FROM users WHERE username = '{}'".format(username)).fetchall()
    print(row)

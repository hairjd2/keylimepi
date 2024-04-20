import json
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from getpass import getpass

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

def readFile():
    # Opening JSON file
    f = open('./password.json')

    # returns JSON object as a dictionary
    passwords = json.load(f)

    # Closing file
    f.close()
    return passwords

def addNewPassword(userName, password, domain, passwords, masterPW):
# Data to be written
    fernet = Fernet(getKey(masterPW))
    passwords[domain] = {}
    passwords[domain]["username"] = userName
    passwords[domain]["password"] = fernet.encrypt(password.encode()).decode()

# Serializing j
    json_object = json.dumps(passwords, indent=4)

# Writing to sample.json
    with open("password.json", "w") as outfile:
        outfile.write(json_object)

def changePassword(password, domain, passwords, masterPW):
# Data to be written
    fernet = Fernet(getKey(masterPW))
    if domain not in passwords.keys():
        return

    passwords[domain]["password"] = fernet.encrypt(password.encode()).decode()

# Serializing j
    json_object = json.dumps(passwords, indent=4)

# Writing to sample.json
    with open("password.json", "w") as outfile:
        outfile.write(json_object)

def deleteDomain(domain, passwords):
    try:
        del passwords[domain]
    except:
        print("Not in the passwords")

# Serializing j
    json_object = json.dumps(passwords, indent=4)

# Writing to sample.json
    with open("password.json", "w") as outfile:
        outfile.write(json_object)

def listDomains(passwords):
    for key in passwords.keys():
        print(key)

def listDomainInfo(passwords, domain, masterPW):
    # masterPW = getpass("What is the master password: ")
    fernet = Fernet(getKey(masterPW))

    print(passwords[domain]["username"])
    print(fernet.decrypt(passwords[domain]["password"].encode()).decode())


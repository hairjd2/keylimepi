import json
from cryptography.fernet import Fernet

def readFile():
    with open('filekey.key', 'rb') as filekey:
        key = filekey.read()

    fernet = Fernet(key)

    with open('password.json', 'rb') as enc_file:
        encrypted = enc_file.read()

    decrypted = fernet.decrypt(encrypted)

    with open('password.json', 'wb') as dec_file:
        dec_file.write(decrypted)

    # Opening JSON file
    f = open('/home/keylimepi/keylimepi/rpicode/password.json')

    # returns JSON object as a dictionary
    passwords = json.load(f)

    # Closing file
    f.close()
    return passwords

def addNewPassword(userName, password, domain, passwords):
# Data to be written
    passwords[domain] = {}
    passwords[domain]["username"] = userName
    passwords[domain]["password"] = password

# Serializing j
    json_object = json.dumps(passwords, indent=4)

# Writing to sample.json
    with open("password.json", "w") as outfile:
        outfile.write(json_object)

def listDomains(passwords):
    for key in passwords.keys():
        print(key)

def listDomainInfo(passwords, domain):
    print(passwords[domain]["username"])
    print(passwords[domain]["password"])

def encryptFile():
    with open('filekey.key', 'rb') as filekey:
        key = filekey.read()

    fernet = Fernet(key)

    with open('password.json', 'rb') as file:
        original = file. read()

    encrypted = fernet.encrypt(original)

    with open('password.json', 'wb') as encrypted_file:
        encrypted_file.write(encrypted)

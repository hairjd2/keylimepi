import json
from cryptography.fernet import Fernet

def readFile():
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


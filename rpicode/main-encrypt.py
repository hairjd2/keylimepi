from password-encrypt import *
import sys

if __name__ == "__main__":
    passwords = readFile()
    if sys.argv[1] == "0":
        addNewPassword(sys.argv[2], sys.argv[3], sys.argv[4], passwords)
    if sys.argv[1] == "1":
       listDomains(passwords)
    if sys.argv[1] == "2":
        listDomainInfo(passwords, sys.argv[2])
    if sys.argv[1] == "3":
        encryptFile()

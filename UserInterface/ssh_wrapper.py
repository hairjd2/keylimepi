from pexpect import pxssh
import re

hostname = "192.168.0.10"
username = "keylimepi"
s = pxssh.pxssh()

def init_sesh(password):

    try:
        s.login(hostname, username, password)
        s.sendline('cd keylimepi/rpicode')   # run a command
        s.prompt()             # match the prompt
        print(s.before)        # print everything before the prompt.
    except pxssh.ExceptionPxssh as e:
        print("pxssh failed on login.")
        print(e)

def createPassword(username, password, domain):
    command = "python3 main.py 0 " + username + " " + password + " " + domain
    s.sendline(command)
    s.prompt()
    print(s.before)

def listDomains():
    s.sendline("python3 main.py 1")
    s.prompt()
    returnString = ''.join(map(chr, s.before))
    returnList = returnString.split()
    returnList.pop()
    returnList.pop(0)
    returnList.pop(0)
    returnList.pop(0)
    returnList.pop(0)
    print(returnList)
    return returnList

def listDomainInfo(domain):
    s.sendline("python3 main.py 2 " + domain)
    s.prompt()
    returnString = ''.join(map(chr, s.before))
    returnList = returnString.split()
    returnList.pop()
    returnList.pop(0)
    returnList.pop(0)
    returnList.pop(0)
    returnList.pop(0)
    returnList.pop(0)
    print(returnList)
    return returnList

def stopSesh():
    s.sendline("python3 main.py 3")
    s.logout()

if __name__ == "__main__":
    init_sesh("password")
    createPassword("Noln", "goodpassword", "google")
    listDomains()
    listDomainInfo("google")
    stopSesh()
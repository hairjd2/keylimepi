import paramiko

host = "raspberrypi.local"
username = "robotguy"
class Password:
    def __init__(self, password):
        self.password = password

device_password = Password("")
client = paramiko.client.SSHClient()

def validateConnection(given_password):
    device_password.password = given_password
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(host, username=username, password=device_password.password)
    except:
        return False
    return True

def createPassword(given_username, given_password, domain):
    command = "cd keylimepi/rpicode; python3 main.py 0 " + given_username + " " + given_password + " " + domain + " " + device_password.password
    _stdin, _stdout,_stderr = client.exec_command(command)
    print(_stdout.read().decode())

def changePassword(given_password, domain):
    command = "cd keylimepi/rpicode; python3 main.py 3 " + given_password + " " + domain + " " + device_password.password
    _stdin, _stdout,_stderr = client.exec_command(command)
    print(_stdout.read().decode())

def listDomains():
    command = "cd keylimepi/rpicode; python3 main.py 1"
    _stdin, _stdout,_stderr = client.exec_command(command)
    returnList = _stdout.read().decode().split()
    print(returnList)
    return returnList

def listDomainInfo(domain):
    command = "cd keylimepi/rpicode; python3 main.py 2 " + domain + " " + device_password.password
    _stdin, _stdout,_stderr = client.exec_command(command)
    returnList = _stdout.read().decode().split()
    print(returnList)
    return returnList

def deleteDomain(domain):
    command = "cd keylimepi/rpicode; python3 main.py 4 " + domain
    _stdin, _stdout,_stderr = client.exec_command(command)
    return True

def close_client():
    client.close()

# if __name__ == "__main__":
#     if validateConnection("password"):
#         print("Worked!")
#     else:
#         print("Doesn't Work")

#     createPassword("Nick", "blah", "gitlab")
#     listDomains()
#     listDomainInfo("gitlab")
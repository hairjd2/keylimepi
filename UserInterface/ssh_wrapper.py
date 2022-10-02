import paramiko

host = "192.168.0.10"
username = "keylimepi"
class Password:
    def __init__(self, password):
        self.password = password

device_password = Password("")

def validateConnection(given_password):
    device_password.password = given_password
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=device_password.password)
    command = "pwd"
    _stdin, _stdout,_stderr = client.exec_command(command)
    home = _stdout.read().decode()
    client.close()
    if home == "/home/keylimepi\n":
        return True
    else:
        return False

def createPassword(given_username, given_password, domain):
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=device_password.password)
    command = "cd keylimepi/rpicode; python3 main.py 0 " + given_username + " " + given_password + " " + domain
    _stdin, _stdout,_stderr = client.exec_command(command)
    print(_stdout.read().decode())
    client.close()

def listDomains():
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=device_password.password)
    command = "cd keylimepi/rpicode; python3 main.py 1"
    _stdin, _stdout,_stderr = client.exec_command(command)
    returnList = _stdout.read().decode().split()
    print(returnList)
    client.close()
    return returnList

def listDomainInfo(domain):
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=device_password.password)
    command = "cd keylimepi/rpicode; python3 main.py 2 " + domain
    _stdin, _stdout,_stderr = client.exec_command(command)
    returnList = _stdout.read().decode().split()
    print(returnList)
    client.close()
    return returnList

# if __name__ == "__main__":
#     if validateConnection("password"):
#         print("Worked!")
#     else:
#         print("Doesn't Work")

#     createPassword("Nick", "blah", "gitlab")
#     listDomains()
#     listDomainInfo("gitlab")
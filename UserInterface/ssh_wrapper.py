import pexpect

username = "keylimepi@192.168.0.10"
child = pexpect.spawn("ssh " + username)

def init_session(password):
    child.expect("password: ")
    child.sendline(password)
    i = child.expect(["Permission denied", "Terminal type", "[#\$]"])

    if i == 0:
        print("Permission denied by host. Unable to login")
        child.kill(0)
        return False
    elif i == 1:
        print("Connected Successfully.\nTerminal type is not set.")
        child.sendline("vt100")
        child.expect("[#\$]")
    elif i == 2:
        print("Connected Successfully.")
        child.sendline("python3 pwkeylymepi/rpicode/main.py")
        prompt = child.after
        print("Shell Command Prompt: ", prompt.decode("utf-8"))
        # child.kill(0)
        return True

def create_password():
    child.sendline("0")
    child.sendline("join")
    child.sendline("password")
    child.sendline("geeksforgeeks")
    child.kill(0)
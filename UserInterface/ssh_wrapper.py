import pexpect
import os

username = "pi@192.168.0.10"
password = "password"

child = pexpect.spawn("ssh " + username)
child.expect("password: ")
child.sendline(password)
i = child.expect(["Permission denied", "Terminal type", "[#\$]"])

if i == 0:
    print("Permission denied by host. Unable to login")
    child.kill(0)
elif i == 1:
    print("Connected Successfully.\nTerminal type is not set.")
    child.sendline("vt100")
    child.expect("[#\$]")
elif i == 2:
    print("Connected Successfully.")
    prompt = child.after
    print("Shell Command Prompt: ", prompt.decode("utf-8"))
    child.kill(0)

print()
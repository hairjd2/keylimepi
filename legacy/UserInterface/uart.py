import serial

class DataTypes:
    DOMAIN_DATA_TYPE = 0
    USERNAME_DATA_TYPE = 1
    PASSWORD_DATA_TYPE = 2

###################################################################
#
#   get_pw_count()
#   Description:
#   Writes the read password count command and receives every byte
#   to get up to date number of bytes. This is typically done at
#   the start so that the python program can get an active count 
#   to keep track of and update
#
###################################################################
def get_pw_count():
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    ser.write(bytes.fromhex("FF")) 
    ser.write(bytes.fromhex("00"))
    readstr = b""

    for i in range(64):
        readstr = ser.read(1) + readstr # Receive the count

    ser.close()
    return int.from_bytes(readstr, byteorder='big') # Return big endian number

###################################################################
#
#   set_pw_count(num_pw)
#   Parameter:
#   - num_pw (int): Number of passwords to write  
#   Description:
#   Writes the write password count command and gives new password
#   count
#
###################################################################
def set_pw_count(num_pw: int):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    ser.write(bytes.fromhex("7F")) # Read password count command
    ser.write(bytes.fromhex("00")) # Doesn't matter what we write here

    for i in range(64-len(int.to_bytes(num_pw))):
        ser.write(bytes.fromhex('00')) # Pad front with zeros to fill up expected 64 bytes
    ser.write(int.to_bytes(num_pw)) # Write actual data
    
    readstr = ""
    for i in range(4):
        readstr = ser.read(1).decode("ascii") + readstr # Read status (Should just be "done")

    ser.close()
    return readstr

##################################################################
#
#   get_data(cmd, address)
#   parameters:
#   - cmd (int): Command saying to perform a read and what data 
#   type to retreive
#   - address (int): Address to retrieve data from
#   Description:
#   Function takes in string of command to convert to byte 
#   string, and the address as an integer and performs a read
#
##################################################################
def get_data(cmd: str, address: int):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200) # Create serial session
    ser.write(bytes.fromhex(cmd)) # Write command
    ser.write(int.to_bytes(address)) # Write the address
    readstr = ""

    for i in range(64):
        readstr = ser.read(1).decode("ascii") + readstr # Read all 64 bytes

    ser.close()
    return readstr

###################################################################
#
#   set_data(cmd, address, data)
#   parameters:
#   - cmd (int): Command saying to perform a write and what data 
#   type to write
#   - address (int): Address to write data to
#   - data (str): Data to write
#   Description:
#   Function takes in string of command to convert to byte 
#   string, and the address as an integer and performs a write
#
###################################################################
def set_data(cmd: str, address: int, data: str):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    ser.write(bytes.fromhex(cmd)) # Send command
    ser.write(int.to_bytes(address)) # Send address
    
    for i in range(64-len(data)):
        ser.write(bytes.fromhex('00')) # Pads front with zeros
    ser.write(data) # Write the actual data
    
    readstr = ""
    for i in range(4):
        readstr = ser.read(1).decode("ascii") + readstr # Read status (Should just be "done")

    ser.close()
    return readstr

###################################################################
#
#   read(data_type, address)
#   parameters:
#   - data_type (int): What type of data to update
#   - address (int): Address to read data from
#   Description:
#   Takes in constant int type of data and calls the get_data 
#   function.
#
###################################################################
def read(data_type: int, address: int):
    cmd = 80
    match data_type:
        case DataTypes.DOMAIN_DATA_TYPE:
            cmd += 0 # Start at offset 0
        case DataTypes.USERNAME_DATA_TYPE:
            cmd += 2 # Read from offset 2
        case DataTypes.PASSWORD_DATA_TYPE:
            cmd += 3 # Read from offset 3
        case _:
            print("Not a valid data type")
            return ""
    
    readstr = get_data(str(cmd), address)
    if(data_type == 0):
        readstr += get_data(str(cmd+1), address) # Read from the second 64 bytes of the domain names
    return readstr

###################################################################
#
#   write(data_type, address, data)
#   parameters:
#   - data_type (int): What type of data to update 
#   type to write
#   - address (int): Address to write data to
#   - data (str): Data to write
#   Description:
#   Takes in constant int type of data to write to and calls the 
#   set_data function.
#
###################################################################
def write(data_type: int, address: int, data: str):
    cmd = 0
    match data_type:
        case DataTypes.DOMAIN_DATA_TYPE:
            cmd += 0 # Start at offset 0
        case DataTypes.USERNAME_DATA_TYPE:
            cmd += 2 # Write to offset 2
        case DataTypes.PASSWORD_DATA_TYPE:
            cmd += 3 # Write to offset 3
        case _:
            print("Not a valid data type")
            return ""
    
    readstr = set_data("0" + str(cmd), address, data[0:63].encode("ascii")) # Want to substring the data up to 64 characters (64 bytes)
    if(data_type == 0):
        readstr = set_data("0" + str(cmd+1), address, data[63:].encode("ascii")) # Write to second 64 bytes of the domain names
    return readstr

###################################################################
#
#   listDomains(num_pw)
#   parameters:
#   - num_pw (int): Password count
#   Description:
#   Lists each domain name
#
###################################################################
def listDomains(num_pw: int):
    print("----------Domains----------")
    for i in range(num_pw):
        readstr = read(DataTypes.DOMAIN_DATA_TYPE, i) # Read domain name of each iteration of the loop
        print(f"{i+1}. {readstr}")
    print("---------------------------")

###################################################################
#
#   listDomainInfo(num_pw)
#   parameters:
#   - num_pw (int): Password count
#   - domain (int): Domain selection
#   Description:
#   Reads all piece of data of given 
#
###################################################################
def listDomainInfo(domain: int, num_pw: int):
    if(domain > num_pw): # Return if given invalid domain
        print("This is not a valid domain")
        return

    # Read and print out each piece of data for requested domain
    readstr = read(0, domain-1)
    print("Domain:", readstr)
    readstr = read(1, domain-1)
    print("Username:", readstr)
    readstr = read(2, domain-1)
    print("Password:", readstr)

###################################################################
#
#   createPassword(domain, username, password, num_pw)
#   parameters:
#   - domain (str): New domain name
#   - username (str): New username
#   - password (str): New password
#   - num_pw (int): Password count
#   Description:
#   Writes new domain name, username, and password, as well as
#   increments the password count
#
###################################################################
def createPassword(domain: str, username: str, password: str, num_pw: int):
    # Write to the FPGA
    write(DataTypes.DOMAIN_DATA_TYPE, num_pw, domain)
    write(DataTypes.USERNAME_DATA_TYPE, num_pw, username)
    write(DataTypes.PASSWORD_DATA_TYPE, num_pw, password)

    # Increments password count and updates it
    num_pw += 1
    readstr = set_pw_count(num_pw)
    return num_pw

###################################################################
#
#   changeUsername(domain, username, num_pw)
#   parameters:
#   - domain (int): Domain Selection
#   - username (str): New Username
#   - num_pw (int): Password count
#   Description:
#   Change username of given domain
#
###################################################################
def changeUsername(domain: int, username: str, num_pw: int):
    if(domain > num_pw): # Trying to change username of a domain name that doesn't exist
        print("This is not a valid domain")
        return
    else:
        write(DataTypes.USERNAME_DATA_TYPE, domain-1, username) # Write new username

###################################################################
#
#   changePassword(domain, password, num_pw)
#   parameters:
#   - domain (int): Domain Selection
#   - password (str): New password
#   - num_pw (int): Password count
#   Description:
#   Change password of given domain
#
###################################################################
def changePassword(domain: int, password: str, num_pw: int):
    if(domain > num_pw): # Trying to change password of a domain name that doesn't exist
        print("This is not a valid domain")
        return
    else:
        write(DataTypes.PASSWORD_DATA_TYPE, domain-1, password) # Write new password

###################################################################
#
#   deleteDomain(domain, num_pw)
#   parameters:
#   - domain (int): Domain Selection
#   - num_pw (int): Password count
#   Description:
#   Starting from selected domain, reads the next domain, username,
#   and password and replacing the current domain. Zeroizes the last
#   domain and decrements the password count.
#
####################################################################
def deleteDomain(domain: int, num_pw: int):
    # Want to make sure the user is sure they want to absolutely remove the domain
    confirm = input("Are you sure? (Deleting this will zeroize out the data and can only be retreived manually) (y/N): ")
    if(confirm == "y"):
        pass
    else:
        return num_pw
    
    # Replace each domain to next one
    curr_pw = domain
    while(curr_pw < num_pw):
        new_domain = read(0, curr_pw)
        write(0, curr_pw-1, new_domain[1:128])
        new_username = read(1, curr_pw)
        write(1, curr_pw-1, new_username[1:64])
        new_password = read(2, curr_pw)
        write(2, curr_pw-1, new_password[1:64])
        curr_pw += 1
    
    # Zeroize last entry
    write(DataTypes.DOMAIN_DATA_TYPE, curr_pw-1, "")
    write(DataTypes.USERNAME_DATA_TYPE, curr_pw-1, "")
    write(DataTypes.PASSWORD_DATA_TYPE, curr_pw-1, "")
    
    # Decrement and update password count
    set_pw_count(num_pw - 1)
    return num_pw - 1

###################################################################
#
#   int()
#   Description:
#   Gets the stored password count, displays it and all domains
#
###################################################################
def init():
    num_pw = get_pw_count()
    print("There are", num_pw, "password(s) stored.")
    listDomains(num_pw)
    return num_pw

# Example UI for the functions above, to be replaced by GUI
def run():
    choice = 0
    num_pw = init()

    while(choice != 7):
        print("\nWhat would you like to do?")
        print("1. List Domains")
        print("2. List Domain Information")
        print("3. Add Password")
        print("4. Change Username")
        print("5. Change Password")
        print("6. Remove Password")
        print("7. Quit")
        choice = int(input("What would you like to do?: "))

        if(choice == 1):
            listDomains(num_pw)
        elif(choice == 2):
            listDomains(num_pw)
            domain = int(input("Which domain would you like to look at?: "))
            listDomainInfo(domain, num_pw)
        elif(choice == 3):
            domain = input("What is the domain name: ")
            username = input("What is your username: ")
            password = input("What is your password: ")
            num_pw = createPassword(domain, username, password, num_pw)
        elif(choice == 4):
            listDomains(num_pw)
            domain = int(input("Which domain would you like to change the username of: "))
            username = input("What is the new username: ")
            changeUsername(domain, username, num_pw)
        elif(choice == 5):
            listDomains(num_pw)
            domain = int(input("Which domain would you like to change the password of: "))
            password = input("What is the new password: ")
            changePassword(domain, password, num_pw)
        elif(choice == 6):
            listDomains(num_pw)
            domain = int(input("Which domain would you like to remove: "))
            num_pw = deleteDomain(domain, num_pw)
        elif(choice == 7):
            break

if __name__ == "__main__":
    run()

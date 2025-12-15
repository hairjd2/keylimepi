import serial

def get_data(data_type, address):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = data_type
    ser.write(bytes.fromhex(str))
    str = address
    ser.write(bytes.fromhex(str))
    readstr = ""

    for i in range(64):
        readstr = ser.read(1).decode("ascii") + readstr

    ser.close()
    return readstr

def set_data(data_type, address, data):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = data_type
    ser.write(bytes.fromhex(str))
    str = address
    ser.write(bytes.fromhex(str))
    for i in range(64-len(data)):
        ser.write(bytes.fromhex('00'))
    str = data.encode("ascii")
    ser.write(str)
    readstr = ""

    for i in range(4):
        readstr = ser.read(1).decode("ascii") + readstr

    ser.close()
    return readstr

def write():
    data_type = input("What kind of data type would you like to read? Domain name (d), username (u) or password (p): ")
    address = input("What address would you like read from (in hex)?: ")
    data = input("What would you like to write: ")
    cmd = 0
    
    if(data_type == "d"):
        cmd += 0
    elif(data_type == "u"):
        cmd += 2
    elif(data_type == "p"):
        cmd += 3
    else:
        print("Not a valid data type")
        return
    
    string = "0" + str(cmd)
    readstr = set_data("0" + str(cmd), address, data[0:63])
    if(data_type == "d"):
        readstr = set_data("0" + str(cmd+1), address, data[63:])
    print("Writing ", data, " to address ", address, ": ", readstr)

def read():
    data_type = input("What kind of data type would you like to read? Domain name (d), username (u) or password (p): ")
    address = input("What address would you like read from (in hex)?: ")
    cmd = 80
    
    if(data_type == "d"):
        cmd += 0
    elif(data_type == "u"):
        cmd += 2
    elif(data_type == "p"):
        cmd += 3
    else:
        print("Not a valid data type")
        return
    
    readstr = get_data(str(cmd), address)
    if(data_type == "d"):
        readstr += get_data(str(cmd+1), address)
    print("Reading at address ", address, ": ", readstr)

def get_pw_count():
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = "FF"
    ser.write(bytes.fromhex(str))
    str = "00" # Doesn't matter what we write here
    ser.write(bytes.fromhex(str))
    readstr = b""

    for i in range(64):
        # readstr = ser.read(1).decode("ascii") + readstr
        readstr = ser.read(1) + readstr

    ser.close()
    # print("Got type ", int(readstr.decode("ascii"), 16))
    print("Got count ", readstr, " ", int.from_bytes(readstr, byteorder='big'))
    # print("Got count", int.from_bytes(readstr, byteorder='big'))
    # return int.from_bytes(readstr, byteorder='big')
    # int(readstr, 16)

def set_pw_count(num_pw):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = "7F"
    ser.write(bytes.fromhex(str))
    str = "00"
    ser.write(bytes.fromhex(str))
    print(int.to_bytes(num_pw), "with length", len(int.to_bytes(num_pw)))
    for i in range(64-len(int.to_bytes(num_pw))):
        ser.write(bytes.fromhex('00'))
    ser.write(int.to_bytes(num_pw))
    readstr = ""

    for i in range(4):
        readstr = ser.read(1).decode("ascii") + readstr

    ser.close()
    return readstr

def run():
    choice = 0

    while(choice != 5):
        print("1. Read")
        print("2. Write")
        print("3. Read Count")
        print("4. Write Count")
        print("5. Quit")
        choice = int(input("What would you like to do?: "))

        if(choice == 1):
            read()
        elif(choice == 2):
            write()
        elif(choice == 3):
            get_pw_count()
        elif(choice == 4):
            num_pw = input("What would you like to write: ")
            set_pw_count(int(num_pw))
        elif(choice == 5):
            break

if __name__ == "__main__":
    run()

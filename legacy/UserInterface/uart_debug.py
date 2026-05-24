import serial

def get_data(cmd, address):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    # Send command read RAM command
    str = cmd
    ser.write(bytes.fromhex(str))
    # Send rest of the address
    str = address
    ser.write(bytes.fromhex(str))
    readstr = ""
    response = ""

    if address[-1] == "3" or address[-1] == "7" or address[-1] == "b" or address[-1] == "f":
        total_len = 60
    else:
        total_len = 64

    # Read the length (ignore for now)
    read_len = ser.read(1)

    print("Got length ", int.from_bytes(read_len))

    readstr = ser.read(total_len).decode("ascii")
    # readstr = ser.read(int.from_bytes(read_len)).decode("ascii")

    # Read status response
    # for i in range(4):
      #  response = response + ser.read(1).decode("ascii")
    response = ser.read(4).decode("ascii")

    print("Finished read successfully: ", response)

    ser.close()
    return readstr

def set_data(cmd, address, data_len, data):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    # Write the command
    str = cmd
    ser.write(bytes.fromhex(str))
    # Send the rest of the address
    str = address
    ser.write(bytes.fromhex(str))
    # Send the data length
    str = data_len
    ser.write(bytes.fromhex(str))

    if address[-1] == "3" or address[-1] == "7" or address[-1] == "b" or address[-1] == "f":
        total_len = 60
    else:
        total_len = 64

    print("Padding data with ", total_len-len(data), " zeros")
    for i in range(total_len-len(data)):
        ser.write(bytes.fromhex('00'))
    str = data.encode("ascii")
    ser.write(str)

    response = ""

    for i in range(4):
        response = response + ser.read(1).decode("ascii")

    print("Finished read successfully: ", response)
    ser.close()
    return response

def get_reg(cmd, address):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    # Send command read RAM command
    str = cmd
    ser.write(bytes.fromhex(str))
    # Send rest of the address
    str = address
    ser.write(bytes.fromhex(str))
    readstr = ""
    response = ""

    readstr = ser.read(4)

    # Read status response
    # for i in range(4):
      #  response = response + ser.read(1).decode("ascii")
    response = ser.read(4).decode("ascii")

    print("Finished read successfully: ", response)

    ser.close()
    return readstr

def set_reg(cmd, address, data):
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)

    str = cmd
    ser.write(bytes.fromhex(str))

    str = address
    ser.write(bytes.fromhex(str))
    response = ""

    print(data[0:2])
    print(data[2:4])
    print(data[4:6])
    print(data[6:8])

    ser.write(bytes.fromhex(data))
    
    response = ser.read(4).decode("ascii")

    print("Finished write successfully: ", response)

    ser.close()

# def set_data(data_type, address, data):
#     ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
#     str = data_type
#     ser.write(bytes.fromhex(str))
#     str = address
#     ser.write(bytes.fromhex(str))
#     str = 64
#     ser.write(str)
#     for i in range(64-len(data)):
#         ser.write(bytes.fromhex('00'))
#     str = data.encode("ascii")
#     ser.write(str)
#     readstr = ""

#     for i in range(4):
#         readstr = ser.read(1).decode("ascii") + readstr

#     ser.close()
#     return readstr

def read():
    cmd = input("What is the command you would like to send?: ")
    address = input("What is the rest of the address (including the data type at the end): ")

    readstr = get_data(cmd, address)
    print("Reading at address ", cmd[3:], address, ": ", readstr)
    # data_type = input("What kind of data type would you like to read? Domain name (d), username (u) or password (p): ")
    # address = input("What address would you like read from (in hex)?: ")
    # cmd = 80
    
    # if(data_type == "d"):
    #     cmd += 0
    # elif(data_type == "u"):
    #     cmd += 2
    # elif(data_type == "p"):
    #     cmd += 3
    # else:
    #     print("Not a valid data type")
    #     return
    
    # readstr = get_data(str(cmd), address)
    # if(data_type == "d"):
    #     readstr += get_data(str(cmd+1), address)
    # print("Reading at address ", address, ": ", readstr)

def write():
    cmd = input("What is the command you would like to send?: ")
    address = input("What address would you like read from (in hex)?: ")
    data_len = input("What is the length of the data? (in hex): ")
    data = input("What would you like to write: ")

    
    # string = "0" + str(cmd)
    readstr = set_data(cmd, address, data_len, data)
    print("Writing ", data, " to address ", address, ": ", readstr)

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
            cmd = input("What is the command you would like to send?: ")
            addr = input("What is the rest of the address: ")
            reg_data = get_reg(cmd, addr)
            print("Got register value: ", reg_data)
        elif(choice == 4):
            cmd = input("What is the command you would like to send?: ")
            addr = input("What is the rest of the address: ")
            data = input("What is data you would like to set the data at?: ")
            set_reg(cmd, addr, data)
        elif(choice == 5):
            break

if __name__ == "__main__":
    run()

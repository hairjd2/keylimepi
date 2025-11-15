import serial
from nifpga import Session

# def test():
#     ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
#     # print(ser.name)
#     str = '81'
#     ser.write(bytes.fromhex(str))
#     str = '01'
#     ser.write(bytes.fromhex(str))
#     readstr = ""

#     for i in range(4):
#         readstr = ser.read(1).decode("ascii") + readstr

#     print("Reading at address 1: ", readstr)

#     str = '01'
#     ser.write(bytes.fromhex(str))
#     readstr = ""

#     for i in range(4):
#         readstr = ser.read(1).decode("ascii") + readstr

#     print("Writing 'Fuck' to address 0: ", readstr)

#     str = '81'
#     ser.write(bytes.fromhex(str))
#     str = '00'
#     ser.write(bytes.fromhex(str))
#     readstr = ""

#     for i in range(4):
#         readstr = ser.read(1).decode("ascii") + readstr
        
#     print("Reading at address 0: ", readstr)
#     ser.close()

def read():
    address = input("What address would you like read from (in hex)?: ")
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = '81'
    ser.write(bytes.fromhex(str))
    str = address
    ser.write(bytes.fromhex(str))
    readstr = ""

    for i in range(4):
        readstr = ser.read(1).decode("ascii") + readstr

    print("Reading at address ", address, ": ", readstr)
    ser.close()

def write():
    address = input("What address would you like to write to (in hex)?: ")
    data = input("What would you like to write: ")
    ser = serial.Serial("/dev/ttyUSB1", baudrate=115200)
    str = '01'
    ser.write(bytes.fromhex(str))
    str = address
    ser.write(bytes.fromhex(str))
    readstr = ""

    for i in range(64):
        readstr = ser.read(1).decode("ascii") + readstr

    print("Writing ", data, " to address ", address, ": ", readstr)
    ser.close()

def run():
    choice = 0

    while(choice != 3):
        print("1. Read")
        print("2. Write")
        print("3. Quit")
        choice = int(input("What would you like to do?: "))

        if(choice == 1):
            read()
        elif(choice == 2):
            write()
        elif(choice == 3):
            break

if __name__ == "__main__":
    run()

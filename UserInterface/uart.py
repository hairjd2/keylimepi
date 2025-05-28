import serial

ser = serial.Serial("COM11", baudrate=115200)
print(ser.name)
str = b'HHeelllloo  WWoorrlldd!!\n\n'
rd_str = []
ser.write(str)
for i in range(int(len(str) / 2)): # TODO: Why do they do this?
    print(ser.read(1))
print(rd_str)
# ser.write(str[0:1])
# ser.write(str[1])
# print(ser.read())
ser.close()
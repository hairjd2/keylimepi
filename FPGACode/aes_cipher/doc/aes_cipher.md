# AES Cipher
- Information gained from this guy doing the same thing: https://medium.com/@imgouravsaini/aes-algorithm-and-its-hardware-implementation-on-fpga-a-step-by-step-guide-2bef178db736
- Based on AES-128
- Allows for up to 16 characters for passwords
- May want to genericize it to be also 256 or 512 (increase the amount of rounds and parameterize the input width)
- The AES algorithm’s operations are performed on a two-dimensional array of bytes called the State
- Copy the input array into the state array as: `s[r c]=input[r+4c]`
- The four bytes form 32-bit words in each column of the State array, where the row number r provides an index for the four bytes within each word. 
- Accordingly, the state can be represented as a one-dimensional sequence of 32-bit words (columns), w0 … w3, where the column number c provides an index. 
- State can be considered as an array of four words, as follows:
    - w0 = s0,0 s1,0 s2,0 s3,0 w2 = s0,2 s1,2 s2,2 s3,2
    - w1 = s0,1 s1,1 s2,1 s3,1 w3 = s0,3 s1,3 s2,3 s3,3
- Each round, except for the last consists of:
    1. Substitute bytes
    2. Shift rows
    3. Mix columns
    4. Add round key
- The last round just does not mix columns
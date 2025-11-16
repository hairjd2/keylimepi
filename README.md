# Keylime Pi
2FA token for logging into applications, as well as a password manager. 
## History
This project started off as a hackathon project (which we won first place) that my friends and I worked on. It revolved around using a Raspberry pi that would connect through usb. The client computer would start an automated ssh session with the raspberry pi and called python scripts on it. As you can imagine, this was very inefficient, as it would take awhile to wait for any reads and writes.

Due to my love of FPGAs and digital design, I decided to go with an FPGA approach, using programmable logic to make it more efficient.
## Design
The end product consists of a pcb that connects to the user's computer through usb. The pcb will contain a flash chip, an FPGA, and ic to translate uart signals to usb.

For communication with the FPGA, I decided to use uart, since its fairly simple and the slower speeds should not be too much of an issue since not alot of data will need to go back and forth during run time. I created a custom command protocol on top of that to be efficient with how many bytes would need to be sent at a time.

In terms of storage, the domain names, usernames, and passwords will all be stored in BRAM during runtime, but will be stored permanently on the flash. Once the FPGA is booted and brought out of reset, a module loads up the BRAM by reading every address of the flash and writing it to the BRAM. Then, during runtime, while the control logic is not performing a read or write, the memory control will go through each address of the BRAM and write that data back to the flash. That way there is no concern of stale data if the usb is unexpectedly unplugged.

Something I still need to design is how to boot the FPGA. My preliminary thought is to have the user store the bit file with their application, and have the application boot the FPGA. That way any updates could also be an update of the bit file to address any security concerns. I still need to figure out a way to boot the bit file on the FPGA without needing to use vivado.
## Repository Layout
### FPGACode
- HDL implementation that includes modules for:
    - Encrypting plaintext being stored
    - Decrypting passwords being sent back to computer
    - Storage interfacing
- Still a work in progress
### lcd
- Code used to drive an external lcd display for debugging purposes
### rpicode (Legacy)
- The code that sits on the raspberry pi storing the passwords
- Will probably be removed soon
### UserInterface
- gui.py
  - Made during Hackathon
  - Uses tkinter to create a gui in python
  - Calls ssh_wrapper.py functions (as of now, soon to change)
- ssh_wrapper.py
  - Legacy code
  - Created to create the ssh session on raspberry pi and call the python scripts
- uart.py
  - Might be renamed, gives a very basic user interface to either read or write to the FPGA with my custom protocol
# Current progress
- Prototype version of this made with raspberry pi during Hackathon.
## FPGA
- Able to now take in reads and writes, with an offset.

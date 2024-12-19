# Serial Interface
- Will prototype using already defined interaction with the UART to send and receive data
- Have RX and TX work simultaneously, let control logic handle using them
## AXI UARTLITE
- Can only handle a byte at a time
- RX and TX are async from each other
## Read controller
- Support for two (or possibly three) types of reading
    1. short_read: read 1 byte (meant for reading command or even a response from the computer)
    2. Long read: read 4 or 16 bytes (longer data like passwords)
    3. Long long read: If long read does only 4 bytes, then this can be 16 bytes. Could also be good if password support allows up to 32 characters (read 32 bytes)
- Interface:
    - Input pipeline
        - `input rd_in_cmd`: (for now only supports short and long read) a '0' for short read and a '1' for a long read
        - `input rd_in_val`: user of interface saying the command given is valid
        - `output rd_in_rdy`: interface saying its ready for next command
    - Output pipeline
        - `output [DATA_WIDTH-1:0] rd_out_data`: The data that was read
        - `output rd_out_cmd`: Says if the read was a short or long read
        - `output rd_out_val`: informs when data out is valid
        - `input rd_out_rdy`: says user is ready for data
## Write controller 
- Only need an input interface for right now
- Might later support a feedback output if necessary
- Has similar short and long writes to read controller
- Interface:
    - Input pipeline
        - `input [DATA_WIDTH-1:0] wr_in_data`: The data that needs to be written
        - `input wr_in_cmd`: Says if the read was a short or long write
        - `input wr_in_val`: informs when data out is valid
        - `output wr_in_rdy`: says user is ready for data
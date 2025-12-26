use serialport::available_ports;
use std::time::Duration;

const DOMAIN_CODE: u32 = 0;
const USERNAME_CODE: u32 = 1;
const PASSWORD_CODE: u32 = 2;

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// # Description:
///   Writes the read password count command and receives every byte
///   to get up to date number of bytes. This is typically done at
///   the start so that the python program can get an active count 
///   to keep track of and update
fn get_pw_count(path: &String) -> u32 {
    // Open the port
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    // Send the "read pw count" command and address 0 as filler
    let cmd: [u8; 2] = [255, 0];
    port.write(&cmd).expect("Get Password command failed");

    // Read 64 bytes from the FPGA
    let mut serial_buf: Vec<u8> = vec![0; 64];
    port.read(serial_buf.as_mut_slice()).expect("Failed to receive number of passwords");

    // concatenate each byte into one 32 bit integer
    let num_pw = ((serial_buf[3] as u32) << 24) | 
                        ((serial_buf[2] as u32) << 16) | 
                        ((serial_buf[1] as u32) << 8) | 
                        (serial_buf[0] as u32);

    return num_pw;
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords to write
/// # Description:
///   Writes the write password count command and gives new password
///   count
fn set_pw_count(path: &String, num_pw: u32) -> String {
    // Open port
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    // Send the "read pw count" command then send address 0 as filler
    let cmd: [u8; 2] = [127, 0];
    port.write(&cmd).expect("Get Password command failed");

    // Create empty array of 64 bytes, and fill with little endian representation of integer
    let mut output: [u8; 64] = [0; 64];
    let num_output: [u8; 4] = num_pw.to_le_bytes();
    for i in 0..4 {
        output[63-i] = num_output[i];
    }

    // Write final full 64 byte array
    port.write(&output).expect("Write failed!");

    // Receive "Done" status and return
    let mut serial_buf: Vec<u8> = vec![0; 4];
    port.read(serial_buf.as_mut_slice()).expect("Failed to get status for setting data");

    let write_stat = match str::from_utf8(&serial_buf) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };
    
    // Need to reverse the string (TODO: Should look into reversing the data on FPGA)
    return write_stat.to_string().chars().rev().collect::<String>();
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - cmd (u8): The command to send to receive data.
/// - address (u8): Address to read from
/// # Description:
/// Function takes in string of command to convert to byte 
/// array, and the address as an integer and performs a read
fn get_data(path: &String, cmd: u8, address: u8) -> String {
    // Open port
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    // Send the command and address
    let setup: [u8; 2] = [cmd, address];
    port.write(&setup).expect("Get Data command failed");

    // Read the full 64 bytes
    let mut serial_buf: Vec<u8> = vec![0; 64];
    port.read(serial_buf.as_mut_slice()).expect("Failed to retreive data");

    // Convert vector to string
    let data = match str::from_utf8(&serial_buf) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };

    // Return string reversed
    return data.to_string().chars().rev().collect::<String>();
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - cmd (u8): The command to send to transmit data.
/// - address (u8): Address to write to
/// - data (String): 
/// # Description:
/// Function takes in string of command to convert to byte 
/// array, and the address as an integer and performs a write
fn set_data(path: &String, cmd: u8, address: u8, data: String) -> String {
    // Open port
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    // Send the command and address
    let setup: [u8; 2] = [cmd, address];
    port.write(&setup).expect("Set Data command failed");

    // Write to the full 64 bytes, filling in the rest with 0
    let mut output: [u8; 64] = [0; 64];
    for i in 0..data.len() {
        output[i] = data.as_bytes()[i];
    }
    port.write(&output).expect("Failed to set data");

    // Get response word (only expecting "Done")
    let mut serial_buf: Vec<u8> = vec![0; 4];
    port.read(serial_buf.as_mut_slice()).expect("Failed to get status for setting data");

    // Convert to String
    let write_stat = match str::from_utf8(&serial_buf) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };

    // Return reversed
    return write_stat.to_string().chars().rev().collect::<String>();
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - data_type (u32): The type of data to read from
/// - address (u8): Address of page to read from
/// # Description:
/// Takes in constant int type of data and calls the get_data 
/// function.
fn read(path: &String, data_type: u32, address: u8) -> String {
    // Set command based on the data type
    let cmd: u8 = match data_type {
        DOMAIN_CODE => 128, // 0x80
        USERNAME_CODE => 130, // 0x82
        PASSWORD_CODE => 131, // 0x83
        _ => 128,
    };

    // Get the data based on the command and address
    let data: String = get_data(path, cmd, address);

    // If the data type is domain, we need to read the second half of it
    if data_type == DOMAIN_CODE {
        let second_half: String = get_data(path, cmd+1, address);

        let data = format!("{second_half}{data}");

        return data;
    }

    return data;
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - data_type (u32): The type of data to write
/// - address (u8): Address of page to write to
/// - data (String): Data to write
/// # Description:
/// Takes in constant int type of data to write to and calls the 
/// set_data function.
fn write(path: &String, data_type: u32, address: u8, data: String) -> String {
    // Set command based on data type
    let cmd: u8 = match data_type {
        DOMAIN_CODE => 0, // 0x00
        USERNAME_CODE => 2, // 0x02
        PASSWORD_CODE => 3, // 0x03
        _ => 0, // 0x00
    };

    // If the data type is domain, we need to make two writes
    if data_type == DOMAIN_CODE {
        let first_half: String;
        let second_half: String;

        // The 128 bytes need to be padded
        // If the string is larger than 64 bytes, it needs to be split
        if data.len() > 64 {
            first_half = data[0..63].trim().to_string();
            second_half = data[64..].to_string();   
        } else {
            first_half = data.trim().to_string();
            second_half = String::from("");
        }

        // Send the two writes and get the status of the second write because
        // if the first one doesn't work, the second one wouldn't either
        set_data(path, cmd, address, first_half);
        let write_stat: String = set_data(path, cmd+1, address, second_half);

        return write_stat;
    } else {
        // Just need to send the data once 
        let write_stat: String = set_data(path, cmd, address, data.trim().to_string());

        return write_stat;
    }
}

/// # Description:
/// This function is meant to be called at the start and returns
/// the path of the port and the number of passwords. Loops through
/// every possible path to open up a port. If opening up a port, 
/// does not error, get the number of passwords.
pub fn find_path() -> (String, u32) {
    // Initialize the data and get all available ports
    let mut num_pw: u32 = 0;
    let ports = available_ports().expect("No ports found!");
    
    // Loop through every serialport
    for p in ports {
        // If we're able to connect to port, attempt to get number of passwords
        let port_name: String = p.port_name.clone();
        if let Ok(port) = serialport::new(p.port_name, 115_200).timeout(Duration::from_millis(100)).open() {
            drop(port);
            let path: String = port_name;
            num_pw = get_pw_count(&path);
            return (path, num_pw);
        }
        
    }

    // If none matches, return "None"
    let path: String = String::from("None");

    return (path, num_pw);
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// # Description:
/// Returns a vector of all domains
pub fn list_domains(path: &String, num_pw: u32) -> Vec<String>{
    // Initialize domains vector
    let mut domains: Vec<String> = Vec::new();

    // Loop through number of passwords
    // Read the domain at i, then push to the vector
    for i in 0..num_pw {
        let domain: String = read(path, DOMAIN_CODE, i as u8);
        domains.push(domain);
    }

    return domains;
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// - domain (u8): Choice of domain
/// # Description:
/// Returns string of domain, username, and password
pub fn list_domain_info(path: &String, num_pw: u32, domain: u8) -> (String, String, String) {
    // If domain is greater than number of passwords, returns error as stirng
    if domain > num_pw as u8 {
        println!("This is not a valid domain");
        return ("Error".to_string(), "Error".to_string(), "Error".to_string());
    }

    // Performs reads of each data type, then returns them
    let domain_str: String = read(path, DOMAIN_CODE, domain-1);
    let username_str: String = read(path, USERNAME_CODE, domain-1);
    let password_str: String = read(path, PASSWORD_CODE, domain-1);

    return (domain_str, username_str, password_str);
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// - domain (String): String of new domain
/// - username (String): String of new username
/// - password (String): String of new password
/// # Description:
/// Adds new password entry
pub fn create_domain(path: &String, num_pw: u32, domain: String, username: String, password: String) -> (u32, String) {
    // Write each data type to number of passwords address (Writing to new page)
    write(path, DOMAIN_CODE, num_pw as u8, domain);
    write(path, USERNAME_CODE, num_pw as u8, username);
    write(path, PASSWORD_CODE, num_pw as u8, password);

    // Increment number of passwords and update the keylimepi
    let new_num_pw = num_pw + 1;
    let write_stat: String = set_pw_count(path, new_num_pw);
    return (new_num_pw, write_stat);
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// - domain (u8): Choice of domain
/// - username (String): String of new username
/// # Description:
/// Updates the username field in the given domain entry
pub fn change_username(path: &String, num_pw: u32, domain: u8, username: String) -> String{
    let write_stat: String;
    if domain > num_pw as u8 {
        println!("This is not a valid domain");
        write_stat = "InvalidAddr".to_string();
    } else {
        write_stat = write(path,USERNAME_CODE, domain-1, username);
    }

    return write_stat;
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// - domain (u8): Choice of domain
/// - password (String): String of new password
/// # Description:
/// Updates the password field in the given domain entry
pub fn change_password(path: &String, num_pw: u32, domain: u8, password: String) -> String {
    let write_stat: String;
    if domain > num_pw as u8 {
        println!("This is not a valid domain");
        write_stat = "InvalidAddr".to_string();
    } else {
        write_stat = write(path,PASSWORD_CODE, domain-1, password);
    }

    return write_stat;
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// - num_pw (u32): Number of passwords
/// - domain (u8): Choice of domain
/// # Description:
/// Starting from selected domain, reads the next domain, username,
/// and password and replacing the current domain. Zeroizes the last
/// domain and decrements the password count.
pub fn delete_domain(path: &String, num_pw: u32, domain: u8) -> (u32, String) {
    // Start at given domain and loop through each entry
    let mut curr_pw: u8 = domain;
    while curr_pw < num_pw as u8 {
        // Write the next entry into current entry
        let new_domain: String = read(path, DOMAIN_CODE, curr_pw);
        write(path, DOMAIN_CODE, curr_pw-1, new_domain);
        let new_username: String = read(path, USERNAME_CODE, curr_pw);
        write(path, USERNAME_CODE, curr_pw-1, new_username);
        let new_password: String = read(path, PASSWORD_CODE, curr_pw);
        write(path, PASSWORD_CODE, curr_pw-1, new_password);
        curr_pw += 1;
    }

    // Write all 0 into the last entry to zeroize it
    write(path, DOMAIN_CODE, curr_pw-1, "".to_string());
    write(path, USERNAME_CODE, curr_pw-1, "".to_string());
    write(path, PASSWORD_CODE, curr_pw-1, "".to_string());

    // Decrement number of passwords and update entry on device
    let new_num_pw: u32 = num_pw - 1;
    let write_stat: String = set_pw_count(path, new_num_pw);
    return (new_num_pw, write_stat);
}

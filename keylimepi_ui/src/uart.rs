use serialport::available_ports;
use std::time::Duration;

const DOMAIN_CODE: u32 = 0;
const USERNAME_CODE: u32 = 1;
const PASSWORD_CODE: u32 = 2;

pub fn list_ports() {
    let ports = available_ports().expect("No ports found!");
    for p in ports {
        println!("{}", p.port_name);
    }
}

/// # Parameters:
/// - path (&String ): Path to device to open the serial port
/// # Description:
///   Writes the read password count command and receives every byte
///   to get up to date number of bytes. This is typically done at
///   the start so that the python program can get an active count 
///   to keep track of and update
pub fn get_pw_count(path: &String) -> u32 {
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
        .timeout(Duration::from_millis(1000))
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

fn get_data(path: &String, cmd: u8, address: u8) -> String {
    // Open port
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(1000))
        .open()
        .expect("Failed to open port");

    let setup: [u8; 2] = [cmd, address];
    
    port.write(&setup).expect("Get Data command failed");

    let mut serial_buf: Vec<u8> = vec![0; 64];
    port.read(serial_buf.as_mut_slice()).expect("Failed to retreive data");

    let data = match str::from_utf8(&serial_buf) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };

    return data.to_string().chars().rev().collect::<String>();
}

fn set_data(path: &String, cmd: u8, address: u8, data: String) -> String {
    let mut port = serialport::new(path, 115_200)
        .timeout(Duration::from_millis(1000))
        .open()
        .expect("Failed to open port");

    let setup: [u8; 2] = [cmd, address];

    port.write(&setup).expect("Set Data command failed");

    let mut output: [u8; 64] = [0; 64];
    for i in 0..data.len() {
        output[i] = data.as_bytes()[i];
    }
    port.write(&output).expect("Failed to set data");

    let mut serial_buf: Vec<u8> = vec![0; 4];
    port.read(serial_buf.as_mut_slice()).expect("Failed to get status for setting data");

    let write_stat = match str::from_utf8(&serial_buf) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };

    return write_stat.to_string().chars().rev().collect::<String>();
}

fn read(path: &String, data_type: u32, address: u8) -> String {
    let cmd: u8 = match data_type {
        DOMAIN_CODE => 128, // 0x80
        USERNAME_CODE => 130, // 0x82
        PASSWORD_CODE => 131, // 0x83
        _ => 128,
    };

    let data: String = get_data(path, cmd, address);

    if data_type == DOMAIN_CODE {
        let second_half: String = get_data(path, cmd+1, address);

        let data = format!("{second_half}{data}");

        return data;
    }

    return data;
}

fn write(path: &String, data_type: u32, address: u8, data: String) -> String {
    let cmd: u8 = match data_type {
        DOMAIN_CODE => 0, // 0x00
        USERNAME_CODE => 2, // 0x02
        PASSWORD_CODE => 3, // 0x03
        _ => 0, // 0x00
    };

    if data_type == DOMAIN_CODE {
        let first_half: String;
        let second_half: String;

        if data.len() > 64 {
            first_half = data[0..63].trim().to_string();
            second_half = data[64..].to_string();   
        } else {
            first_half = data.trim().to_string();
            second_half = String::from("");
        }

        set_data(path, cmd, address, first_half);
        let write_stat: String = set_data(path, cmd+1, address, second_half);

        return write_stat;
    } else {
        let write_stat: String = set_data(path, cmd, address, data.trim().to_string());

        return write_stat;
    }
}

pub fn list_domains(path: &String, num_pw: u32) -> Vec<String>{
    let mut domains: Vec<String> = Vec::new();

    for i in 0..num_pw {
        let domain: String = read(path, DOMAIN_CODE, i as u8);
        domains.push(domain);
    }

    return domains;
}

pub fn list_domain_info(path: &String, num_pw: u32, domain: u8) -> (String, String, String) {
    if domain > num_pw as u8 {
        println!("This is not a valid domain");
        return ("Error".to_string(), "Error".to_string(), "Error".to_string());
    }

    let domain_str: String = read(path, DOMAIN_CODE, domain-1);
    let username_str: String = read(path, USERNAME_CODE, domain-1);
    let password_str: String = read(path, PASSWORD_CODE, domain-1);

    return (domain_str, username_str, password_str);
}

pub fn create_domain(path: &String, num_pw: u32, domain: String, username: String, password: String) -> (u32, String) {
    write(path, DOMAIN_CODE, num_pw as u8, domain);
    write(path, USERNAME_CODE, num_pw as u8, username);
    write(path, PASSWORD_CODE, num_pw as u8, password);

    let new_num_pw = num_pw + 1;
    let write_stat: String = set_pw_count(path, new_num_pw);
    return (new_num_pw, write_stat);
}

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

pub fn delete_domain(path: &String, num_pw: u32, domain: u8) -> (u32, String) {
    let mut curr_pw: u8 = domain;
    while curr_pw < num_pw as u8 {
        let new_domain: String = read(path, DOMAIN_CODE, curr_pw);
        write(path, DOMAIN_CODE, curr_pw-1, new_domain);
        let new_username: String = read(path, USERNAME_CODE, curr_pw);
        write(path, USERNAME_CODE, curr_pw-1, new_username);
        let new_password: String = read(path, PASSWORD_CODE, curr_pw);
        write(path, PASSWORD_CODE, curr_pw-1, new_password);
        curr_pw += 1;
    }

    write(path, DOMAIN_CODE, curr_pw-1, "".to_string());
    write(path, USERNAME_CODE, curr_pw-1, "".to_string());
    write(path, PASSWORD_CODE, curr_pw-1, "".to_string());

    let new_num_pw: u32 = num_pw - 1;
    let write_stat: String = set_pw_count(path, new_num_pw);
    return (new_num_pw, write_stat);
}

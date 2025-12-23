use serialport::available_ports;
use std::time::Duration;

fn list_ports() {
    let ports = available_ports().expect("No ports found!");
    for p in ports {
        println!("{}", p.port_name);
    }
}

fn get_pw_count() -> u32 {
    let mut num_pw: u32 = 0;

    // let port = serialport::new("/dev/ttyUSB1", 115_200)
    //     .timeout(Duration::from_millis(10))
    //     .open()
    //     .expect("Failed to open port");

    

    return num_pw;
}

fn set_pw_count(num_pw: u32)  {
    // let mut port = serialport::new("/dev/ttyUSB1", 115_200)
    //     .timeout(Duration::from_millis(10))
    //     .open()
    //     .expect("Failed to open port");

    // let output: [u8; 4] = num_pw.to_be_bytes();
    // println!("Big-endian bytes: {:?}", output);

    // port.write(&output).expect("Write failed!");
}

fn get_data(cmd: String, address: u32) -> String {
    let mut data: String = String::new();
    return data;
}

fn set_data(cmd: String, address: u32, data: String) {

}

fn read(data_type: u32, address: u32) -> String {
    let mut data: String = String::new();
    return data;
}

fn write(data_type: u32, address: u32, data: String) {

}

pub fn init() -> u32 {
    let mut num_pw = get_pw_count();
    list_domains(num_pw);
    return num_pw;
}

pub fn list_domains(num_pw: u32) {
    println!("----------Domains----------");
    for i in 0..num_pw {
        let readstr: String = read(0, i);
        let j: u32 = i + 1;
        println!("{j}. {readstr}");
    }
}

pub fn list_domain_info(num_pw: u32, domain: u32) {
    
}

pub fn create_domain(num_pw: u32, domain: String, username: String, password: String) {
    
}

pub fn change_username(num_pw: u32, domain: u32, username: String) {

}

pub fn change_password(num_pw: u32, domain: u32, password: String) {
    
}

pub fn delete_domain(num_pw: u32, domain: u32) {
    
}
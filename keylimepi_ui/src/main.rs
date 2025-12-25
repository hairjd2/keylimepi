use std::io;

mod uart;
mod gui;

// Helper function to get user input integer
fn get_num_input() -> u8 {
    // Initialize new string
    let mut input = String::new();
    // Get from stdin
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");

    // trim, parse, and make sure it can be converted to a u8
    let input: u8 = match input.trim().parse() {
        Ok(num) => num,
        Err(_) => return 0,
    };

    return input;
}

fn start_list_domains(path: &String, num_pw: u32) {
    // Get a vector of domain strings, then loop through and list each one
    let mut domains: Vec<String> = uart::list_domains(path, num_pw);
    println!("----------Domains----------");
    let mut j = 1;
    for domain in domains.iter_mut() {
        println!("{j}. {domain}");
        j += 1;
    }
    println!("---------------------------");
}

fn start_list_domain_info(path: &String, num_pw: u32) {
    start_list_domains(&path, num_pw);
    println!("Which domain would you like to look at?: ");
    let domain = get_num_input();
    let (domain_str, username_str, password_str) =uart::list_domain_info(path, num_pw, domain);

    println!("Domain: {domain_str}");
    println!("Username: {username_str}");
    println!("Password: {password_str}");
}

fn start_create_domain(path: &String, num_pw: u32) -> u32 {
    println!("What is the domain name: ");
    let mut domain = String::new();
    io::stdin()
        .read_line(&mut domain)
        .expect("Failed to read line");

    println!("What is your username: ");
    let mut username = String::new();
    io::stdin()
        .read_line(&mut username)
        .expect("Failed to read line");

    println!("What is your password: ");
    let mut password = String::new();
    io::stdin()
        .read_line(&mut password)
        .expect("Failed to read line");

    let domain_result: String = domain.clone();

    let (new_num_pw, write_stat) = uart::create_domain(path, num_pw, domain, username, password);

    if write_stat == "Done" {
        print!("Successfully created new entry for your login at {domain_result}");
    } else {
        print!("Failed to create new entry for your login at {domain_result}")
    }
    return new_num_pw;
}

fn start_change_username(path: &String, num_pw: u32) {
    start_list_domains(&path, num_pw);
    println!("Which domain would you like to change the username of: ");
    let domain = get_num_input();

    println!("What is your new username: ");
    let mut username = String::new();
    io::stdin()
        .read_line(&mut username)
        .expect("Failed to read line");

    uart::change_username(path, num_pw, domain, username);
}

fn start_change_password(path: &String, num_pw: u32) {
    start_list_domains(&path, num_pw);
    println!("Which domain would you like to change the username of: ");
    let domain = get_num_input();

    println!("What is your new password: ");
    let mut password = String::new();
    io::stdin()
        .read_line(&mut password)
        .expect("Failed to read line");

    uart::change_password(path, num_pw, domain, password);
}

fn start_delete_domain(path: &String, num_pw: u32) -> u32 {
    start_list_domains(&path, num_pw);

    println!("Which domain would you like to remove: ");
    let domain = get_num_input();

    let (new_num_pw, write_stat) = uart::delete_domain(path, num_pw, domain);

    if write_stat == "Done" {
        println!("Successfully deleted domain");
    } else {
        println!("Failed to delete domain")
    }
    return new_num_pw;
}

pub fn init() -> (String, u32) {
    println!("Available ports:");
    uart::list_ports();
    println!("What is your Keylimepi connected to?: ");
    let mut path: String = String::new();
    io::stdin()
        .read_line(&mut path)
        .expect("Failed to read line");

    path = path.trim().to_string();

    let num_pw = uart::get_pw_count(&path);

    start_list_domains(&path, num_pw);
    return (path, num_pw);
}

fn main() {
    gui::main_gui();
    
    let mut conn_info: (String, u32) = init();

    conn_info.0 = String::from("/dev/ttyUSB1");

    loop {
        println!("1. List Domains");
        println!("2. List Domain Information");
        println!("3. Add Domain");
        println!("4. Change Username");
        println!("5. Change Password");
        println!("6. Delete Domain");
        println!("7. Quit");
        println!("\nWhat would you like to do?: ");

        let mut choice = String::new();

        io::stdin()
            .read_line(&mut choice)
            .expect("Failed to read line");

        let choice: u32 = match choice.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        if choice == 1 {
            start_list_domains(&conn_info.0, conn_info.1);
        } else if choice == 2 {
           start_list_domain_info(&conn_info.0, conn_info.1);
        } else if choice == 3 {
            conn_info.1 = start_create_domain(&conn_info.0, conn_info.1);
        } else if choice == 4 {
            start_change_username(&conn_info.0, conn_info.1);
        } else if choice == 5 {
            start_change_password(&conn_info.0, conn_info.1);
        } else if choice == 6 {
            conn_info.1 = start_delete_domain(&conn_info.0, conn_info.1);
        } else if choice == 7 {
            println!("Buh-bye :)");
            break;
        }
    }

}
use std::io;

mod uart;

fn get_num_input() -> u32 {
    let mut input = String::new();

    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");

    let input: u32 = match input.trim().parse() {
        Ok(num) => num,
        Err(_) => return 0,
    };

    return input;
}

fn start_list_domain_info(num_pw: u32) {
    uart::list_domains(num_pw);
    println!("Which domain would you like to look at?: ");
    let domain = get_num_input();
    uart::list_domain_info(num_pw, domain);
}

fn start_create_domain(num_pw: u32) {
    uart::list_domains(num_pw);

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

    uart::create_domain(num_pw, domain, username, password);
}

fn start_change_username(num_pw: u32) {
    uart::list_domains(num_pw);
    println!("Which domain would you like to change the username of: ");
    let mut domain = get_num_input();

    println!("What is your new username: ");
    let mut username = String::new();
    io::stdin()
        .read_line(&mut username)
        .expect("Failed to read line");

    uart::change_username(num_pw, domain, username);
}

fn start_change_password(num_pw: u32) {
    uart::list_domains(num_pw);
    println!("Which domain would you like to change the username of: ");
    let mut domain = get_num_input();

    println!("What is your new password: ");
    let mut password = String::new();
    io::stdin()
        .read_line(&mut password)
        .expect("Failed to read line");

    uart::change_password(num_pw, domain, password);
}

fn start_delete_domain(num_pw: u32) {
    uart::list_domains(num_pw);

    println!("Which domain would you like to remove: ");
    let mut domain = get_num_input();

    uart::delete_domain(num_pw, domain);
}

fn main() {
    let mut num_pw: u32 = uart::init();

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
            uart::list_domains(num_pw);
        } else if choice == 2 {
           start_list_domain_info(num_pw);
        } else if choice == 3 {
            start_create_domain(num_pw);
        } else if choice == 4 {
            start_change_username(num_pw);
        } else if choice == 5 {
            start_change_password(num_pw);
        } else if choice == 6 {
            start_delete_domain(num_pw);
        } else if choice == 7 {
            println!("Buh-bye :)");
            break;
        }
    }

}
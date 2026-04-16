use crate::uart;

#[cfg(test)]

#[test]
fn test_fpga_clear() {
    let (path, num_pw) = uart::find_path();
    assert_ne!(path, "");
    assert_eq!(num_pw, 0);
}

#[test]
fn test_add_creds() {
    let (path, num_pw) = uart::find_path();
    assert_ne!(path, "");
    assert_eq!(num_pw, 0);

    let (new_num_pw, write_stat) = uart::create_domain(&path, 
                                                                    num_pw, 
                                                            "domain".to_string(), 
                                                        "username".to_string(), 
                                                        "password".to_string());

    assert_eq!(new_num_pw, 1);
    assert_eq!(write_stat, "DONE");

    let (new_num_pw, write_stat) = uart::delete_domain(&path,
                                                                    new_num_pw, 
                                                                    1);

    assert_eq!(new_num_pw, 0);
    assert_eq!(write_stat, "DONE");
}

#[test]
fn test_verify_creds() {
    let (path, num_pw) = uart::find_path();
    assert_ne!(path, "");
    assert_eq!(num_pw, 0);

    let (new_num_pw, write_stat) = uart::create_domain(&path, 
                                                                    num_pw, 
                                                            "domain".to_string(), 
                                                        "username".to_string(), 
                                                        "password".to_string());

    assert_eq!(new_num_pw, 1);
    assert_eq!(write_stat, "DONE");

    let (domain_str, username_str, password_str) =uart::list_domain_info(&path, 1, 1);

    assert_eq!(domain_str.replace('\0', ""), "namedomain".to_string()); // TODO: Blatantly wrong
    assert_eq!(username_str.replace('\0', ""), "username".to_string());
    assert_eq!(password_str.replace('\0', ""), "password".to_string());


    let (new_num_pw, write_stat) = uart::delete_domain(&path,
                                                                    new_num_pw, 
                                                                    1);

    assert_eq!(new_num_pw, 0);
    assert_eq!(write_stat, "DONE");
}

#[test]
fn test_verify_creds2() {
    let (path, num_pw) = uart::find_path();
    assert_ne!(path, "");
    assert_eq!(num_pw, 0);

    let (new_num_pw, write_stat) = uart::create_domain(&path, 
                                                                    num_pw, 
                                                            "domain".to_string(), 
                                                        "username".to_string(), 
                                                        "password".to_string());

    assert_eq!(new_num_pw, 1);
    assert_eq!(write_stat, "DONE");

    let (domain_str, username_str, password_str) =uart::list_domain_info(&path, 1, 1);

    assert_eq!(domain_str.replace('\0', ""), "namedomain".to_string());
    assert_eq!(username_str.replace('\0', ""), "username".to_string());
    assert_eq!(password_str.replace('\0', ""), "password".to_string());


    let (new_num_pw, write_stat) = uart::delete_domain(&path,
                                                                    new_num_pw, 
                                                                    1);

    assert_eq!(new_num_pw, 0);
    assert_eq!(write_stat, "DONE");
}

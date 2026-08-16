# Control Logic
- Coordinates the operations of:
    - Serial interface
    - Storage interface
    - Register file
## State machine
- Has 8 states:
    - init
    - validate_password
    - wrong_password
    - idle
    - unknown_cmd
    - store_password
    - op_result
    - get_password

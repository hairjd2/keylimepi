# Force the project creation, and set the board part to be the ZYBO Z7-10
create_project -force keylimepi_fpga ./keylimepi_fpga -part xc7s50csga324-1

# Add source files, add more here when we need to or have it read from a list
add_files { \
    ../src/ip/cred_ram/cred_ram.xci \
    ../src/ip/uart_buf/uart_buf.xci \
    ../src/rtl/keylimepi_fpga/keylimepi_pkg.sv \
    ../src/rtl/regmap/regmap.sv \
    ../src/rtl/serial_interface/UART_RX.sv \
    ../src/rtl/serial_interface/UART_TX.sv \
    ../src/rtl/cred_sync/bram_if.sv \
    ../src/rtl/ctrl_logic/ctrl_logic.sv \
    ../src/rtl/cred_sync/cred_sync.sv \
    ../src/rtl/rv_fifo/rv_fifo.sv \
    ../src/rtl/cred_sync/serdes.sv \
    ../src/rtl/serial_interface/serial_interface.sv \
    ../src/rtl/cred_sync/spi_if.sv \
    ../src/rtl/keylimepi_fpga/keylimepi_fpga_top.sv \
}

# Add the master constraint file
add_files -fileset constrs_1 { \
    ../src/constraints/keylimepi_debug.xdc \
    ../src/constraints/keylimepi_fpga.xdc \
}

# Have it update the compile order of the sources
update_compile_order -fileset sources_1

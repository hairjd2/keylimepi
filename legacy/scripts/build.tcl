set design_name keylimepi_fpga
set fpga_part xc7s50csga324-1
set make_target [lindex $argv 0] 

# set reference directories for source files
set src_dir [file normalize "./../src"]
set rtl_dir [file normalize "$src_dir/rtl"]
set ip_dir [file normalize "$src_dir/ip"]
set const_dir [file normalize "$src_dir/constraints"]
set origin_dir [file normalize "."]

proc setup_project {rtl_dir ip_dir const_dir origin_dir} {

    # set top module
    set_property top "keylimepi_fpga_top" [current_fileset]

    # add source files
    read_verilog -sv "$rtl_dir/keylimepi_fpga/keylimepi_pkg.sv"
    read_verilog -sv "$rtl_dir/regmap/regmap.sv"
    read_verilog -sv "$rtl_dir/serial_interface/UART_RX.sv"
    read_verilog -sv "$rtl_dir/serial_interface/UART_TX.sv"
    read_verilog -sv "$rtl_dir/pw_sync/bram_if.sv"
    read_verilog -sv "$rtl_dir/ctrl_logic/ctrl_logic.sv"
    read_verilog -sv "$rtl_dir/pw_sync/pw_sync.sv"
    read_verilog -sv "$rtl_dir/rv_fifo/rv_fifo.sv"
    read_verilog -sv "$rtl_dir/pw_sync/serdes.sv"
    read_verilog -sv "$rtl_dir/serial_interface/serial_interface.sv"
    read_verilog -sv "$rtl_dir/pw_sync/spi_if.sv"
    read_verilog -sv "$rtl_dir/keylimepi_fpga/keylimepi_fpga_top.sv"

    read_ip "${ip_dir}/pw_ram/pw_ram.xci"
    read_ip "${ip_dir}/uart_buf/uart_buf.xci"

    read_xdc "${const_dir}/keylimepi_fpga.xdc"
    read_xdc "${const_dir}/keylimepi_debug.xdc"

    # Set project properties
    set obj [current_project]
    set _xil_proj_name_ "keylimepi_fpga"
    set proj_dir [get_property directory [current_project]]
    set_property -name "board_part_repo_paths" -value "[file normalize "$origin_dir/../../../../../.Xilinx/Vivado/2023.2/xhub/board_store/xilinx_board_store"]" -objects $obj
    set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
    set_property -name "enable_resource_estimation" -value "0" -objects $obj
    set_property -name "enable_vhdl_2008" -value "1" -objects $obj
    set_property -name "ip_cache_permissions" -value "read write" -objects $obj
    set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
    set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
    set_property -name "part" -value "xc7s50csga324-1" -objects $obj
    set_property -name "revised_directory_structure" -value "1" -objects $obj
    set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
    set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
    set_property -name "simulator_language" -value "Mixed" -objects $obj
    set_property -name "sim_compile_state" -value "1" -objects $obj
    set_property -name "use_inline_hdl_ip" -value "1" -objects $obj
    set_property -name "webtalk.modelsim_export_sim" -value "10" -objects $obj
    set_property -name "webtalk.questa_export_sim" -value "10" -objects $obj
    set_property -name "webtalk.riviera_export_sim" -value "10" -objects $obj
    set_property -name "webtalk.vcs_export_sim" -value "10" -objects $obj
    set_property -name "webtalk.xsim_export_sim" -value "10" -objects $obj
    set_property -name "webtalk.xsim_launch_sim" -value "76" -objects $obj
    set_property -name "xpm_libraries" -value "XPM_MEMORY" -objects $obj
}

if {$make_target eq "create_project"} {
    create_project -force $::design_name/$::design_name $origin_dir -part $::fpga_part
    setup_project $rtl_dir $ip_dir $const_dir $origin_dir
}

if {[string compare $argv "build"] == 0} {
    # setup_project $rtl_dir $ip_dir $const_dir $origin_dir
    setup_project $rtl_dir $ip_dir $const_dir $origin_dir

    # synth
    synth_design -top "top_${design_name}" -part ${fpga_part}

    # place and route
    opt_design
    place_design
    route_design

    # write bitstream
    write_bitstream -force "${origin_dir}/${arch}/${design_name}.bit"
}

# pw_ram/pw_ram.xci
# keylimepi_fpga.xdc
# ctrl_logic/sim/ctrl_logic_tb.sv

# read design sources
# read_verilog -sv "${src_dir}/clock/xc7/clock_480p.sv"
# read_verilog -sv "${src_dir}/essential/debounce.sv"
# read_verilog -sv "${origin_dir}/${arch}/top_${design_name}.sv"
# read_verilog -sv "${origin_dir}/simple_480p.sv"
# read_verilog -sv "${origin_dir}/simple_score.sv"


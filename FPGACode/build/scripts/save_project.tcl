open_project ../keylimepi_fpga.xpr

set origin_dir_loc .
write_project_tcl -force -use_bd_files -target_proj_dir .. {keylimepi_fpga.tcl}

close_project
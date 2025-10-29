open_project ../keylimepi_fpga.xpr

set_property AUTO_INCREMENTAL 0 [get_runs synth*]
set_property -name {write_incremental_synth_checkpoint} -value {False} -objects [get_runs synth*]

set origin_dir_loc .
write_project_tcl -force -use_bd_files -target_proj_dir .. {keylimepi_fpga.tcl}

close_project
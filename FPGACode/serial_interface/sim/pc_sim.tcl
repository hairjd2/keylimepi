# Top level design
read_verilog ../src/pc.sv

# Create the block memory
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list \
  CONFIG.Coe_File {D:\CMPE_Capstone\CODE\mem_files\default.coe} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Load_Init_File {true} \
  CONFIG.Memory_Type {Single_Port_ROM} \
  CONFIG.Write_Depth_A {256} \
  CONFIG.Write_Width_A {16} \
] [get_ips blk_mem_gen_0]
generate_target {instantiation_template} [get_files pc.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
generate_target all [get_files  sim.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]

# Test bench
read_verilog ../test/pc_tb.sv

save_project_as sim -force
set_property top pc_tb [get_fileset sim_1]
launch_simulation -simset sim_1 -mode behavioral
run 5us
current_fileset
quit
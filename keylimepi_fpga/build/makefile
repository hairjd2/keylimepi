XILINX_VIVADO = ${XILINX_TOOLS}vivado

create_project: 
# 	echo ${XILINX_VIVADO}
	${XILINX_VIVADO} -mode batch \
		-source scripts/build.tcl \
		-tclargs "create_project" \
		-log logs/create_project.log
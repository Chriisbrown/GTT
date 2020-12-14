# ---------------------------------------------------
# Makefile variables
VCC = ${PACKAGE_PATH}/../RuflCore/vcc.py

# VCC generates full paths, so need a full path here for handling autodependencies
PROJECT         = ${PACKAGE_PATH}/build/$(basename $(notdir ${SRC}))
VIVADO_PROJECT  = ${PROJECT}/top/top.xpr
VIVADO_SCRIPT   = ${PROJECT}/vivado.tcl
MODELSIM_SCRIPT = ${PROJECT}/modelsim.tcl

INCLUDE_PATHS  := $(addprefix -I,${INCLUDE_PATHS})
# ---------------------------------------------------

# ---------------------------------------------------
# Top-level rules
.PHONY: clean vivado vivado-gui modelsim modelsim-gui

default:
	@echo "Please specify 'clean', 'vivado', 'vivado-gui', 'modelsim' or 'modelsim-gui'"

always:

clean: _cleanall
_cleanall:
	rm -rf build
# ---------------------------------------------------

# ---------------------------------------------------
# Create the directory
${PROJECT}:
	mkdir -p $@
# ---------------------------------------------------

# ---------------------------------------------------
# Rules for Vivado
${VIVADO_SCRIPT}: ${SRC} | ${PROJECT}
	${VCC} -d ${INCLUDE_PATHS} -o $@ $< && \
	echo -e "\nProduced '$@'"

${VIVADO_PROJECT}: ${VIVADO_SCRIPT}
	cd $(dir $<) && \
  vivado -mode batch -source $(notdir $<) && \
	echo -e "\nProduced '$@'"

vivado: ${VIVADO_PROJECT}

vivado-gui: ${VIVADO_PROJECT} always
	cd $(dir $<) && \
  vivado $(notdir $<) &
# ---------------------------------------------------

# ---------------------------------------------------
# Rules for Modelsim
${MODELSIM_SCRIPT}: ${TESTBENCH} | ${PROJECT}
	${VCC} -d ${INCLUDE_PATHS} -o $@ $< && \
	for i in $(abspath $(wordlist 2,9999,${TESTBENCH})); do echo "source $$i" >> $@; done && \
	echo -e "\nProduced '$@'"

modelsim: ${MODELSIM_SCRIPT}
	cd $(dir $<) && \
	vsim -do $(notdir $<) &

modelsim-gui: ${MODELSIM_SCRIPT} always
	cd $(dir $<) && \
  vsim -i -do $(notdir $<) &

# ---------------------------------------------------

-include $(VIVADO_SCRIPT:.tcl=.d)
-include $(MODELSIM_SCRIPT:.tcl=.d)



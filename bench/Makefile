TARGET=Tx
.PHONY: $(TARGET)
RTLSRC=../rtl
all: $(TARGET)

DESIGN_FILES = $(wildcard $(RTLSRC)/*.v) $(wildcard $(RTLSRC)/*/*.v)

$(TARGET): $(TARGET).smt2
	yosys-smtbmc --dump-vcd $(TARGET).vcd -g -t 20010 $(TARGET).smt2
	yosys-smtbmc --dump-vcd $(TARGET)_i.vcd -i -g -t 110 $(TARGET).smt2

$(TARGET).smt2: $(DESIGN_FILES)
	yosys -ql $(TARGET).yslog \
		-p 'read_verilog -formal $(DESIGN_FILES)' \
		-p 'prep -top $(TARGET)_top -nordff' \
		-p 'write_smt2 -wires $(TARGET).smt2'

clean::
	rm -rf *~ *.yslog *.smt2 *.vcd

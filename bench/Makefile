TARGET=UART
.PHONY: $(TARGET)
RTLSRC=../rtl
all: $(TARGET)

DESIGN_FILES = $(wildcard $(RTLSRC)/*.v) $(wildcard $(RTLSRC)/*/*.v)

$(TARGET): $(TARGET).smt2
	yosys-smtbmc -s yices --dump-vcd $(TARGET).vcd -g -t 10 $(TARGET).smt2
	yosys-smtbmc -s yices -t 200010 $(TARGET).smt2
	yosys-smtbmc -s yices -i -t 1100 $(TARGET).smt2

$(TARGET).smt2: $(DESIGN_FILES)
	yosys -ql $(TARGET).yslog \
		-p 'read_verilog -formal $(DESIGN_FILES)' \
		-p 'prep -top test_$(TARGET) -nordff' \
		-p 'write_smt2 -wires $(TARGET).smt2'

clean::
	rm -rf *~ *.yslog *.smt2 *.vcd

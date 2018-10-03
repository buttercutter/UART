TARGET=UART
.PHONY: $(TARGET)
RTLSRC=../rtl
all: sby

DESIGN_FILES = $(wildcard $(RTLSRC)/*.v) $(wildcard $(RTLSRC)/*/*.v)

sby: $(TARGET).sby
	sby -f $(TARGET).sby

induction: $(TARGET).smt2
	yosys-smtbmc -s yices --presat --dump-vcd $(TARGET)_induction.vcd -i -t 26 $(TARGET).smt2	
	
bmc: $(TARGET).smt2
	yosys-smtbmc -s yices --presat --dump-vcd $(TARGET)_BMC.vcd -t 2000 $(TARGET).smt2
	
cover: $(TARGET).smt2
	yosys-smtbmc -s yices --presat -t 2000 -c $(TARGET).smt2

$(TARGET): $(TARGET).smt2
	yosys-smtbmc -s yices --presat --dump-vcd $(TARGET)_induction.vcd -i -t 10 $(TARGET).smt2
	yosys-smtbmc -s yices --presat --dump-vcd $(TARGET)_BMC.vcd -t 2000 $(TARGET).smt2	
	yosys-smtbmc -s yices --presat -t 2000 -c $(TARGET).smt2
	yosys-smtbmc -s yices --presat --dump-vcd $(TARGET).vcd -g -t 30 $(TARGET).smt2

$(TARGET).smt2: $(DESIGN_FILES)
	yosys -ql $(TARGET).yslog \
		-p 'read_verilog -formal $(DESIGN_FILES)' \
		-p 'prep -top test_$(TARGET) -nordff' \
		-p 'write_smt2 -wires $(TARGET).smt2'

iverilog: $(DESIGN_FILES)
	iverilog -g 2012 -g assertions -g specify -o $(TARGET).vvp -tvvp $(DESIGN_FILES) $(TARGET)_tb.v
	vvp $(TARGET).vvp

clean::
	rm -rf $(TARGET) $(TARGET)_proof $(TARGET)_cover *~ *.yslog *.smt2 *.vcd *.vvp

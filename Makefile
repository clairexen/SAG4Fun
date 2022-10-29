all: cmos32c.txt cmos32s.txt cmos64c.txt cmos64s.txt cmos64f.txt run

run: sag4fun32c sag4fun32s sag4fun64c sag4fun64s sag4fun64f
	vvp -N ./sag4fun32c
	vvp -N ./sag4fun32s
	vvp -N ./sag4fun64c
	vvp -N ./sag4fun64s
	vvp -N ./sag4fun64f

sag4fun32c: testbench.v sag4fun.v
	iverilog -D TYPE_32 -D TYPE_C -o $@ $^

sag4fun32s: testbench.v sag4fun.v
	iverilog -D TYPE_32 -D TYPE_S -o $@ $^

sag4fun64c: testbench.v sag4fun.v
	iverilog -D TYPE_64 -D TYPE_C -o $@ $^

sag4fun64s: testbench.v sag4fun.v
	iverilog -D TYPE_64 -D TYPE_S -o $@ $^

sag4fun64f: testbench.v sag4fun.v
	iverilog -D TYPE_64 -D TYPE_F -o $@ $^

cmos32c.txt: sag4fun.v
	yosys -p 'synth -flatten -top SAG4Fun32C; abc -g cmos; opt -fast' \
		-p 'tee -o cmos32c.txt stat -tech cmos; tee -a cmos32c.txt ltp -noff' sag4fun.v

cmos32s.txt: sag4fun.v
	yosys -p 'synth -flatten -top SAG4Fun32S; abc -g cmos; opt -fast' \
		-p 'tee -o cmos32s.txt stat -tech cmos; tee -a cmos32s.txt ltp -noff' sag4fun.v

cmos64c.txt: sag4fun.v
	yosys -p 'synth -flatten -top SAG4Fun64C; abc -g cmos; opt -fast' \
		-p 'tee -o cmos64c.txt stat -tech cmos; tee -a cmos64c.txt ltp -noff' sag4fun.v

cmos64s.txt: sag4fun.v
	yosys -p 'synth -flatten -top SAG4Fun64S; abc -g cmos; opt -fast' \
		-p 'tee -o cmos64s.txt stat -tech cmos; tee -a cmos64s.txt ltp -noff' sag4fun.v

cmos64f.txt: sag4fun.v
	yosys -p 'synth -flatten -top SAG4Fun64F; abc -g cmos; opt -fast' \
		-p 'tee -o cmos64f.txt stat -tech cmos; tee -a cmos64f.txt ltp -noff' sag4fun.v

clean:
	rm -f cmos32c.txt cmos32s.txt cmos64c.txt cmos64s.txt cmos64f.txt
	rm -f sag4fun32c sag4fun32s sag4fun64c sag4fun64s sag4fun64f testbench.vcd

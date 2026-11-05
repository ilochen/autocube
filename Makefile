VERILATOR ?= verilator
.PHONY: test
test:
	mkdir -p build
	$(VERILATOR) --binary --timing -Wno-fatal --Mdir build/motor --top-module motor_queue_tb rtl/motor.sv tests/motor_queue_tb.sv
	./build/motor/Vmotor_queue_tb

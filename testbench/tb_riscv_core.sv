`timescale 1ns / 1ps

module tb_riscv_core;

  // --- Parameters ---
  localparam CLK_PERIOD = 10; // 10ns = 100MHz

  // --- Testbench Signals ---
  logic clk;
  logic rst_n;

  // --- Instantiate the DUT (Device Under Test) ---
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // --- Clock Generation ---
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // --- Test Sequence ---
  initial begin
    $display("===============================================");
    $display("=  Starting RISC-V Core Simulation          =");
    $display("===============================================");

    // 1. Apply Reset
    rst_n = 1'b0;
    repeat (5) @(posedge clk); // Hold reset for a few cycles
    rst_n = 1'b1;
    $display("[%0t] Reset released.", $time);

    // 2. Run the program loaded from program.mem
    // The program.mem contains:
    // 00a00093  -> addi x1, x0, 10 (x1 = 10)
    // 01400113  -> addi x2, x0, 20 (x2 = 20)
    // 002081b3  -> add x3, x1, x2 (x3 = x1 + x2 = 10 + 20 = 30)
    // 00302023  -> sw x3, 0(x0) (store x3 to data memory address 0)
    // 00002203  -> lw x4, 0(x0) (load from data memory address 0 to x4)

    repeat (15) @(posedge clk); // Run for enough cycles for instructions to complete

    // 3. Verify final register values and memory content
    $display("\n-----------------------------------------------");
    $display("--- Final State Verification ---");
    $display("-----------------------------------------------");
    
    // Access internal signals of the DUT for verification
    // These paths might need adjustment based on your specific hierarchy
    verify_register("x1", dut.decode_stage_inst.register_file_inst.registers[1], 32'd10);
    verify_register("x2", dut.decode_stage_inst.register_file_inst.registers[2], 32'd20);
    verify_register("x3", dut.decode_stage_inst.register_file_inst.registers[3], 32'd30);
    verify_register("x4", dut.decode_stage_inst.register_file_inst.registers[4], 32'd30);

    // Verify data memory content at address 0
    // The data_memory module is instantiated inside memory_stage
    verify_memory("Data Memory[0]", dut.memory_stage_inst.data_mem_inst.memory[0], 32'd30);

    $display("\n===============================================");
    $display("= Simulation Finished.                          =");
    $display("===============================================");
    #100;
    $finish;
  end

  // --- Verification Tasks ---
  task verify_register(string name, logic [31:0] value, logic [31:0] expected);
    if (value === expected) begin
      $display("[PASS] Register %s: Expected %0d (0x%h), Got %0d (0x%h)", name, expected, expected, value, value);
    end else begin
      $error("[FAIL] Register %s: Expected %0d (0x%h), Got %0d (0x%h)", name, expected, expected, value, value);
    end
  endtask

  task verify_memory(string name, logic [31:0] value, logic [31:0] expected);
    if (value === expected) begin
      $display("[PASS] %s: Expected %0d (0x%h), Got %0d (0x%h)", name, expected, expected, value, value);
    end else begin
      $error("[FAIL] %s: Expected %0d (0x%h), Got %0d (0x%h)", name, expected, expected, value, value);
    end
  endtask

  // --- Waveform Dump (for debugging) ---
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_riscv_core);
  end

endmodule
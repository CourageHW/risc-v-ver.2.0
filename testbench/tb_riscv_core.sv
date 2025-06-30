`timescale 1ns/1ps

import defines::*;

module tb_riscv_core;

  logic clk;
  logic rst_n;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT instance
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );
  logic [31:0] x3, x4, x5;
  // Test sequence
  initial begin
    $display("=== RISC-V Core Testbench Start ===");

    rst_n = 0;
    #20;
    rst_n = 1;


    // Wait for execution to complete
    #100;

    // Check results: assuming register file is accessible via decode_stage_inst.regs
    // Example: x3 = 1, x4 = 4, x5 = 5 expected
    
    x3 = dut.decode_stage_inst.register_file_inst.registers[3];
    x4 = dut.decode_stage_inst.register_file_inst.registers[4];
    x5 = dut.decode_stage_inst.register_file_inst.registers[5];

    assert(x3 === 32'd1) else $error("❌ x3 wrong: expected 1, got %0d", x3);
    assert(x4 === 32'd4) else $error("❌ x4 wrong: expected 4, got %0d", x4);
    assert(x5 === 32'd5) else $error("❌ x5 wrong: expected 5, got %0d", x5);

    $display("✅ All register value checks passed!");
    #1000;
    $finish;
  end
endmodule

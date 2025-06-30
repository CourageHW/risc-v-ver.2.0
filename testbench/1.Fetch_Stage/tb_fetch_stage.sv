`timescale 1ns / 1ps

import defines::*;

module tb_fetch_stage;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic IF_pc_write_en_i;
  logic [DATA_WIDTH-1:0] IF_branch_target_addr_i;
  logic IF_PCSrc_i;
  
  logic [DATA_WIDTH-1:0] IF_instruction_o;
  logic [DATA_WIDTH-1:0] IF_pc_o;
  logic [DATA_WIDTH-1:0] IF_pc_plus4_o;

  // Instantiate the DUT
  fetch_stage dut (
    .clk(clk),
    .rst_n(rst_n),
    .IF_pc_write_en_i(IF_pc_write_en_i),
    .IF_branch_target_addr_i(IF_branch_target_addr_i),
    .IF_PCSrc_i(IF_PCSrc_i),
    .IF_instruction_o(IF_instruction_o),
    .IF_pc_o(IF_pc_o),
    .IF_pc_plus4_o(IF_pc_plus4_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period, 100MHz clock
  end

  // Test sequence
  initial begin
    $display("Starting fetch_stage Testbench...");

    // Initialize inputs
    IF_pc_write_en_i      = 0;
    IF_branch_target_addr_i = '0;
    IF_PCSrc_i            = 0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (IF_pc_o === '0 && IF_pc_plus4_o === 32'd4 && IF_instruction_o === 32'd1) begin
      $display("  [PASS] Reset successful.");
    end else begin
      $error("  [FAIL] Reset failed. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: Normal PC increment
    $display("\nTest 2: Normal PC increment");
    IF_pc_write_en_i = 1;
    IF_PCSrc_i       = 0; // Select PC+4
    @(posedge clk);
    if (IF_pc_o === 32'd4 && IF_pc_plus4_o === 32'd8 && IF_instruction_o === 32'h00000002) begin
      $display("  [PASS] Normal PC increment successful. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end else begin
      $error("  [FAIL] Normal PC increment failed. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end
    @(posedge clk);

    // Test 3: Branch taken
    $display("\nTest 3: Branch taken");
    IF_pc_write_en_i      = 1;
    IF_PCSrc_i            = 1; // Select branch target
    IF_branch_target_addr_i = 32'h0000_0100; // Jump to address 0x100


    @(posedge clk); // Wait for PC to update
    #1;
    if (IF_pc_o === 32'h0000_0100 && IF_pc_plus4_o === 32'h0000_0104 && IF_instruction_o === 32'h00000041) begin // Assuming instruction at 0x100/4 = 0x40 is 0x41
      $display("  [PASS] Branch taken successful. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end else begin
      $error("  [FAIL] Branch taken failed. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end
    @(posedge clk);

    // Test 4: PC hold (pc_write_en_i = 0)
    $display("\nTest 4: PC hold");
    IF_pc_write_en_i      = 0;
    IF_PCSrc_i            = 0; // Should not matter
    IF_branch_target_addr_i = 32'h0000_0500; // Should not matter
    @(posedge clk);
    if (IF_pc_o === 32'h0000_0100 && IF_pc_plus4_o === 32'h0000_0104 && IF_instruction_o === 32'h00000041) begin
      $display("  [PASS] PC hold successful. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end else begin
      $error("  [FAIL] PC hold failed. PC: %h, PC+4: %h, Instr: %h", IF_pc_o, IF_pc_plus4_o, IF_instruction_o);
    end
    @(posedge clk);

    $display("\nAll fetch_stage tests finished.");
    
    #1000;
    $finish;
  end

endmodule

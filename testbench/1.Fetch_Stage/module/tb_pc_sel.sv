`timescale 1ns / 1ps

import defines::*;

module tb_pc_sel;

  // Testbench signals
  logic [DATA_WIDTH-1:0] pc_plus4_i;
  logic [DATA_WIDTH-1:0] branch_target_addr_i;
  logic PCSrc_i;
  logic [DATA_WIDTH-1:0] pc_sel_o;

  // Instantiate the DUT
  pc_sel dut (
    .pc_plus4_i(pc_plus4_i),
    .branch_target_addr_i(branch_target_addr_i),
    .PCSrc_i(PCSrc_i),
    .pc_sel_o(pc_sel_o)
  );

  // Test sequence
  initial begin
    $display("Starting pc_sel Testbench...");

    // Test 1: PCSrc_i = 0 (select pc_plus4_i)
    pc_plus4_i = 32'h0000_0100;
    branch_target_addr_i = 32'h0000_0200;
    PCSrc_i = 1'b0;
    #1; // Allow combinational logic to settle
    if (pc_sel_o === pc_plus4_i) begin
      $display("  [PASS] Test 1 (PCSrc_i = 0) successful. Expected: %h, Got: %h", pc_plus4_i, pc_sel_o);
    end else begin
      $error("  [FAIL] Test 1 (PCSrc_i = 0) failed. Expected: %h, Got: %h", pc_plus4_i, pc_sel_o);
    end

    // Test 2: PCSrc_i = 1 (select branch_target_addr_i)
    pc_plus4_i = 32'h0000_0300;
    branch_target_addr_i = 32'h0000_0400;
    PCSrc_i = 1'b1;
    #1;
    if (pc_sel_o === branch_target_addr_i) begin
      $display("  [PASS] Test 2 (PCSrc_i = 1) successful. Expected: %h, Got: %h", branch_target_addr_i, pc_sel_o);
    end else begin
      $error("  [FAIL] Test 2 (PCSrc_i = 1) failed. Expected: %h, Got: %h", branch_target_addr_i, pc_sel_o);
    end

    // Test 3: Edge case - same values
    pc_plus4_i = 32'h0000_0500;
    branch_target_addr_i = 32'h0000_0500;
    PCSrc_i = 1'b0;
    #1;
    if (pc_sel_o === pc_plus4_i) begin
      $display("  [PASS] Test 3 (PCSrc_i = 0, same values) successful. Expected: %h, Got: %h", pc_plus4_i, pc_sel_o);
    end else begin
      $error("  [FAIL] Test 3 (PCSrc_i = 0, same values) failed. Expected: %h, Got: %h", pc_plus4_i, pc_sel_o);
    end

    PCSrc_i = 1'b1;
    #1;
    if (pc_sel_o === branch_target_addr_i) begin
      $display("  [PASS] Test 3 (PCSrc_i = 1, same values) successful. Expected: %h, Got: %h", branch_target_addr_i, pc_sel_o);
    end else begin
      $error("  [FAIL] Test 3 (PCSrc_i = 1, same values) failed. Expected: %h, Got: %h", branch_target_addr_i, pc_sel_o);
    end

    $display("\nAll pc_sel tests finished.");
    $finish;
  end

endmodule

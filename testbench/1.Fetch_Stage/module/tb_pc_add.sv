`timescale 1ns / 1ps

import defines::*;

module tb_pc_add;

  // Testbench signals
  logic [DATA_WIDTH-1:0] pc_i;
  logic [DATA_WIDTH-1:0] pc_plus4_o;

  // Instantiate the DUT
  pc_add dut (
    .pc_i(pc_i),
    .pc_plus4_o(pc_plus4_o)
  );

  // Test sequence
  initial begin
    $display("Starting pc_add Testbench...");

    // Test 1: pc_i = 0
    pc_i = 32'd0;
    #1; // Allow combinational logic to settle
    if (pc_plus4_o === 32'd4) begin
      $display("  [PASS] Test 1 (pc_i = 0) successful. Expected: %0d, Got: %0d", 32'd4, pc_plus4_o);
    end else begin
      $error("  [FAIL] Test 1 (pc_i = 0) failed. Expected: %0d, Got: %0d", 32'd4, pc_plus4_o);
    end

    // Test 2: pc_i = 100
    pc_i = 32'd100;
    #1;
    if (pc_plus4_o === 32'd104) begin
      $display("  [PASS] Test 2 (pc_i = 100) successful. Expected: %0d, Got: %0d", 32'd104, pc_plus4_o);
    end else begin
      $error("  [FAIL] Test 2 (pc_i = 100) failed. Expected: %0d, Got: %0d", 32'd104, pc_plus4_o);
    end

    // Test 3: pc_i = MAX_VALUE - 3
    pc_i = {DATA_WIDTH{1'b1}} - 32'd3; // Max value - 3
    #1;
    if (pc_plus4_o === {DATA_WIDTH{1'b1}} + 32'd1) begin // Should wrap around to 1
      $display("  [PASS] Test 3 (pc_i = MAX-3) successful. Expected: %h, Got: %h", {DATA_WIDTH{1'b1}} + 32'd1, pc_plus4_o);
    end else begin
      $error("  [FAIL] Test 3 (pc_i = MAX-3) failed. Expected: %h, Got: %h", {DATA_WIDTH{1'b1}} + 32'd1, pc_plus4_o);
    end

    // Test 4: pc_i = some random value
    pc_i = 32'hABCD_1234;
    #1;
    if (pc_plus4_o === 32'hABCD_1238) begin
      $display("  [PASS] Test 4 (pc_i = 0xABCD_1234) successful. Expected: %h, Got: %h", 32'hABCD_1238, pc_plus4_o);
    end else begin
      $error("  [FAIL] Test 4 (pc_i = 0xABCD_1234) failed. Expected: %h, Got: %h", 32'hABCD_1238, pc_plus4_o);
    end

    $display("\nAll pc_add tests finished.");
    $finish;
  end

endmodule

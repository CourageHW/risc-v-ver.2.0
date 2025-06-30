`timescale 1ns / 1ps

import defines::*;

module tb_target_address_adder;

  // Testbench signals
  logic [DATA_WIDTH-1:0] pc_i;
  logic [DATA_WIDTH-1:0] immediate_result_i;
  logic [DATA_WIDTH-1:0] branch_target_addr_o;

  // Instantiate the DUT
  target_address_adder dut (
    .pc_i(pc_i),
    .immediate_result_i(immediate_result_i),
    .branch_target_addr_o(branch_target_addr_o)
  );

  // Test task
  task automatic test_case(
    input logic [DATA_WIDTH-1:0] pc_val,
    input logic [DATA_WIDTH-1:0] imm_val,
    input logic [DATA_WIDTH-1:0] expected_result,
    input string test_name
  );
    begin
      pc_i = pc_val;
      immediate_result_i = imm_val;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  PC = 0x%h, Immediate = 0x%h", pc_i, immediate_result_i);
      $display("  Result: Expected 0x%h, Got 0x%h", expected_result, branch_target_addr_o);

      if (branch_target_addr_o === expected_result) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting target_address_adder Testbench...");

    // Test 1: Basic addition (positive)
    test_case(32'h0000_1000, 32'h0000_0010, 32'h0000_1010, "Basic Positive Addition");

    // Test 2: Addition with zero immediate
    test_case(32'h0000_2000, 32'h0000_0000, 32'h0000_2000, "Addition with Zero Immediate");

    // Test 3: Addition with negative immediate (signed extension)
    // PC = 0x0000_3000, Immediate = -4 (0xFFFFFFFC)
    test_case(32'h0000_3000, 32'hFFFF_FFFC, 32'h0000_2FFC, "Addition with Negative Immediate");

    // Test 4: Larger positive values
    test_case(32'hABCD_0000, 32'h0000_EF00, 32'hABCD_EF00, "Larger Positive Values");

    // Test 5: Overflow (for unsigned, it wraps around)
    // PC = 0xFFFFFFF0, Immediate = 0x20 (32)
    test_case(32'hFFFF_FFF0, 32'h0000_0020, 32'h0000_0010, "Overflow Test");

    $display("\nAll target_address_adder tests finished.");
    $finish;
  end

endmodule

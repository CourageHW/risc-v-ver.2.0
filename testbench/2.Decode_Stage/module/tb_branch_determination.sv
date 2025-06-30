`timescale 1ns / 1ps

import defines::*;

module tb_branch_determination;

  // Testbench signals
  logic BrEq_i;
  logic BrLT_i;
  logic BrLTU_i;
  logic Branch_i;
  logic [2:0] funct3_i;

  logic BranchTaken_o;

  // Instantiate the DUT
  branch_determination dut (
    .BrEq_i(BrEq_i),
    .BrLT_i(BrLT_i),
    .BrLTU_i(BrLTU_i),
    .Branch_i(Branch_i),
    .funct3_i(funct3_i),
    .BranchTaken_o(BranchTaken_o)
  );

  // Test task
  task automatic test_case(
    input logic BrEq_t,
    input logic BrLT_t,
    input logic BrLTU_t,
    input logic Branch_t,
    input logic [2:0] funct3_t,
    input logic expected_BranchTaken,
    input string test_name
  );
    begin
      BrEq_i = BrEq_t;
      BrLT_i = BrLT_t;
      BrLTU_i = BrLTU_t;
      Branch_i = Branch_t;
      funct3_i = funct3_t;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Inputs: BrEq=%b, BrLT=%b, BrLTU=%b, Branch=%b, funct3=%b", BrEq_i, BrLT_i, BrLTU_i, Branch_i, funct3_i);
      $display("  Output: BranchTaken: Expected %b, Got %b", expected_BranchTaken, BranchTaken_o);

      if (BranchTaken_o === expected_BranchTaken) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting branch_determination Testbench...");

    // Test 1: Branch_i = 0 (No branch instruction, BranchTaken should always be 0)
    test_case(1, 1, 1, 0, FUNCT3_BEQ, 0, "Branch_i=0: BEQ (should be 0)");
    test_case(0, 0, 0, 0, FUNCT3_BNE, 0, "Branch_i=0: BNE (should be 0)");
    test_case(1, 0, 1, 0, FUNCT3_BLT, 0, "Branch_i=0: BLT (should be 0)");

    // Test 2: BEQ (Branch if Equal)
    test_case(1, 0, 0, 1, FUNCT3_BEQ, 1, "BEQ: Equal (Taken)");
    test_case(0, 1, 1, 1, FUNCT3_BEQ, 0, "BEQ: Not Equal (Not Taken)");

    // Test 3: BNE (Branch if Not Equal)
    test_case(0, 1, 1, 1, FUNCT3_BNE, 1, "BNE: Not Equal (Taken)");
    test_case(1, 0, 0, 1, FUNCT3_BNE, 0, "BNE: Equal (Not Taken)");

    // Test 4: BLT (Branch if Less Than - Signed)
    test_case(0, 1, 0, 1, FUNCT3_BLT, 1, "BLT: Less Than (Taken)");
    test_case(0, 0, 1, 1, FUNCT3_BLT, 0, "BLT: Not Less Than (Not Taken)");

    // Test 5: BGE (Branch if Greater Than or Equal - Signed)
    test_case(0, 0, 1, 1, FUNCT3_BGE, 1, "BGE: Greater Than or Equal (Taken)");
    test_case(0, 1, 0, 1, FUNCT3_BGE, 0, "BGE: Less Than (Not Taken)");

    // Test 6: BLTU (Branch if Less Than - Unsigned)
    test_case(0, 0, 1, 1, FUNCT3_BLTU, 1, "BLTU: Less Than Unsigned (Taken)");
    test_case(0, 1, 0, 1, FUNCT3_BLTU, 0, "BLTU: Not Less Than Unsigned (Not Taken)");

    // Test 7: BGEU (Branch if Greater Than or Equal - Unsigned)
    test_case(0, 1, 0, 1, FUNCT3_BGEU, 1, "BGEU: Greater Than or Equal Unsigned (Taken)");
    test_case(0, 0, 1, 1, FUNCT3_BGEU, 0, "BGEU: Less Than Unsigned (Not Taken)");

    // Test 8: Default funct3 (should not be taken if Branch_i is 1)
    test_case(1, 1, 1, 1, 3'b111, 0, "Default funct3 (should be 0)");

    $display("\nAll branch_determination tests finished.");
    $finish;
  end

endmodule

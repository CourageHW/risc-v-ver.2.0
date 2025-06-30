`timescale 1ns / 1ps

import defines::*;

module tb_immediate_sel;

  // Testbench signals
  imm_sel_e ImmSel_i;
  logic [DATA_WIDTH-1:0] imm_i_i;
  logic [DATA_WIDTH-1:0] imm_s_i;
  logic [DATA_WIDTH-1:0] imm_b_i;
  logic [DATA_WIDTH-1:0] imm_u_i;
  logic [DATA_WIDTH-1:0] imm_j_i;
  logic [DATA_WIDTH-1:0] ImmSel_o;

  // Instantiate the DUT
  immediate_sel dut (
    .ImmSel_i(ImmSel_i),
    .imm_i_i(imm_i_i),
    .imm_s_i(imm_s_i),
    .imm_b_i(imm_b_i),
    .imm_u_i(imm_u_i),
    .imm_j_i(imm_j_i),
    .ImmSel_o(ImmSel_o)
  );

  // Test task
  task automatic test_case(
    input imm_sel_e sel_type,
    input logic [DATA_WIDTH-1:0] expected_output,
    input string test_name
  );
    begin
      ImmSel_i = sel_type;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  ImmSel_i = %s", ImmSel_i.name());
      $display("  ImmSel_o: Expected 0x%h, Got 0x%h", expected_output, ImmSel_o);

      if (ImmSel_o === expected_output) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting immediate_sel Testbench...");

    // Initialize all immediate inputs with distinct values
    imm_i_i = 32'h1111_1111;
    imm_s_i = 32'h2222_2222;
    imm_b_i = 32'h3333_3333;
    imm_u_i = 32'h4444_4444;
    imm_j_i = 32'h5555_5555;

    // Test 1: IMM_TYPE_I
    test_case(IMM_TYPE_I, imm_i_i, "Select I-type immediate");

    // Test 2: IMM_TYPE_S
    test_case(IMM_TYPE_S, imm_s_i, "Select S-type immediate");

    // Test 3: IMM_TYPE_B
    test_case(IMM_TYPE_B, imm_b_i, "Select B-type immediate");

    // Test 4: IMM_TYPE_U
    test_case(IMM_TYPE_U, imm_u_i, "Select U-type immediate");

    // Test 5: IMM_TYPE_J
    test_case(IMM_TYPE_J, imm_j_i, "Select J-type immediate");

    // Test 6: Default case (IMM_TYPE_R or any undefined value)
    // The module defines default: ImmSel_o = IMM_TYPE_R, which is 0. So expect 0.
    ImmSel_i = IMM_TYPE_R; // Explicitly set to R-type
    #1;
    if (ImmSel_o === 32'd5) begin
      $display("\nTest Case: Default (IMM_TYPE_R)");
      $display("  ImmSel_i = %s", ImmSel_i.name());
      $display("  ImmSel_o: Expected 0x%h, Got 0x%h", 32'd5, ImmSel_o);
      $display("  [PASS] Default case successful.");
    end else begin
      $error("\nTest Case: Default (IMM_TYPE_R)");
      $error("  ImmSel_i = %s", ImmSel_i.name());
      $error("  ImmSel_o: Expected 0x%h, Got 0x%h", 32'd5, ImmSel_o);
      $error("  [FAIL] Default case failed.");
    end

    $display("\nAll immediate_sel tests finished.");
    $finish;
  end

endmodule

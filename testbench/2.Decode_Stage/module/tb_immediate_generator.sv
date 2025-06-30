`timescale 1ns / 1ps

import defines::*;

module tb_immediate_generator;

  // Testbench signals
  logic [DATA_WIDTH-1:0] instruction_i;
  logic [DATA_WIDTH-1:0] imm_i_o;
  logic [DATA_WIDTH-1:0] imm_s_o;
  logic [DATA_WIDTH-1:0] imm_b_o;
  logic [DATA_WIDTH-1:0] imm_u_o;
  logic [DATA_WIDTH-1:0] imm_j_o;

  // Instantiate the DUT
  immediate_generator dut (
    .instruction_i(instruction_i),
    .imm_i_o(imm_i_o),
    .imm_s_o(imm_s_o),
    .imm_b_o(imm_b_o),
    .imm_u_o(imm_u_o),
    .imm_j_o(imm_j_o)
  );

  // Test task
  task automatic test_case(
    input logic [DATA_WIDTH-1:0] instruction_t,
    input logic [DATA_WIDTH-1:0] expected_imm_i,
    input logic [DATA_WIDTH-1:0] expected_imm_s,
    input logic [DATA_WIDTH-1:0] expected_imm_b,
    input logic [DATA_WIDTH-1:0] expected_imm_u,
    input logic [DATA_WIDTH-1:0] expected_imm_j,
    input string test_name
  );
    begin
      instruction_i = instruction_t;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Instruction: 0x%h", instruction_i);
      $display("  Imm_I: Expected 0x%h, Got 0x%h", expected_imm_i, imm_i_o);
      $display("  Imm_S: Expected 0x%h, Got 0x%h", expected_imm_s, imm_s_o);
      $display("  Imm_B: Expected 0x%h, Got 0x%h", expected_imm_b, imm_b_o);
      $display("  Imm_U: Expected 0x%h, Got 0x%h", expected_imm_u, imm_u_o);
      $display("  Imm_J: Expected 0x%h, Got 0x%h", expected_imm_j, imm_j_o);

      if (imm_i_o === expected_imm_i &&
          imm_s_o === expected_imm_s &&
          imm_b_o === expected_imm_b &&
          imm_u_o === expected_imm_u &&
          imm_j_o === expected_imm_j) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting immediate_generator Testbench...");

    // Example instructions (from RISC-V ISA manual or common examples)
    // Instruction format: [31:20]imm[19:15]rs1[14:12]funct3[11:7]rd[6:0]opcode

    // Test 1: I-type (addi x10, x1, 0xFFF) - immediate is 0xFFF (signed -1)
    // instruction_i = 0xFFF08513 (addi x10, x1, -1)
    test_case(
      32'hFFF08513, // addi x10, x1, -1
      32'hFFFFFFFF, // imm_i_o: 0xFFF (sign-extended)
      32'hFFFFFFFA, // imm_s_o: Calculated from instruction_i
      32'hFFFFF7A0, // imm_b_o: Calculated from instruction_i
      32'hFFF08000, // imm_u_o: Calculated from instruction_i
      32'hFFF087E0, // imm_j_o: Calculated from instruction_i
      "I-type: addi (negative immediate)"
    );

    // Test 2: I-type (addi x4, x1, 50) - instruction_i = 32'h03208213
    test_case(
      32'h03208213, // addi x4, x1, 50
      32'h00000032, // imm_i_o: 50
      32'h00000012, // imm_s_o: Calculated from instruction_i
      32'h00000004, // imm_b_o: Calculated from instruction_i
      32'h03208000, // imm_u_o: Calculated from instruction_i
      32'h00008800, // imm_j_o: Calculated from instruction_i
      "I-type: addi (positive immediate)"
    );

    // Test 3: S-type (sw x2, 12(x1)) - instruction_i = 32'h00C0A623
    test_case(
      32'h00C0A623, // sw x2, 12(x1)
      32'h0000000C, // imm_i_o: Calculated from instruction_i
      32'h0000000C, // imm_s_o: 12
      32'h00000018, // imm_b_o: Calculated from instruction_i
      32'h00C0A000, // imm_u_o: Calculated from instruction_i
      32'h0000A000, // imm_j_o: Calculated from instruction_i
      "S-type: sw (positive immediate)"
    );

    // Test 4: B-type (beq x1, x2, -4) - instruction_i = 32'hFFC08063
    test_case(
      32'hFFC08063, // beq x1, x2, -4
      32'hFFFFFFFFC, // imm_i_o: Calculated from instruction_i
      32'hFFFFFFF83, // imm_s_o: Calculated from instruction_i
      32'hFFFF_FFFC, // imm_b_o: -4
      32'hFFC08000, // imm_u_o: Calculated from instruction_i
      32'hFFF087FC, // imm_j_o: Calculated from instruction_i
      "B-type: beq (negative immediate)"
    );

    // Test 5: U-type (lui x10, 0x12345) - instruction_i = 32'h12345537
    test_case(
      32'h12345537, // lui x10, 0x12345
      32'h00000123, // imm_i_o: Calculated from instruction_i
      32'h00000126, // imm_s_o: Calculated from instruction_i
      32'h0000044C, // imm_b_o: Calculated from instruction_i
      32'h12345000, // imm_u_o: 0x12345000
      32'h00045110, // imm_j_o: Calculated from instruction_i
      "U-type: lui"
    );

    // Test 6: J-type (jal x0, 0x100) - instruction_i = 32'h001000EF
    test_case(
      32'h001000EF, // jal x0, 0x100
      32'h00000001, // imm_i_o: Calculated from instruction_i
      32'h0000000F, // imm_s_o: Calculated from instruction_i
      32'h00000000, // imm_b_o: Calculated from instruction_i
      32'h00100000, // imm_u_o: Calculated from instruction_i
      32'h00000100, // imm_j_o: 0x100
      "J-type: jal (positive immediate)"
    );

    // Test 7: J-type (jal x0, -4) - instruction_i = 32'hFFC000EF
    test_case(
      32'hFFC000EF, // jal x0, -4
      32'hFFFFFFFFC, // imm_i_o: Calculated from instruction_i
      32'hFFFFFFF8F, // imm_s_o: Calculated from instruction_i
      32'hFFFFF7C0, // imm_b_o: Calculated from instruction_i
      32'hFFC00000, // imm_u_o: Calculated from instruction_i
      32'hFFFF_FFFC, // imm_j_o: -4
      "J-type: jal (negative immediate)"
    );

    $display("\nAll immediate_generator tests finished.");
    $finish;
  end

endmodule

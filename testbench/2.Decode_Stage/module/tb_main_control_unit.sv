`timescale 1ns / 1ps

import defines::*;

module tb_main_control_unit;

  // Testbench signals
  logic [6:0]    opcode_i;

  // DUT outputs
  logic          RegWrite_o;
  wb_sel_e       WBSel_o;
  logic          MemRead_o;
  logic          MemWrite_o;
  logic          Branch_o;
  logic          Jump_o;
  logic          ALUSrc1_o;
  logic          ALUSrc2_o;
  alu_op_e       ALUOp_o;
  imm_sel_e      ImmSel_o;

  // Instantiate the DUT
  main_control_unit dut (
    .opcode_i(opcode_i),
    .RegWrite_o(RegWrite_o),
    .WBSel_o(WBSel_o),
    .MemRead_o(MemRead_o),
    .MemWrite_o(MemWrite_o),
    .Branch_o(Branch_o),
    .Jump_o(Jump_o),
    .ALUSrc1_o(ALUSrc1_o),
    .ALUSrc2_o(ALUSrc2_o),
    .ALUOp_o(ALUOp_o),
    .ImmSel_o(ImmSel_o)
  );

  // Test task
  task automatic test_case(
    input logic [6:0]    opcode_t,
    input logic          expected_RegWrite,
    input wb_sel_e       expected_WBSel,
    input logic          expected_MemRead,
    input logic          expected_MemWrite,
    input logic          expected_Branch,
    input logic          expected_Jump,
    input logic          expected_ALUSrc1,
    input logic          expected_ALUSrc2,
    input alu_op_e       expected_ALUOp,
    input imm_sel_e      expected_ImmSel,
    input string         test_name
  );
    begin
      opcode_i = opcode_t;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s (Opcode: %b)", test_name, opcode_i);
      if (RegWrite_o === expected_RegWrite &&
          WBSel_o    === expected_WBSel    &&
          MemRead_o  === expected_MemRead  &&
          MemWrite_o === expected_MemWrite &&
          Branch_o   === expected_Branch   &&
          Jump_o     === expected_Jump     &&
          ALUSrc1_o  === expected_ALUSrc1  &&
          ALUSrc2_o  === expected_ALUSrc2  &&
          ALUOp_o    === expected_ALUOp    &&
          ImmSel_o   === expected_ImmSel) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
        $display("    Expected: RegWrite=%b, WBSel=%s, MemRead=%b, MemWrite=%b, Branch=%b, Jump=%b, ALUSrc1=%b, ALUSrc2=%b, ALUOp=%s, ImmSel=%s",
                 expected_RegWrite, expected_WBSel.name(), expected_MemRead, expected_MemWrite, expected_Branch, expected_Jump, expected_ALUSrc1, expected_ALUSrc2, expected_ALUOp.name(), expected_ImmSel.name());
        $display("    Got:      RegWrite=%b, WBSel=%s, MemRead=%b, MemWrite=%b, Branch=%b, Jump=%b, ALUSrc1=%b, ALUSrc2=%b, ALUOp=%s, ImmSel=%s",
                 RegWrite_o, WBSel_o.name(), MemRead_o, MemWrite_o, Branch_o, Jump_o, ALUSrc1_o, ALUSrc2_o, ALUOp_o.name(), ImmSel_o.name());
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting main_control_unit Testbench...");

    // Initialize inputs to default safe values
    opcode_i = 7'b0;
    #1;

    // Test 1: R-type (e.g., ADD, SUB)
    test_case(OPCODE_RTYPE, 1, WB_ALU, 0, 0, 0, 0, 0, 0, ALUOP_RTYPE, IMM_TYPE_R, "R-type Instruction");

    // Test 2: I-type (Arithmetic, e.g., ADDI)
    test_case(OPCODE_ITYPE, 1, WB_ALU, 0, 0, 0, 0, 0, 1, ALUOP_ITYPE_ARITH, IMM_TYPE_I, "I-type Arithmetic Instruction");

    // Test 3: LOAD (e.g., LW)
    test_case(OPCODE_LOAD, 1, WB_MEM, 1, 0, 0, 0, 0, 1, ALUOP_MEM_ADDR, IMM_TYPE_I, "LOAD Instruction");

    // Test 4: STORE (e.g., SW)
    test_case(OPCODE_STORE, 0, WB_NONE, 0, 1, 0, 0, 0, 1, ALUOP_MEM_ADDR, IMM_TYPE_S, "STORE Instruction");

    // Test 5: BRANCH (e.g., BEQ)
    test_case(OPCODE_BRANCH, 0, WB_NONE, 0, 0, 1, 0, 0, 0, ALUOP_BRANCH, IMM_TYPE_B, "BRANCH Instruction");

    // Test 6: LUI
    test_case(OPCODE_LUI, 1, WB_ALU, 0, 0, 0, 0, 0, 1, ALUOP_LUI, IMM_TYPE_U, "LUI Instruction");

    // Test 7: AUIPC
    test_case(OPCODE_AUIPC, 1, WB_ALU, 0, 0, 0, 0, 1, 1, ALUOP_JUMP, IMM_TYPE_U, "AUIPC Instruction");

    // Test 8: JAL
    test_case(OPCODE_JAL, 1, WB_PC4, 0, 0, 0, 1, 0, 0, ALUOP_NONE, IMM_TYPE_R, "JAL Instruction"); // ALUOp_o is ALUOP_NONE for JAL

    // Test 9: JALR
    test_case(OPCODE_JALR, 1, WB_PC4, 0, 0, 0, 1, 0, 1, ALUOP_JUMP, IMM_TYPE_I, "JALR Instruction");

    // Test 10: Default/Unknown Opcode
    test_case(7'b1111111, 0, WB_NONE, 0, 0, 0, 0, 0, 0, ALUOP_NONE, IMM_TYPE_R, "Unknown Opcode");

    $display("\nAll main_control_unit tests finished.");
    $finish;
  end

endmodule

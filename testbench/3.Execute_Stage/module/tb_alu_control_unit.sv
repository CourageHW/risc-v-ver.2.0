`timescale 1ns / 1ps

import defines::*;

module tb_alu_control_unit;
  localparam CLK_PERIOD = 10; // 10ns

  logic clk;
  
  alu_op_e ALUOp_i;
  alu_sel_e ALUSel_o;
  logic [2:0] alu_ctrl_funct3_i;
  logic alu_ctrl_funct7_i;

  alu_control_unit dut (
    .ALUOp_i(ALUOp_i),
    .alu_ctrl_funct3_i(alu_ctrl_funct3_i),
    .alu_ctrl_funct7_i(alu_ctrl_funct7_i),
    .ALUSel_o(ALUSel_o)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  task automatic test (
    input alu_op_e ALUOp_t,
    input logic [2:0] alu_ctrl_funct3_t,
    input logic alu_ctrl_funct7_t,
    input alu_sel_e expected_ALUSel,
    input string OperateName
    );

    @(posedge clk);
    #1;

    ALUOp_i = ALUOp_t;
    alu_ctrl_funct3_i = alu_ctrl_funct3_t;
    alu_ctrl_funct7_i = alu_ctrl_funct7_t;
    @(posedge clk);
    #1;

    assert(ALUSel_o == expected_ALUSel)
      else $error("Mismatch result. %s expected result : %0d Got : %0d at %0t",
        OperateName, expected_ALUSel, ALUSel_o, $time);
    
    $display("[Pass] %s", OperateName);
  endtask

  initial begin
    ALUOp_i = ALUOP_NONE;
    alu_ctrl_funct3_i = '0;
    alu_ctrl_funct7_i = '0;

    @(posedge clk);

    $display("\n=======================");
    $display("[Start] at %0t", $time);
    $display("========================\n");

    test(ALUOP_MEM_ADDR, 3'bxxx, 1'bx, ALU_ADD, "Memory Address");
    test(ALUOP_BRANCH  , 3'bxxx, 1'bx, ALU_SUB, "Branch");
    test(ALUOP_LUI     , 3'bxxx, 1'bx, ALU_PASS_B, "LUI");
    test(ALUOP_JUMP    , 3'bxxx, 1'bx, ALU_ADD, "JUMP");

    test(ALUOP_RTYPE   , 3'b000, 1'b0, ALU_ADD, "RTYPE ADD");
    test(ALUOP_RTYPE   , 3'b000, 1'b1, ALU_SUB, "RTYPE SUB");
    test(ALUOP_RTYPE   , 3'b101, 1'b0, ALU_SRL, "RTYPE SRL");
    test(ALUOP_RTYPE   , 3'b101, 1'b1, ALU_SRA, "RTYPE SRA");
    test(ALUOP_RTYPE   , 3'b001, 1'bx, ALU_SLL, "RTYPE SLL");
    test(ALUOP_RTYPE   , 3'b010, 1'bx, ALU_SLT, "RTYPE SLT");
    test(ALUOP_RTYPE   , 3'b011, 1'bx, ALU_SLTU, "RTYPE SLTU");
    test(ALUOP_RTYPE   , 3'b100, 1'bx, ALU_XOR, "RTYPE XOR");

    test(ALUOP_ITYPE_ARITH, 3'b101, 1'b0, ALU_SRL, "ITYPE SRL");
    test(ALUOP_ITYPE_ARITH, 3'b101, 1'b1, ALU_SRA, "ITYPE SRA");
    test(ALUOP_ITYPE_ARITH, 3'b000, 1'bx, ALU_ADD, "ITYPE ADD");
    test(ALUOP_ITYPE_ARITH, 3'b001, 1'bx, ALU_SLL, "ITYPE SLL");
    test(ALUOP_ITYPE_ARITH, 3'b010, 1'bx, ALU_SLT, "ITYPE SLT");
    test(ALUOP_ITYPE_ARITH, 3'b011, 1'bx, ALU_SLTU, "ITYPE SLTU");
    test(ALUOP_ITYPE_ARITH, 3'b100, 1'bx, ALU_XOR, "ITYPE XOR");

    repeat(10) @(posedge clk);

    $display("\n==============================");
    $display("[Success] ALU Control Unit Test");
    $display("===============================\n");

    $finish;
  end
endmodule

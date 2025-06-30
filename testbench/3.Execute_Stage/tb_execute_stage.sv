`timescale 1ns / 1ps

import defines::*;

module tb_execute_stage;
  localparam CLK_PERIOD = 10; // 10ns

  logic clk;

  // execute_stage 모듈의 입력 포트에 연결될 신호들
  logic [DATA_WIDTH-1:0] EX_rd_data1_i;
  logic [DATA_WIDTH-1:0] EX_rd_data2_i;
  logic [DATA_WIDTH-1:0] MEM_alu_result_i;
  logic [DATA_WIDTH-1:0] WB_alu_result_i;
  logic [DATA_WIDTH-1:0] EX_imm_i;
  logic [DATA_WIDTH-1:0] EX_pc_i;
  logic [DATA_WIDTH-1:0] EX_instruction_i;

  logic EX_ALUOpSrc1_i;
  logic EX_ALUOpSrc2_i;
  alu_op_e EX_ALUOp_i;
  fw_sel_e EX_forwardA_i;
  fw_sel_e EX_forwardB_i;

  // execute_stage 모듈의 출력 포트에서 받을 신호들
  logic [DATA_WIDTH-1:0] EX_alu_result_o;
  logic [DATA_WIDTH-1:0] EX_wr_data_o;

  // DUT (Design Under Test): execute_stage 모듈 인스턴스화
  execute_stage dut (
    .EX_rd_data1_i(EX_rd_data1_i),
    .EX_rd_data2_i(EX_rd_data2_i),
    .MEM_alu_result_i(MEM_alu_result_i),
    .WB_alu_result_i(WB_alu_result_i),
    .EX_imm_i(EX_imm_i),
    .EX_pc_i(EX_pc_i),
    .EX_instruction_i(EX_instruction_i),
    .EX_ALUOpSrc1_i(EX_ALUOpSrc1_i),
    .EX_ALUOpSrc2_i(EX_ALUOpSrc2_i),
    .EX_ALUOp_i(EX_ALUOp_i),
    .EX_forwardA_i(EX_forwardA_i),
    .EX_forwardB_i(EX_forwardB_i),
    .EX_alu_result_o(EX_alu_result_o),
    .EX_wr_data_o(EX_wr_data_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Test task
  task automatic test (
    input logic [DATA_WIDTH-1:0] rd_data1_t,
    input logic [DATA_WIDTH-1:0] rd_data2_t,
    input logic [DATA_WIDTH-1:0] mem_alu_t,
    input logic [DATA_WIDTH-1:0] wb_alu_t,
    input logic [DATA_WIDTH-1:0] imm_t,
    input logic [DATA_WIDTH-1:0] pc_t,
    input logic [DATA_WIDTH-1:0] instruction_t,
    input logic alu_op_src1_t,
    input logic alu_op_src2_t,
    input alu_op_e alu_op_t,
    input fw_sel_e forwardA_t,
    input fw_sel_e forwardB_t,
    input logic [DATA_WIDTH-1:0] expected_alu_result,
    input logic [DATA_WIDTH-1:0] expected_wr_data,
    input string test_name
    );

    @(posedge clk); // Wait for clock edge
    #1; // Small delay for inputs to settle

    // Assign inputs to DUT
    EX_rd_data1_i      = rd_data1_t;
    EX_rd_data2_i      = rd_data2_t;
    MEM_alu_result_i   = mem_alu_t;
    WB_alu_result_i    = wb_alu_t;
    EX_imm_i           = imm_t;
    EX_pc_i            = pc_t;
    EX_instruction_i   = instruction_t;
    EX_ALUOpSrc1_i     = alu_op_src1_t;
    EX_ALUOpSrc2_i     = alu_op_src2_t;
    EX_ALUOp_i         = alu_op_t;
    EX_forwardA_i      = forwardA_t;
    EX_forwardB_i      = forwardB_t;

    @(posedge clk); // Wait for next clock edge for combinational logic to propagate
    #1; // Small delay for outputs to settle

    // Verify outputs
    if (EX_alu_result_o === expected_alu_result && EX_wr_data_o === expected_wr_data) begin
      $display("  [PASS] %s", test_name);
    end else begin
      $error("  [FAIL] %s", test_name);
      $display("    Expected ALU Result: 0x%h, Got: 0x%h", expected_alu_result, EX_alu_result_o);
      $display("    Expected Write Data: 0x%h, Got: 0x%h", expected_wr_data, EX_wr_data_o);
    end
  endtask

  initial begin
    // Initialize all inputs to default safe values
    EX_rd_data1_i      = '0;
    EX_rd_data2_i      = '0;
    MEM_alu_result_i   = '0;
    WB_alu_result_i    = '0;
    EX_imm_i           = '0;
    EX_pc_i            = '0;
    EX_instruction_i   = '0;
    EX_ALUOpSrc1_i     = 0;
    EX_ALUOpSrc2_i     = 0;
    EX_ALUOp_i         = ALUOP_NONE;
    EX_forwardA_i      = FW_NONE;
    EX_forwardB_i      = FW_NONE;

    @(posedge clk); // Initial clock synchronization

    $display("===============================================");
    $display("=  Starting Execute Stage Testbench           =");
    $display("===============================================");

    // Test 1: Basic R-type ADD (no forwarding, no special ALUSrc)
    test(32'd10, 32'd5, '0, '0, '0, '0, {29'b0, FUNCT7_ADD, 3'b000, 7'b0110011}, 0, 0, ALUOP_RTYPE, FW_NONE, FW_NONE, 32'd15, 32'd5, "Basic R-type ADD");

    // Test 2: I-type ADDI (no forwarding, ALUSrc2=1)
    test(32'd20, '0, '0, '0, 32'd10, '0, {29'b0, 3'b000, 7'b0010011}, 0, 1, ALUOP_ITYPE_ARITH, FW_NONE, FW_NONE, 32'd30, 32'd10, "I-type ADDI");

    // Test 3: Load/Store Address Calculation (ALUSrc2=1)
    test(32'd100, '0, '0, '0, 32'd4, '0, {29'b0, 3'b000, 7'b0000011}, 0, 1, ALUOP_MEM_ADDR, FW_NONE, FW_NONE, 32'd104, 32'd4, "Load/Store Address Calc");

    // Test 4: Branch SUB (no forwarding, no special ALUSrc)
    test(32'd50, 32'd50, '0, '0, '0, '0, {29'b0, 3'b000, 7'b1100011}, 0, 0, ALUOP_BRANCH, FW_NONE, FW_NONE, 32'd0, 32'd50, "Branch SUB (Equal)");

    // Test 5: LUI (ALUSrc2=1, ALU_PASS_B)
    test('0, '0, '0, '0, 32'hABCD_0000, '0, {29'b0, 7'b0110111}, 0, 1, ALUOP_LUI, FW_NONE, FW_NONE, 32'hABCD_0000, 32'hABCD_0000, "LUI Instruction");

    // Test 6: JALR (ALUSrc1=0, ALUSrc2=1, ALU_ADD)
    test(32'h1000, '0, '0, '0, 32'd8, 32'h0, {29'b0, 3'b000, 7'b1100111}, 0, 1, ALUOP_JUMP, FW_NONE, FW_NONE, 32'h1008, 32'd8, "JALR Instruction");

    // Test 7: AUIPC (ALUSrc1=1, ALUSrc2=1, ALU_ADD)
    test('0, '0, '0, '0, 32'h1000, 32'h2000, {29'b0, 7'b0010111}, 1, 1, ALUOP_JUMP, FW_NONE, FW_NONE, 32'h3000, 32'h1000, "AUIPC Instruction");

    // Test 8: Forwarding A from MEM_ALU
    test(32'd10, 32'd5, 32'd99, '0, '0, '0, {29'b0, FUNCT7_ADD, 3'b000, 7'b0110011}, 0, 0, ALUOP_RTYPE, FW_MEM_ALU, FW_NONE, 32'd104, 32'd5, "Forward A from MEM_ALU"); // 99 + 5 = 104

    // Test 9: Forwarding B from WB_DATA
    test(32'd10, 32'd5, '0, 32'd88, '0, '0, {29'b0, FUNCT7_ADD, 3'b000, 7'b0110011}, 0, 0, ALUOP_RTYPE, FW_NONE, FW_WB_DATA, 32'd98, 32'd88, "Forward B from WB_DATA"); // 10 + 88 = 98

    // Test 10: Forwarding A from WB_DATA and B from MEM_ALU
    test(32'd10, 32'd5, 32'd77, 32'd66, '0, '0, {29'b0, FUNCT7_ADD, 3'b000, 7'b0110011}, 0, 0, ALUOP_RTYPE, FW_WB_DATA, FW_MEM_ALU, 32'd143, 32'd77, "Forward A from WB_DATA, B from MEM_ALU"); // 66 + 77 = 143

    $display("===============================================");
    $display("=  Execute Stage Test Complete!               =");
    $display("===============================================");
    repeat(10) @(posedge clk); // Additional delay before finishing

    $finish;
  end

endmodule

`timescale 1ns / 1ps

import defines::*;

module tb_ID_to_EX;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic flush_i;

  wb_sel_e ID_WBSel_i;
  fw_sel_e ID_forwardA_i;
  fw_sel_e ID_forwardB_i;
  logic ID_MemRead_i;
  logic ID_MemWrite_i;
  logic ID_RegWrite_i;
  alu_op_e ID_ALUOp_i;
  logic ID_ALUOpSrc1_i;
  logic ID_ALUOpSrc2_i;

  logic [DATA_WIDTH-1:0] ID_instruction_i;
  logic [DATA_WIDTH-1:0] ID_rd_data1_i;
  logic [DATA_WIDTH-1:0] ID_rd_data2_i;
  logic [DATA_WIDTH-1:0] ID_imm_i;
  logic [DATA_WIDTH-1:0] ID_pc_i;
  logic [DATA_WIDTH-1:0] ID_pc_plus4_i;

  wb_sel_e EX_WBSel_o;
  fw_sel_e EX_forwardA_o;
  fw_sel_e EX_forwardB_o;
  logic EX_MemRead_o;
  logic EX_MemWrite_o;
  logic EX_RegWrite_o;
  alu_op_e EX_ALUOp_o;
  logic EX_ALUOpSrc1_o;
  logic EX_ALUOpSrc2_o;

  logic [DATA_WIDTH-1:0] EX_instruction_o;
  logic [DATA_WIDTH-1:0] EX_rd_data1_o;
  logic [DATA_WIDTH-1:0] EX_rd_data2_o;
  logic [DATA_WIDTH-1:0] EX_imm_o;
  logic [DATA_WIDTH-1:0] EX_pc_o;
  logic [DATA_WIDTH-1:0] EX_pc_plus4_o;

  // Instantiate the DUT
  ID_to_EX dut (
    .clk(clk),
    .rst_n(rst_n),
    .flush_i(flush_i),
    .ID_WBSel_i(ID_WBSel_i),
    .ID_forwardA_i(ID_forwardA_i),
    .ID_forwardB_i(ID_forwardB_i),
    .ID_MemRead_i(ID_MemRead_i),
    .ID_MemWrite_i(ID_MemWrite_i),
    .ID_RegWrite_i(ID_RegWrite_i),
    .ID_ALUOp_i(ID_ALUOp_i),
    .ID_ALUOpSrc1_i(ID_ALUOpSrc1_i),
    .ID_ALUOpSrc2_i(ID_ALUOpSrc2_i),
    .ID_instruction_i(ID_instruction_i),
    .ID_rd_data1_i(ID_rd_data1_i),
    .ID_rd_data2_i(ID_rd_data2_i),
    .ID_imm_i(ID_imm_i),
    .ID_pc_i(ID_pc_i),
    .ID_pc_plus4_i(ID_pc_plus4_i),
    .EX_WBSel_o(EX_WBSel_o),
    .EX_forwardA_o(EX_forwardA_o),
    .EX_forwardB_o(EX_forwardB_o),
    .EX_MemRead_o(EX_MemRead_o),
    .EX_MemWrite_o(EX_MemWrite_o),
    .EX_RegWrite_o(EX_RegWrite_o),
    .EX_ALUOp_o(EX_ALUOp_o),
    .EX_ALUOpSrc1_o(EX_ALUOpSrc1_o),
    .EX_ALUOpSrc2_o(EX_ALUOpSrc2_o),
    .EX_instruction_o(EX_instruction_o),
    .EX_rd_data1_o(EX_rd_data1_o),
    .EX_rd_data2_o(EX_rd_data2_o),
    .EX_imm_o(EX_imm_o),
    .EX_pc_o(EX_pc_o),
    .EX_pc_plus4_o(EX_pc_plus4_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $display("Starting ID_to_EX Testbench...");

    // Initialize inputs
    ID_WBSel_i        = WB_NONE;
    ID_forwardA_i     = FW_NONE;
    ID_forwardB_i     = FW_NONE;
    ID_MemRead_i      = 0;
    ID_MemWrite_i     = 0;
    ID_RegWrite_i     = 0;
    ID_ALUOp_i        = ALUOP_NONE;
    ID_ALUOpSrc1_i    = 0;
    ID_ALUOpSrc2_i    = 0;
    ID_instruction_i  = '0;
    ID_rd_data1_i     = '0;
    ID_rd_data2_i     = '0;
    ID_imm_i          = '0;
    ID_pc_i           = '0;
    ID_pc_plus4_i     = '0;
    flush_i           = 0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (EX_WBSel_o === WB_NONE && EX_forwardA_o === FW_NONE && EX_forwardB_o === FW_NONE &&
        EX_MemRead_o === 0 && EX_MemWrite_o === 0 && EX_RegWrite_o === 0 &&
        EX_ALUOp_o === ALUOP_NONE && EX_ALUOpSrc1_o === 0 && EX_ALUOpSrc2_o === 0 &&
        EX_instruction_o === '0 && EX_rd_data1_o === '0 && EX_rd_data2_o === '0 &&
        EX_imm_o === '0 && EX_pc_o === '0 && EX_pc_plus4_o === '0) begin
      $display("  [PASS] Reset successful.");
    end else begin
      $error("  [FAIL] Reset failed.");
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: Normal operation - all signals high/non-zero
    $display("\nTest 2: Normal operation");
    ID_WBSel_i        = WB_ALU;
    ID_forwardA_i     = FW_MEM_ALU;
    ID_forwardB_i     = FW_WB_DATA;
    ID_MemRead_i      = 1;
    ID_MemWrite_i     = 1;
    ID_RegWrite_i     = 1;
    ID_ALUOp_i        = ALUOP_RTYPE;
    ID_ALUOpSrc1_i    = 1;
    ID_ALUOpSrc2_i    = 1;
    ID_instruction_i  = 32'hABCDEF01;
    ID_rd_data1_i     = 32'h11112222;
    ID_rd_data2_i     = 32'h33334444;
    ID_imm_i          = 32'h55556666;
    ID_pc_i           = 32'h00001000;
    ID_pc_plus4_i     = 32'h00001004;
    @(posedge clk);
    if (EX_WBSel_o === WB_ALU && EX_forwardA_o === FW_MEM_ALU && EX_forwardB_o === FW_WB_DATA &&
        EX_MemRead_o === 1 && EX_MemWrite_o === 1 && EX_RegWrite_o === 1 &&
        EX_ALUOp_o === ALUOP_RTYPE && EX_ALUOpSrc1_o === 1 && EX_ALUOpSrc2_o === 1 &&
        EX_instruction_o === 32'hABCDEF01 && EX_rd_data1_o === 32'h11112222 && EX_rd_data2_o === 32'h33334444 &&
        EX_imm_o === 32'h55556666 && EX_pc_o === 32'h00001000 && EX_pc_plus4_o === 32'h00001004) begin
      $display("  [PASS] Normal operation successful.");
    end else begin
      $error("  [FAIL] Normal operation failed.");
    end
    @(posedge clk);

    // Test 3: Flush operation
    $display("\nTest 3: Flush operation");
    flush_i = 1;
    ID_WBSel_i        = WB_MEM;
    ID_forwardA_i     = FW_NONE;
    ID_forwardB_i     = FW_NONE;
    ID_MemRead_i      = 0;
    ID_MemWrite_i     = 0;
    ID_RegWrite_i     = 0;
    ID_ALUOp_i        = ALUOP_ITYPE_ARITH;
    ID_ALUOpSrc1_i    = 0;
    ID_ALUOpSrc2_i    = 0;
    ID_instruction_i  = 32'h00000000;
    ID_rd_data1_i     = 32'h00000000;
    ID_rd_data2_i     = 32'h00000000;
    ID_imm_i          = 32'h00000000;
    ID_pc_i           = 32'h00000000;
    ID_pc_plus4_i     = 32'h00000000;
    @(posedge clk);
    if (EX_WBSel_o === WB_NONE && EX_forwardA_o === FW_NONE && EX_forwardB_o === FW_NONE &&
        EX_MemRead_o === 0 && EX_MemWrite_o === 0 && EX_RegWrite_o === 0 &&
        EX_ALUOp_o === ALUOP_NONE && EX_ALUOpSrc1_o === 0 && EX_ALUOpSrc2_o === 0 &&
        EX_instruction_o === '0 && EX_rd_data1_o === '0 && EX_rd_data2_o === '0 &&
        EX_imm_o === '0 && EX_pc_o === '0 && EX_pc_plus4_o === '0) begin
      $display("  [PASS] Flush successful.");
    end else begin
      $error("  [FAIL] Flush failed.");
    end
    flush_i = 0;
    @(posedge clk);

    $display("\nAll ID_to_EX tests finished.");
    #1000;
    $finish;
  end

endmodule

`timescale 1ns / 1ps

import defines::*;

module riscv_core (
  input logic clk,
  input logic rst_n
  );


  wb_sel_e ID_WBSel_w, EX_WBSel_w, MEM_WBSel_w, WB_WBSel_w;
  alu_op_e ID_ALUOp_w, EX_ALUOp_w;
  fw_sel_e ID_forwardA_w, ID_forwardB_w, EX_forwardA_w, EX_forwardB_w;
  logic ID_MemRead_w, EX_MemRead_w, MEM_MemRead_w, WB_MemWrite_w; 
  logic ID_MemWrite_w, EX_MemWrite_w, MEM_MemWrite_w; 
  logic ID_RegWrite_w, EX_RegWrite_w, MEM_RegWrite_w, WB_RegWrite_w;
  logic ID_ALUOpSrc1_w, EX_ALUOpSrc1_w;
  logic ID_ALUOpSrc2_w, EX_ALUOpSrc2_w;
  logic ID_PCSrc_w;
  logic IF_pc_write_en_w;
  logic IF_ID_write_en_w;
  logic ID_EX_flush_w;
   
  logic [DATA_WIDTH-1:0] MEM_addr_w, WB_addr_w;

  logic [DATA_WIDTH-1:0] ID_branch_target_addr_w;
  logic [DATA_WIDTH-1:0] IF_instruction_w,ID_instruction_w, EX_instruction_w, MEM_instruction_w, WB_instruction_w;
  logic [DATA_WIDTH-1:0] ID_rd_data1_w, EX_rd_data1_w;
  logic [DATA_WIDTH-1:0] ID_rd_data2_w, EX_rd_data2_w;
  logic [DATA_WIDTH-1:0] ID_imm_w, EX_imm_w;
  logic [DATA_WIDTH-1:0] IF_pc_w, ID_pc_w, EX_pc_w;
  logic [DATA_WIDTH-1:0] IF_pc_plus4_w, ID_pc_plus4_w, EX_pc_plus4_w, MEM_pc_plus4_w, WB_pc_plus4_w;
  logic [DATA_WIDTH-1:0] EX_alu_result_w, MEM_alu_result_w, WB_alu_result_w;
  logic [DATA_WIDTH-1:0] MEM_rd_mem_addr_w;
  logic [DATA_WIDTH-1:0] MEM_rd_data2_w;
  logic [DATA_WIDTH-1:0] EX_wr_data_w, MEM_wr_data_w, WB_wr_data_w;
  logic [DATA_WIDTH-1:0] MEM_rd_data_w, WB_rd_data_w;
  logic [DATA_WIDTH-1:0] WB_writeback_data_w;
  
  logic [4:0] ID_rs1_addr_w, ID_rs2_addr_w;
  logic [4:0] EX_rd_addr_w, MEM_rd_addr_w;

  logic [4:0] WB_wr_addr_w;
  

  // =============================================== //
  //                   IF Stage                      //
  // =============================================== //
  fetch_stage fetch_stage_inst (
    .clk(clk),
    .rst_n(rst_n),
    .IF_pc_write_en_i(IF_pc_write_en_w),
    .IF_branch_target_addr_i(ID_branch_target_addr_w),
    .IF_PCSrc_i(ID_PCSrc_w),
    .IF_instruction_o(IF_instruction_w),
    .IF_pc_o(IF_pc_w),
    .IF_pc_plus4_o(IF_pc_plus4_w)
  );

  IF_to_ID if_to_id_inst (
    .clk(clk),
    .rst_n(rst_n),
    .flush_i(ID_PCSrc_w),
    .IF_ID_write_en_i(IF_ID_write_en_w),

    .IF_instruction_i(IF_instruction_w),
    .IF_pc_i(IF_pc_w),
    .IF_pc_plus4_i(IF_pc_plus4_w),

    .ID_instruction_o(ID_instruction_w),
    .ID_pc_o(ID_pc_w),
    .ID_pc_plus4_o(ID_pc_plus4_w)
    );
  // =============================================== //
  //                   ID Stage                      //
  // =============================================== //

  assign WB_wr_addr_w = WB_instruction_w[11:7];

  decode_stage decode_stage_inst (
    // --- 입력 포트 ---
    .clk(clk),
    .rst_n(rst_n),
    .ID_instruction_i(ID_instruction_w), // IF/ID 파이프라인 레지스터로부터 온 명령어
    .ID_pc_i(ID_pc_w),
    .WB_we_i(WB_RegWrite_w),
    .WB_wr_addr_i(WB_wr_addr_w),
    .WB_wr_data_i(WB_writeback_data_w),

    // --- 출력 포트 ---
    // 제어 신호 -> ID/EX 파이프라인 레지스터로 전달
    .ID_WBSel_o(ID_WBSel_w),
    .ID_MemRead_o(ID_MemRead_w),
    .ID_MemWrite_o(ID_MemWrite_w),
    .ID_PCSrc_o(ID_PCSrc_w),
    .ID_RegWrite_o(ID_RegWrite_w),
    .ID_ALUOp_o(ID_ALUOp_w),
    .ID_ALUOpSrc1_o(ID_ALUOpSrc1_w),
    .ID_ALUOpSrc2_o(ID_ALUOpSrc2_w),

    // 데이터 -> ID/EX 파이프라인 레지스터로 전달
    .ID_branch_target_addr_o(ID_branch_target_addr_w),
    .ID_rd_data1_o(ID_rd_data1_w),
    .ID_rd_data2_o(ID_rd_data2_w),
    .ID_imm_o(ID_imm_w)
  );


  ID_to_EX id_to_ex_inst (
    // --- 공통 신호 ---
    .clk(clk),
    .rst_n(rst_n),
    .flush_i(ID_EX_flush_w),

    // --- 입력 (Decode Stage의 출력) ---
    .ID_WBSel_i(ID_WBSel_w),
    .ID_forwardA_i(ID_forwardA_w),
    .ID_forwardB_i(ID_forwardB_w),
    .ID_MemRead_i(ID_MemRead_w),
    .ID_MemWrite_i(ID_MemWrite_w),
    .ID_RegWrite_i(ID_RegWrite_w),
    .ID_ALUOp_i(ID_ALUOp_w),
    .ID_ALUOpSrc1_i(ID_ALUOpSrc1_w),
    .ID_ALUOpSrc2_i(ID_ALUOpSrc2_w),
    .ID_instruction_i(ID_instruction_w),
    .ID_rd_data1_i(ID_rd_data1_w),
    .ID_rd_data2_i(ID_rd_data2_w),
    .ID_imm_i(ID_imm_w),
    .ID_pc_i(ID_pc_w),
    .ID_pc_plus4_i(ID_pc_plus4_w),

    // --- 출력 (Execute Stage로 전달) ---
    .EX_WBSel_o(EX_WBSel_w),
    .EX_forwardA_o(EX_forwardA_w),
    .EX_forwardB_o(EX_forwardB_w),
    .EX_MemRead_o(EX_MemRead_w),
    .EX_MemWrite_o(EX_MemWrite_w),
    .EX_RegWrite_o(EX_RegWrite_w),
    .EX_ALUOp_o(EX_ALUOp_w),
    .EX_ALUOpSrc1_o(EX_ALUOpSrc1_w),
    .EX_ALUOpSrc2_o(EX_ALUOpSrc2_w),
    .EX_instruction_o(EX_instruction_w),
    .EX_rd_data1_o(EX_rd_data1_w),
    .EX_rd_data2_o(EX_rd_data2_w),
    .EX_imm_o(EX_imm_w),
    .EX_pc_o(EX_pc_w),
    .EX_pc_plus4_o(EX_pc_plus4_w)
  );


  // =============================================== //
  //                   EX Stage                      //
  // =============================================== //


  execute_stage execute_stage_inst (
    .EX_rd_data1_i(EX_rd_data1_w),
    .EX_rd_data2_i(EX_rd_data2_w),
    .MEM_alu_result_i(MEM_alu_result_w),
    .WB_alu_result_i(WB_alu_result_w),
    .EX_imm_i(EX_imm_w),
    .EX_pc_i(EX_pc_w),
    .EX_instruction_i(EX_instruction_w),
    .EX_ALUOpSrc1_i(EX_ALUOpSrc1_w),
    .EX_ALUOpSrc2_i(EX_ALUOpSrc2_w),
    .EX_ALUOp_i(EX_ALUOp_w),
    .EX_forwardA_i(EX_forwardA_w),
    .EX_forwardB_i(EX_forwardB_w),

    .EX_alu_result_o(EX_alu_result_w),
    .EX_wr_data_o(EX_wr_data_w)
    );

  

  EX_to_MEM ex_to_mem_inst (
    .clk(clk),
    .rst_n(rst_n),
    
    .EX_WBSel_i(EX_WBSel_w),
    .EX_MemRead_i(EX_MemRead_w),
    .EX_MemWrite_i(EX_MemWrite_w),
    .EX_RegWrite_i(EX_RegWrite_w),

    .EX_alu_result_i(EX_alu_result_w),
    .EX_instruction_i(EX_instruction_w),
    .EX_wr_data_i(EX_wr_data_w),
    .EX_pc_plus4_i(EX_pc_plus4_w),

    .MEM_WBSel_o(MEM_WBSel_w),
    .MEM_MemRead_o(MEM_MemRead_w),
    .MEM_MemWrite_o(MEM_MemWrite_w),
    .MEM_RegWrite_o(MEM_RegWrite_w),

    .MEM_alu_result_o(MEM_alu_result_w),
    .MEM_instruction_o(MEM_instruction_w),
    .MEM_wr_data_o(MEM_wr_data_w),
    .MEM_pc_plus4_o(MEM_pc_plus4_w)
    );

  // =============================================== //
  //                   MEM Stage                     //
  // =============================================== //

  assign MEM_rd_mem_addr_w = MEM_alu_result_w;
  assign MEM_addr_w = MEM_alu_result_w;
 
  memory_stage memory_stage_inst (
    .clk(clk),
    .MEM_MemWrite_i(MEM_MemWrite_w),
    .MEM_MemRead_i(MEM_MemRead_w),
    .WB_MemWrite_i(WB_MemWrite_w),
    .MEM_instruction_i(MEM_instruction_w),
    .MEM_addr_i(MEM_rd_mem_addr_w),
    .MEM_wr_data_i(MEM_wr_data_w),
    .WB_addr_i(WB_addr_w),
    .WB_wr_data_i(WB_wr_data_w),
    .MEM_rd_data_o(MEM_rd_data_w)
    );


  MEM_to_WB mem_to_wb_inst (
    .clk(clk),
    .rst_n(rst_n),

    .MEM_WBSel_i(MEM_WBSel_w),
    .MEM_RegWrite_i(MEM_RegWrite_w),
    .MEM_MemWrite_i(MEM_MemWrite_w),

    .MEM_alu_result_i(MEM_alu_result_w),
    .MEM_instruction_i(MEM_instruction_w),
    .MEM_rd_data_i(MEM_rd_data_w),
    .MEM_pc_plus4_i(MEM_pc_plus4_w),
    .MEM_addr_i(MEM_addr_w),
    .MEM_wr_data_i(MEM_wr_data_w),

    .WB_WBSel_o(WB_WBSel_w),
    .WB_RegWrite_o(WB_RegWrite_w),
    .WB_MemWrite_o(WB_MemWrite_w),

    .WB_alu_result_o(WB_alu_result_w),
    .WB_instruction_o(WB_instruction_w),
    .WB_rd_data_o(WB_rd_data_w),
    .WB_pc_plus4_o(WB_pc_plus4_w),
    .WB_addr_o(WB_addr_w),
    .WB_wr_data_o(WB_wr_data_w)
    );


  // =============================================== //
  //                   WB Stage                      //
  // =============================================== //


  writeback_stage writeback_stage_inst (
    .WB_WBSel_i(WB_WBSel_w),
    .WB_alu_result_i(WB_alu_result_w),
    .WB_rd_data_i(WB_rd_data_w),
    .WB_pc_plus4_i(WB_pc_plus4_w),

    .WB_writeback_data_o(WB_writeback_data_w)
  );

  // =============================================== //
  //                Forwarding Unit                  //
  // =============================================== //
  
  assign ID_rs1_addr_w = ID_instruction_w[19:15];
  assign ID_rs2_addr_w = ID_instruction_w[24:20];
  assign EX_rd_addr_w = EX_instruction_w[11:7];
  assign MEM_rd_addr_w = MEM_instruction_w[11:7];

  forwarding_unit forwarding_unit_inst (
    .ID_rs1_addr_i(ID_rs1_addr_w),
    .ID_rs2_addr_i(ID_rs2_addr_w),
    .EX_rd_addr_i(EX_rd_addr_w),
    .MEM_rd_addr_i(MEM_rd_addr_w),
    .EX_RegWrite_i(EX_RegWrite_w),
    .MEM_RegWrite_i(MEM_RegWrite_w),

    .forwardA(ID_forwardA_w),
    .forwardB(ID_forwardB_w)
  );


  // =============================================== //
  //             Hazard Detection Unit               //
  // =============================================== //
  
  hazard_detection_unit hazard_detection_unit_inst (
    .ID_rs1_addr_i(ID_rs1_addr_w),
    .ID_rs2_addr_i(ID_rs2_addr_w),
    .EX_rd_addr_i(EX_rd_addr_w),
    .EX_MemRead_i(EX_MemRead_w),
    .PCWrite_en_o(IF_pc_write_en_w),
    .IF_ID_write_en_o(IF_ID_write_en_w),
    .ID_EX_flush_o(ID_EX_flush_w)
    );

endmodule

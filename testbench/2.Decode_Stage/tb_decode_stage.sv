`timescale 1ns / 1ps

import defines::*;

module tb_decode_stage;

  // 파라미터 및 신호 선언
  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 5;
  localparam int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] ID_instruction_i;

  // DUT의 Write-Back 포트를 제어하기 위한 신호
  logic WB_we_i;
  logic [ADDR_WIDTH-1:0] WB_wr_addr_i;
  logic [DATA_WIDTH-1:0] WB_wr_data_i;

  // DUT 출력 신호
  wb_sel_e ID_WBSel_o;
  logic ID_MemRead_o;
  logic ID_MemWrite_o;
  logic ID_Jump_o;
  logic ID_Branch_o;
  logic ID_RegWrite_o;
  alu_op_e ID_ALUOp_o;
  logic ID_ALUOpSrc1_o;
  logic ID_ALUOpSrc2_o;
  logic [DATA_WIDTH-1:0] ID_instruction_o;
  logic [DATA_WIDTH-1:0] ID_rd_data1_o;
  logic [DATA_WIDTH-1:0] ID_rd_data2_o;
  logic [DATA_WIDTH-1:0] ID_imm_o;

  // 수정된 DUT 인스턴스화
  decode_stage dut (.*);

  // 클럭 생성
  always #(CLK_PERIOD / 2) clk = ~clk;

  // 테스트 시퀀스
  initial begin
    $display("=================================================");
    $display("=== Decode Stage Testbench 시작 ===");
    $display("=================================================");

    // 초기화
    clk = 0;
    rst_n = 1;
    ID_instruction_i = '0;
    WB_we_i = 0;
    WB_wr_addr_i = '0;
    WB_wr_data_i = '0;

    // 리셋 적용
    rst_n <= 0;
    repeat(2) @(posedge clk);
    rst_n <= 1;
    $display("\n[초기화] 리셋 완료. 레지스터 파일 초기화됨.");
    @(posedge clk);

    // --- 테스트 준비: 레지스터에 초기값 쓰기 ---
    $display("\n[준비] 테스트를 위한 초기값 레지스터에 쓰기...");
    // x1 레지스터에 100 쓰기
    WB_we_i <= 1;
    WB_wr_addr_i <= 1;
    WB_wr_data_i <= 100;
    @(posedge clk);
    // x2 레지스터에 200 쓰기
    WB_wr_addr_i <= 2;
    WB_wr_data_i <= 200;
    @(posedge clk);
    WB_we_i <= 0; // 쓰기 비활성화
    $display("  -> 완료: x1=100, x2=200");
    @(posedge clk);

    // --- 테스트 1: R-type (add x3, x1, x2) ---
    $display("\n[테스트 1] R-type: add x3, x1, x2");
    ID_instruction_i <= 32'h002081b3; // instruction: 0000000 00010 00001 000 00011 0110011
    @(posedge clk);
    #1; // 조합 논리 출력이 안정화될 시간을 줌
    $display("  -> 제어 신호: RegWrite=%b, ALUSrc2=%b, Branch=%b, MemRead=%b, MemWrite=%b",
             ID_RegWrite_o, ID_ALUOpSrc2_o, ID_Branch_o, ID_MemRead_o, ID_MemWrite_o);
    $display("  -> 데이터: rd_data1=0x%h (%d), rd_data2=0x%h (%d)",
             ID_rd_data1_o, ID_rd_data1_o, ID_rd_data2_o, ID_rd_data2_o);
    assert (ID_RegWrite_o == 1 && ID_ALUOpSrc2_o == 0 && ID_Branch_o == 0 && ID_rd_data1_o == 100 && ID_rd_data2_o == 200)
    else $fatal(1, "  -> 실패: R-type 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 2: I-type (addi x4, x1, 50) ---
    $display("\n[테스트 2] I-type: addi x4, x1, 50");
    ID_instruction_i <= 32'h03208213; // instruction: 000000110010 00001 000 00100 0010011
    @(posedge clk);
    #1;
    $display("  -> 제어 신호: RegWrite=%b, ALUSrc2=%b", ID_RegWrite_o, ID_ALUOpSrc2_o);
    $display("  -> 데이터: rd_data1=0x%h (%d), imm=0x%h (%d)",
             ID_rd_data1_o, ID_rd_data1_o, ID_imm_o, $signed(ID_imm_o));
    assert (ID_RegWrite_o == 1 && ID_ALUOpSrc2_o == 1 && ID_rd_data1_o == 100 && $signed(ID_imm_o) == 50)
    else $fatal(1, "  -> 실패: I-type 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 3: Load (lw x5, 8(x1)) ---
    $display("\n[테스트 3] Load-type: lw x5, 8(x1)");
    ID_instruction_i <= 32'h0080a283; // instruction: 000000001000 00001 010 00101 0000011
    @(posedge clk);
    #1;
    $display("  -> 제어 신호: RegWrite=%b, MemRead=%b, WBSel=%s", ID_RegWrite_o, ID_MemRead_o, ID_WBSel_o.name());
    $display("  -> 데이터: rd_data1=0x%h (%d), imm=0x%h (%d)",
             ID_rd_data1_o, ID_rd_data1_o, ID_imm_o, $signed(ID_imm_o));
    assert (ID_RegWrite_o == 1 && ID_MemRead_o == 1 && ID_WBSel_o == WB_MEM && $signed(ID_imm_o) == 8)
    else $fatal(1, "  -> 실패: Load-type 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 4: Store (sw x2, 12(x1)) ---
    $display("\n[테스트 4] Store-type: sw x2, 12(x1)");
    ID_instruction_i <= 32'h0020a623; // instruction: 0000000 00010 00001 010 01100 0100011
    @(posedge clk);
    #1;
    $display("  -> 제어 신호: RegWrite=%b, MemWrite=%b", ID_RegWrite_o, ID_MemWrite_o);
    $display("  -> 데이터: rd_data1=0x%h (%d), rd_data2=0x%h (%d), imm=0x%h (%d)",
             ID_rd_data1_o, ID_rd_data1_o, ID_rd_data2_o, ID_rd_data2_o, ID_imm_o, $signed(ID_imm_o));
    assert (ID_RegWrite_o == 0 && ID_MemWrite_o == 1 && ID_rd_data1_o == 100 && ID_rd_data2_o == 200 && $signed(ID_imm_o) == 12)
    else $fatal(1, "  -> 실패: Store-type 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 5: Branch (beq x1, x2, offset) ---
    $display("\n[테스트 5] Branch-type: beq x1, x2, offset");
    ID_instruction_i <= 32'h00208863; // beq x1, x2, 16
    @(posedge clk);
    #1;
    $display("  -> 제어 신호: RegWrite=%b, Branch=%b", ID_RegWrite_o, ID_Branch_o);
    $display("  -> 데이터: rd_data1=0x%h (%d), rd_data2=0x%h (%d)",
             ID_rd_data1_o, ID_rd_data1_o, ID_rd_data2_o, ID_rd_data2_o);
    assert (ID_RegWrite_o == 0 && ID_Branch_o == 1 && ID_rd_data1_o == 100 && ID_rd_data2_o == 200)
    else $fatal(1, "  -> 실패: Branch-type 테스트 실패!");
    $display("  -> 성공!");


    $display("\n=================================================");
    $display("=== 모든 테스트 통과! ===");
    $display("=================================================");
    $finish;
  end

endmodule

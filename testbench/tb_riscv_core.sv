`timescale 1ns / 1ps

import defines::*;

module tb_riscv_core;

  // 파라미터 및 신호 선언
  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 5;
  localparam int CLK_PERIOD = 10;

  // DUT 연결 신호
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] instruction_i;
  logic [DATA_WIDTH-1:0] pc_i;

  // DUT의 레지스터 파일에 쓰기 위한 신호 (decode_stage로 직접 연결됨)
  logic WB_we;
  logic [ADDR_WIDTH-1:0] WB_wr_addr;
  logic [DATA_WIDTH-1:0] WB_wr_data;

  // DUT 출력 신호
  logic [DATA_WIDTH-1:0] alu_result_o;
  logic alu_zeroFlag_o;

  // DUT 인스턴스화
  riscv_core dut (.*);

  // 클럭 생성
  always #(CLK_PERIOD / 2) clk = ~clk;

  // 테스트 시퀀스
  initial begin
    $display("=================================================");
    $display("=== RISC-V Core (DE-EX) Testbench 시작 ===");
    $display("=================================================");

    // --- 1. 초기화 ---
    clk = 0;
    rst_n = 1;
    instruction_i = '0;
    pc_i = '0;
    WB_we = 0;
    WB_wr_addr = '0;
    WB_wr_data = '0;

    // 리셋 적용
    rst_n <= 0;
    repeat(2) @(posedge clk);
    rst_n <= 1;
    $display("\n[초기화] 리셋 완료.");
    @(posedge clk);

    // --- 2. 테스트 준비: 레지스터에 초기값 쓰기 ---
    $display("\n[준비] 테스트를 위한 초기값 레지스터에 쓰기...");
    // x1 레지스터에 100 쓰기
    WB_we <= 1;
    WB_wr_addr <= 1;
    WB_wr_data <= 100;
    @(posedge clk);
    // x2 레지스터에 200 쓰기
    WB_wr_addr <= 2;
    WB_wr_data <= 200;
    @(posedge clk);
    WB_we <= 0; // 쓰기 비활성화
    $display("  -> 완료: x1=100, x2=200");
    @(posedge clk);

    // --- 3. 테스트 시작 ---
    // 파이프라인 지연: 명령어 입력 후 2 클럭 뒤에 결과 확인

    // --- 테스트 1: R-type (add x3, x1, x2) ---
    $display("\n[테스트 1] R-type: add x3, x1, x2");
    instruction_i <= 32'h002081b3; // add x3, x1, x2
    pc_i <= 32'h0000_1000;
    @(posedge clk); // Decode Stage
    @(posedge clk); // Execute Stage
    #1; // 결과 안정화 시간
    $display("  -> 예상 결과: %d, 실제 결과: %d", 300, alu_result_o);
    $display("  -> 예상 Zero Flag: %b, 실제 Zero Flag: %b", 0, alu_zeroFlag_o);
    assert (alu_result_o == 300 && alu_zeroFlag_o == 0)
    else $fatal(1, "  -> 실패: R-type (add) 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 2: I-type (addi x4, x1, 50) ---
    $display("\n[테스트 2] I-type: addi x4, x1, 50");
    instruction_i <= 32'h03208213; // addi x4, x1, 50
    pc_i <= 32'h0000_1004;
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("  -> 예상 결과: %d, 실제 결과: %d", 150, alu_result_o);
    assert (alu_result_o == 150)
    else $fatal(1, "  -> 실패: I-type (addi) 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 3: R-type (sub x5, x2, x1) ---
    $display("\n[테스트 3] R-type: sub x5, x2, x1");
    instruction_i <= 32'h401102b3; // sub x5, x2, x1
    pc_i <= 32'h0000_1008;
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("  -> 예상 결과: %d, 실제 결과: %d", 100, alu_result_o);
    assert (alu_result_o == 100)
    else $fatal(1, "  -> 실패: R-type (sub) 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 4: R-type (sub x6, x1, x1) -> Zero Flag 확인 ---
    $display("\n[테스트 4] R-type (Zero Flag): sub x6, x1, x1");
    instruction_i <= 32'h40108333; // sub x6, x1, x1
    pc_i <= 32'h0000_100C;
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("  -> 예상 결과: %d, 실제 결과: %d", 0, alu_result_o);
    $display("  -> 예상 Zero Flag: %b, 실제 Zero Flag: %b", 1, alu_zeroFlag_o);
    assert (alu_result_o == 0 && alu_zeroFlag_o == 1)
    else $fatal(1, "  -> 실패: R-type (sub, zero) 테스트 실패!");
    $display("  -> 성공!");

    // --- 테스트 5: I-type (lw 주소 계산) lw x7, 12(x1) ---
    $display("\n[테스트 5] I-type (lw 주소 계산): lw x7, 12(x1)");
    instruction_i <= 32'h00c0a383; // lw x7, 12(x1)
    pc_i <= 32'h0000_1010;
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("  -> 예상 주소 결과: %d, 실제 주소 결과: %d", 112, alu_result_o);
    assert (alu_result_o == 112)
    else $fatal(1, "  -> 실패: I-type (lw addr) 테스트 실패!");
    $display("  -> 성공!");


    $display("\n=================================================");
    $display("=== 모든 테스트 통과! ===");
    $display("=================================================");
    repeat(10) @(posedge clk);
    $finish;
  end

endmodule

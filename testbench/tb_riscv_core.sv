`timescale 1ns / 1ps

module tb_riscv_core;

  // --- Parameters ---
  localparam CLK_PERIOD = 10; // 10ns = 100MHz

  // --- Testbench Signals ---
  logic clk;
  logic rst_n;

  // --- Instantiate the DUT (Device Under Test) ---
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // --- Clock Generation ---
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // --- Test Sequence ---
  initial begin
    $display("===============================================");
    $display("= Starting Forwarding Unit Test Simulation  =");
    $display("===============================================");

    // 1. 리셋 인가
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    $display("[%0t] Reset released.", $time);

    // 2. 프로그램이 끝나고 무한루프에 도달할 때까지 충분한 시간 동안 시뮬레이션 실행
    repeat (15) @(posedge clk);

    // 3. 최종 레지스터 값 검증
    $display("\n-----------------------------------------------");
    $display("--- Final Register State Verification ---");
    $display("-----------------------------------------------");
    
    // 포워딩이 성공했다면 아래 값들이 정확히 일치해야 합니다.
    // DUT 내부 레지스터 파일 경로는 실제 설계에 맞게 수정해야 할 수 있습니다.
    // 예: dut.decode_stage_inst.register_file_inst.rf[1]
    verify_register("x1 (5)",  dut.decode_stage_inst.register_file_inst.registers[1], 32'd5);
    verify_register("x2 (15)", dut.decode_stage_inst.register_file_inst.registers[2], 32'd15);
    verify_register("x3 (20)", dut.decode_stage_inst.register_file_inst.registers[3], 32'd20);

    $display("\n===============================================");
    $display("= Simulation Finished =");
    $display("===============================================");
    #1000;
    $finish; 
  end

  // --- 검증용 태스크 ---
  task verify_register(string name, logic [31:0] value, logic [31:0] expected);
    if (value === expected) begin
      $display("[PASS] %s: Expected %0d, Got %0d", name, expected, value);
    end else begin
      $error("[FAIL] %s: Expected %0d, Got %0d", name, expected, value);
    end
  endtask

endmodule

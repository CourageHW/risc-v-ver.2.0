
`timescale 1ns / 1ps

// 테스트벤치에 필요한 파라미터를 정의합니다.
// defines 패키지를 사용하지 않고, 테스트벤치 내에서 localparam으로 정의하여 단독 실행이 가능하도록 했습니다.
module tb_register_file;

  // 파라미터 정의
  localparam int DATA_WIDTH = 32;
  localparam int REG_COUNT  = 32;
  localparam int ADDR_WIDTH = $clog2(REG_COUNT);
  localparam int CLK_PERIOD = 10; // 클럭 주기 (10ns -> 100MHz)

  // DUT 연결을 위한 신호 선언
  logic clk;
  logic rst_n;
  logic we_i;
  logic [ADDR_WIDTH-1:0] wr_addr_i;
  logic [DATA_WIDTH-1:0] wr_data_i;
  logic [ADDR_WIDTH-1:0] rd_addr1_i;
  logic [ADDR_WIDTH-1:0] rd_addr2_i;
  logic [DATA_WIDTH-1:0] rd_data1_o;
  logic [DATA_WIDTH-1:0] rd_data2_o;


  logic test_passed;
  // DUT (Device Under Test) 인스턴스화
  // 'defines::*'를 임포트하는 원본 모듈을 그대로 사용합니다.
  // 이 테스트벤치는 defines 패키지에 의존하지 않습니다.
  register_file dut (
    .clk(clk),
    .rst_n(rst_n),
    .we_i(we_i),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .rd_addr1_i(rd_addr1_i),
    .rd_addr2_i(rd_addr2_i),
    .rd_data1_o(rd_data1_o),
    .rd_data2_o(rd_data2_o)
  );

  // 클럭 생성기
  always #(CLK_PERIOD / 2) clk = ~clk;

  // 테스트 시나리오
  initial begin
    $display("======================================================");
    $display("Testbench Started.");
    $display("======================================================");

    // 1. 초기화 및 리셋 테스트
    clk = 0;
    rst_n = 1'b1;
    we_i = 1'b0;
    wr_addr_i = '0;
    wr_data_i = '0;
    rd_addr1_i = '0;
    rd_addr2_i = '0;

    $display("\n[Test 1] Applying reset...");
    rst_n <= 1'b0; // 리셋 활성화
    repeat (2) @(posedge clk);
    rst_n <= 1'b1; // 리셋 비활성화
    $display("Reset released. All registers should be 0.");
    @(posedge clk);

    // 2. 기본 쓰기 및 읽기 테스트
    $display("\n[Test 2] Basic Write and Read Test");
    $display("Writing 0xDEADBEEF to register 5...");
    we_i      <= 1'b1;
    wr_addr_i <= 5;
    wr_data_i <= 32'hDEADBEEF;
    @(posedge clk);
    we_i      <= 1'b0; // 다음 사이클에서는 쓰기 비활성화

    $display("Reading from register 5...");
    rd_addr1_i <= 5;
    @(posedge clk); // 데이터가 출력되기를 기다림 (조합 논리이므로 사실 바로 반영됨)

    if (rd_data1_o === 32'hDEADBEEF) begin
      $display("  -> SUCCESS: Read data matches written data (0x%h)", rd_data1_o);
    end else begin
      $display("  -> FAILURE: Read data (0x%h) does not match (0x%h)", rd_data1_o, 32'hDEADBEEF);
    end

    // 3. 동시 읽기 테스트
    $display("\n[Test 3] Simultaneous Read Test");
    $display("Writing 0xCAFEAFFE to register 10...");
    we_i      <= 1'b1;
    wr_addr_i <= 10;
    wr_data_i <= 32'hCAFEAFFE;
    @(posedge clk);
    we_i      <= 1'b0;

    $display("Reading from reg 5 (port 1) and reg 10 (port 2) simultaneously...");
    rd_addr1_i <= 5;
    rd_addr2_i <= 10;
    @(posedge clk);

    $display("  -> Port 1 (reg 5) data: 0x%h", rd_data1_o);
    $display("  -> Port 2 (reg 10) data: 0x%h", rd_data2_o);
    if (rd_data1_o === 32'hDEADBEEF && rd_data2_o === 32'hCAFEAFFE) begin
      $display("  -> SUCCESS: Both ports read correct data.");
    end else begin
      $display("  -> FAILURE: Read data is incorrect.");
    end

    // 4. 주소 0 쓰기 방지 테스트
    $display("\n[Test 4] Write to address 0 should be ignored");
    $display("Attempting to write 0xBAD0BAD0 to register 0...");
    we_i      <= 1'b1;
    wr_addr_i <= 0;
    wr_data_i <= 32'hBAD0BAD0;
    @(posedge clk);
    we_i      <= 1'b0;

    $display("Reading from register 0...");
    rd_addr1_i <= 0;
    @(posedge clk);

    if (rd_data1_o === 32'h0) begin
      $display("  -> SUCCESS: Register 0 remains 0 (0x%h)", rd_data1_o);
    end else begin
      $display("  -> FAILURE: Register 0 was written with 0x%h", rd_data1_o);
    end

    // 5. 연속 쓰기 및 읽기 테스트
    $display("\n[Test 5] Sequential Write/Read Test");
    for (int i = 1; i < 16; i++) begin
      we_i      <= 1'b1;
      wr_addr_i <= i;
      wr_data_i <= i * 100;
      @(posedge clk);
    end
    we_i <= 1'b0;
    $display("Finished writing to registers 1 through 15.");

    test_passed = 1;
    for (int i = 1; i < 16; i++) begin
      rd_addr1_i <= i;
      // 조합 논리 출력을 확인하기 위해 약간의 딜레이를 줌
      #1; 
      if (rd_data1_o !== i * 100) begin
        $display("  -> FAILURE: Read from reg %0d. Expected %0d, Got %0d", i, i*100, rd_data1_o);
        test_passed = 0;
      end
    end

    if(test_passed) begin
        $display("  -> SUCCESS: All sequentially written data verified.");
    end

    $display("\n======================================================");
    $display("Testbench Finished.");
    $display("======================================================");

    repeat(10) @(posedge clk);
    $finish;
  end

  // 모니터링 (선택 사항): 신호 변경 시마다 값 출력
  // initial begin
  //   $monitor("Time=%0t, clk=%b, rst_n=%b, we=%b, wr_addr=%d, wr_data=0x%h, rd_addr1=%d, rd_data1=0x%h, rd_addr2=%d, rd_data2=0x%h",
  //            $time, clk, rst_n, we_i, wr_addr_i, wr_data_i, rd_addr1_i, rd_data1_o, rd_addr2_i, rd_data2_o);
  // end

endmodule

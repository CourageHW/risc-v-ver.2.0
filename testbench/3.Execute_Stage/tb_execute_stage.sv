`timescale 1ns / 1ps

import defines::*;

module tb_execute_stage;
  localparam CLK_PERIOD = 10; // 10ns

  logic clk;

  // execute_stage 모듈의 입력 포트에 연결될 신호들
  logic [DATA_WIDTH-1:0] EX_alu_operand1_i;
  logic [DATA_WIDTH-1:0] EX_alu_operand2_i;
  logic [2:0] EX_alu_ctrl_funct3_i;
  logic EX_alu_ctrl_funct7_i;
  alu_op_e EX_ALUOp_i;

  // execute_stage 모듈의 출력 포트에서 받을 신호들
  logic [DATA_WIDTH-1:0] EX_alu_result_o;
  logic EX_alu_zeroFlag_o;

  // DUT (Design Under Test): execute_stage 모듈 인스턴스화
  execute_stage dut (
    .EX_alu_operand1_i(EX_alu_operand1_i),
    .EX_alu_operand2_i(EX_alu_operand2_i),
    .EX_alu_ctrl_funct3_i(EX_alu_ctrl_funct3_i),
    .EX_alu_ctrl_funct7_i(EX_alu_ctrl_funct7_i),
    .EX_ALUOp_i(EX_ALUOp_i),
    .EX_alu_result_o(EX_alu_result_o),
    .EX_alu_zeroFlag_o(EX_alu_zeroFlag_o)
  );

  // 클럭 생성
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // 테스트 케이스를 수행하는 task
  task automatic test (
    input alu_op_e      ALUOp_t,
    input logic [2:0]   alu_ctrl_funct3_t,
    input logic         alu_ctrl_funct7_t,
    input logic [DATA_WIDTH-1:0] operand1_t, // ALU operand 1
    input logic [DATA_WIDTH-1:0] operand2_t, // ALU operand 2
    input logic [DATA_WIDTH-1:0] expected_result, // 예상되는 ALU 결과
    input logic         expected_zeroFlag, // 예상되는 Zero Flag
    input string        OperateName // 테스트 케이스 이름
    );

    @(posedge clk); // 클럭 엣지 대기
    #1; // 작은 지연 후 입력 인가

    // DUT의 입력 신호에 값 할당
    EX_ALUOp_i          = ALUOp_t;
    EX_alu_ctrl_funct3_i = alu_ctrl_funct3_t;
    EX_alu_ctrl_funct7_i = alu_ctrl_funct7_t;
    EX_alu_operand1_i   = operand1_t;
    EX_alu_operand2_i   = operand2_t;

    @(posedge clk); // 다음 클럭 엣지 대기 (DUT가 연산을 수행할 시간)
    #1; // 작은 지연 후 출력 값 확인 (조합 로직이므로 다음 클럭 엣지 후 안정화)

    // ALU 결과값 검증
    assert(EX_alu_result_o == expected_result)
      else $error("Mismatch result for %s: Expected ALU Result = %0d, Got = %0d at %0t",
        OperateName, expected_result, EX_alu_result_o, $time);

    // Zero Flag 검증
    assert(EX_alu_zeroFlag_o == expected_zeroFlag)
      else $error("Mismatch zeroFlag for %s: Expected Zero Flag = %0d, Got = %0d at %0t",
        OperateName, expected_zeroFlag, EX_alu_zeroFlag_o, $time);

    $display("[Pass] %s", OperateName);
  endtask

  initial begin
    // 초기값 설정
    EX_ALUOp_i          = ALUOP_NONE;
    EX_alu_ctrl_funct3_i = '0;
    EX_alu_ctrl_funct7_i = '0;
    EX_alu_operand1_i   = '0;
    EX_alu_operand2_i   = '0;

    @(posedge clk); // 초기 클럭 동기화

    $display("\n=======================");
    $display("[Start] Execute Stage Test at %0t", $time);
    $display("========================\n");

    // --- Memory Address Calculations (ALU_ADD) ---
    test(ALUOP_MEM_ADDR, 3'bxxx, 1'bx, 32'd100, 32'd20, 32'd120, 0, "MEM_ADDR_ADD");

    // --- Branch Operations (ALU_SUB) ---
    test(ALUOP_BRANCH, 3'bxxx, 1'bx, 32'd50, 32'd50, 32'd0, 1, "BRANCH_EQ (Zero)");
    test(ALUOP_BRANCH, 3'bxxx, 1'bx, 32'd50, 32'd40, 32'd10, 0, "BRANCH_NE (Non-Zero)");

    // --- LUI (ALU_PASS_B) ---
    // LUI는 operand1이 0이고 operand2가 Immediate (U-type)인 경우가 많음
    test(ALUOP_LUI, 3'bxxx, 1'bx, 32'd0, 32'hABCD_0000, 32'hABCD_0000, 0, "LUI Pass B");

    // --- JUMP (ALU_ADD) ---
    // JUMP는 보통 PC + offset (addi) 같은 연산
    test(ALUOP_JUMP, 3'bxxx, 1'bx, 32'h1000, 32'd4, 32'h1004, 0, "JUMP_ADD (PC+4)");

    // --- R-Type Operations ---
    // Assuming FUNCT7_ADD = 1'b0, FUNCT7_SUB = 1'b1
    test(ALUOP_RTYPE, FUNCT3_ADD_SUB, FUNCT7_ADD, 32'd15, 32'd7, 32'd22, 0, "RTYPE ADD");
    test(ALUOP_RTYPE, FUNCT3_ADD_SUB, FUNCT7_SUB, 32'd15, 32'd7, 32'd8,  0, "RTYPE SUB");
    test(ALUOP_RTYPE, FUNCT3_SRL_SRA, FUNCT7_SRL, 32'd16, 32'd2, 32'd4,  0, "RTYPE SRL");
    test(ALUOP_RTYPE, FUNCT3_SRL_SRA, FUNCT7_SRA, -32'sd16, 32'd2, -32'sd4, 0, "RTYPE SRA"); // SRA Negative Test
    test(ALUOP_RTYPE, FUNCT3_SLL,     1'bx,       32'd5,  32'd3, 32'd40, 0, "RTYPE SLL");
    test(ALUOP_RTYPE, FUNCT3_SLT,     1'bx,       32'd10, 32'd20, 32'd1, 0, "RTYPE SLT (true)");
    test(ALUOP_RTYPE, FUNCT3_SLTU,    1'bx,       32'd10, 32'd20, 32'd1, 0, "RTYPE SLTU (true)");
    test(ALUOP_RTYPE, FUNCT3_XOR,     1'bx,       32'd5,  32'd3, 32'd6,  0, "RTYPE XOR");
    test(ALUOP_RTYPE, FUNCT3_OR,      1'bx,       32'd5,  32'd3, 32'd7,  0, "RTYPE OR");  // Add if ALU Control supports FUNCT3_OR for R-type
    test(ALUOP_RTYPE, FUNCT3_AND,     1'bx,       32'd5,  32'd3, 32'd1,  0, "RTYPE AND"); // Add if ALU Control supports FUNCT3_AND for R-type


    // --- I-Type Arithmetic Operations ---
    // Assuming FUNCT7_SRL = 1'b0, FUNCT7_SRA = 1'b1
    test(ALUOP_ITYPE_ARITH, FUNCT3_SRL_SRA, FUNCT7_SRL, 32'd32, 32'd3, 32'd4,  0, "ITYPE SRL");
    test(ALUOP_ITYPE_ARITH, FUNCT3_SRL_SRA, FUNCT7_SRA, -32'sd32, 32'd3, -32'sd4, 0, "ITYPE SRA"); // SRAI Negative Test
    test(ALUOP_ITYPE_ARITH, FUNCT3_ADD_SUB, 1'bx,       32'd10, 32'd5, 32'd15, 0, "ITYPE ADD (addi)");
    test(ALUOP_ITYPE_ARITH, FUNCT3_SLL,     1'bx,       32'd6,  32'd2, 32'd24, 0, "ITYPE SLL (slli)");
    test(ALUOP_ITYPE_ARITH, FUNCT3_SLT,     1'bx,       32'd10, 32'd5, 32'd0,  1, "ITYPE SLT (false)");
    test(ALUOP_ITYPE_ARITH, FUNCT3_SLTU,    1'bx,       32'd5,  32'd10, 32'd1, 0, "ITYPE SLTU (true)");
    test(ALUOP_ITYPE_ARITH, FUNCT3_XOR,     1'bx,       32'd7,  32'd2, 32'd5,  0, "ITYPE XOR (xori)");
    test(ALUOP_ITYPE_ARITH, FUNCT3_OR,      1'bx,       32'd6,  32'd1, 32'd7,  0, "ITYPE OR (ori)"); // Add if ALU Control supports FUNCT3_OR for I-type
    test(ALUOP_ITYPE_ARITH, FUNCT3_AND,     1'bx,       32'd7,  32'd3, 32'd3,  0, "ITYPE AND (andi)"); // Add if ALU Control supports FUNCT3_AND for I-type



    $display("\n==============================");
    $display("[Success] Execute Stage Test Complete!");
    $display("===============================\n");
    repeat(10) @(posedge clk); // 시뮬레이션 종료 전 추가 대기

    $finish;
  end

endmodule

`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: CodeDragon
//
// Create Date: 2018/03/08 08:35:37
// Design Name:
// Module Name: controller
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

// @brief CPU controller

module Controller(
        input wire[5: 0] operator,
        input wire[5: 0] special,
        output wire[3: 0] aluOperator,
        output wire[1: 0] aluX,
        output wire[2: 0] aluY,
        output wire regWriteEnable,
        output wire[1: 0] regWriteDestinationControl,
        output wire regWriteSourceControl,
        output wire ramWrite,
        output wire[1: 0] pcWrite,
        output wire jump,
        output wire syscall,
        output wire lbu,
        output wire bltz
    );

    reg[31: 0] result = 0;
    //  result layout
    //   aluOperator aluX aluY rWE rWD rWS ramWrite pcWrite jump syscall RESERVE
    //  |           |    |    |   |   |   |        |       |    |       |       |
    // 31          28   26   23  22  20  19       18      16   15      14       0
    // first bit of RESERVE is lbu
    // second bit of RESERVE is bltz

    assign aluOperator = result[31: 28];
    assign aluX = result[27: 26];
    assign aluY = result[25: 23];
    assign regWriteEnable = result[22];
    assign regWriteDestinationControl = result[21: 20];
    assign regWriteSourceControl = result[19];
    assign ramWrite = result[18];
    assign pcWrite = result[17: 16];
    assign jump = result[15];
    assign syscall = result[14];
    assign lbu = result[13];
    assign bltz = result[12];

    always @ (operator, special) begin
        case (operator)
            6'b001000: result = 32'b0101_00_010_1_10_1_0_00_0_0_00000000000000;
            6'b001001: result = 32'b0101_00_010_1_10_1_0_00_0_0_00000000000000;
            6'b001100: result = 32'b0111_00_010_1_10_1_0_00_0_0_00000000000000;
            6'b001101: result = 32'b1000_00_010_1_10_1_0_00_0_0_00000000000000;
            6'b100011: result = 32'b0101_00_010_1_10_0_0_00_0_0_00000000000000;
            6'b101011: result = 32'b0101_00_010_0_10_1_1_00_0_0_00000000000000;
            6'b000100: result = 32'b1110_00_000_0_10_1_0_10_0_0_00000000000000;
            6'b000101: result = 32'b1110_00_000_0_10_1_0_11_0_0_00000000000000;
            6'b001010: result = 32'b1011_00_010_1_10_1_0_00_0_0_00000000000000;
            6'b000010: result = 32'b0000_00_000_0_10_1_0_00_1_0_00000000000000;
            6'b000011: result = 32'b0101_10_011_1_11_1_0_00_1_0_00000000000000;
            // sltiu (HuSixu's ccmb)
            6'b001011: result = 32'b1100_00_010_1_10_1_0_00_0_0_00000000000000;
            // lbu (HuSixu's ccmb)
            6'b100100: result = 32'b0101_00_010_1_10_0_0_00_0_0_10000000000000;
            // bltz (HuSixu's ccmb)
            6'b000001: result = 32'b1011_00_000_0_10_1_0_00_0_0_01000000000000;
            6'b000000: begin
                case (special)
                    6'b100000: result = 32'b0101_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b100001: result = 32'b0101_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b100100: result = 32'b0111_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b000000: result = 32'b0000_01_001_1_00_1_0_00_0_0_00000000000000;
                    6'b000011: result = 32'b0001_01_001_1_00_1_0_00_0_0_00000000000000;
                    6'b000010: result = 32'b0010_01_001_1_00_1_0_00_0_0_00000000000000;
                    6'b100010: result = 32'b0110_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b100101: result = 32'b1000_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b100111: result = 32'b1010_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b101010: result = 32'b1011_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b101011: result = 32'b1100_00_000_1_00_1_0_00_0_0_00000000000000;
                    6'b001000: result = 32'b0000_00_000_0_00_1_0_01_0_0_00000000000000;
                    6'b001100: result = 32'b0000_00_000_0_00_1_0_00_0_1_00000000000000;
                    // srlv (HuSixu's ccmb)
                    6'b000110: result = 32'b0010_01_100_1_00_1_0_00_0_0_00000000000000;
                    default: result = 32'h0;
                endcase
            end
            default: result = 32'h0;
        endcase
    end
endmodule

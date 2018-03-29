`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: HuSixu
//
// Create Date: 03/08/2018 11:04:46 AM
// Design Name:
// Module Name: syscall
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

/// @brief the syscall controller
module Syscall(
        input wire[31: 0] regSValue,
        input wire[31: 0] regTValue,
        input wire syscall,
        input wire clock,
        input wire reset,
        output wire enable,
        output reg[31: 0] syscallOutput = 0
    );

    reg regEnable = 0;
    assign enable = ~regEnable;

    always @(posedge clock) begin
        if (syscall && regSValue != 32'h0000_000a) begin
            syscallOutput <= regTValue;
        end else if (syscall && regSValue == 32'h0000_000a) begin
            regEnable <= 1;
        end else if (reset) begin
            syscallOutput <= 0;
            regEnable <= 0;
        end
    end
endmodule

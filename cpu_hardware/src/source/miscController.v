`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: CodeDragon
//
// Create Date: 2018/03/09 22:17:22
// Design Name:
// Module Name: miscController
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

//@brief misc controller to display information and control frequency

module MiscController(
        input wire clock,
        input wire frequency,
        // input wire memoryAddress[9: 0], Nope memory address should directly
        // passed to mux
        input wire[2: 0] functionNumber,

        input wire[31: 0] syscallOutput,
        input wire[31: 0] memory,
        input wire[31: 0] pc,
        input wire[31: 0] totalCycle,
        input wire[31: 0] unconditionalJump,
        input wire[31: 0] conditionalJump,
        input wire[31: 0] conditionalSuccessfulJump,

        output wire enable, // if to print memory address, pc should be halted
        output wire memoryAddressControl, // define the source of memory address
        output reg[31: 0] data,
        output wire clockOut
    );

    wire lessDevidedClock;
    wire devidedClock;
    ClockDivider #(5)lessClockDivider(.clock(clock), .reset(0),
                                        .clockOut(lessDevidedClock));
    ClockDivider #(1000000)clockDivider(.clock(clock), .reset(0),
                                        .clockOut(devidedClock));

    assign clockOut = (frequency == 0) ? lessDevidedClock : devidedClock;

    assign enable = (functionNumber == 3'b001) ? 0 : 1;

    assign memoryAddressControl = (functionNumber == 3'b001) ? 1 : 0;

    always  @(functionNumber, syscallOutput, memory,
            pc, totalCycle, unconditionalJump,
            conditionalJump, conditionalSuccessfulJump) begin
        case (functionNumber)
            3'b000: data = syscallOutput;
            3'b001: data = memory;
            3'b010: data = pc;
            3'b011: data = totalCycle;
            3'b100: data = unconditionalJump;
            3'b101: data = conditionalJump;
            3'b110: data = conditionalSuccessfulJump;
            default: data = 32'h0;
        endcase
    end
endmodule

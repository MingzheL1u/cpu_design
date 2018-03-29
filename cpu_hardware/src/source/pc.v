`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: HuSixu
//
// Create Date: 03/08/2018 08:10:46 AM
// Design Name:
// Module Name: pc
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


/// @brief the pc controller
module Pc(
        input wire[31: 0] regSValue,
        input wire[25: 0] instruction,
        input wire[1: 0] pcWrite,
        input wire aluEqual,
        input wire reset,
        input wire enable,
        input wire clock,
        input wire jump,
        input wire bltz,
        output reg[31: 0] pc = 0,
        output reg[31: 0] totalCycle = 0,
        output reg[31: 0] unconditionalJump = 0,
        output reg[31: 0] conditionalJump = 0,
        output reg[31: 0] conditionalSuccessfulJump = 0
    );
    wire [15: 0] immediate;
    assign immediate = instruction[15: 0];

    wire[32: 0] jumpDestination;
    assign jumpDestination = (({4'b000000, instruction, 2'b00}) - 32'h0000_3000);

    always @(posedge clock) begin
        if (enable) begin

            // judge if this is a J instruction
            case ({(bltz && regSValue), jump})
                2'b00: begin
                    // this is not a J instruction, judging by pcWrite hardware
                    // interface
                    case (pcWrite)
                        2'd0: pc <= pc + 4;
                        // jr
                        2'd1: pc <= regSValue;
                        // beq
                        2'd2: begin
                            if (aluEqual) begin
                                pc <= {{14{immediate[15]}}, immediate, 2'b00} + pc + 4;
                            end else begin
                                pc <= pc + 4;
                            end
                        end
                        // bne
                        2'd3: begin
                            if (!aluEqual) begin
                                pc <= {{14{immediate[15]}}, immediate, 2'b00} + pc + 4;
                            end else begin
                                pc <= pc + 4;
                            end
                        end
                    endcase
                end
                2'b01: pc <= jumpDestination;                                  // this is a J instruction
                2'b10: pc <= {{14{immediate[15]}}, immediate, 2'b00} + pc + 4; // bltz, HuSixu's ccmb
                default: pc <= 0;
            endcase
            totalCycle <= totalCycle + 1;
            unconditionalJump <= unconditionalJump + (pcWrite == 1 || jump);
            conditionalJump <= conditionalJump + (pcWrite == 2 || pcWrite == 3);
            conditionalSuccessfulJump <= conditionalSuccessfulJump +
                ((pcWrite == 2 && aluEqual) || (pcWrite == 3 && !aluEqual));
        end else if (reset) begin
            pc <= 0;
            totalCycle <= 0;
            unconditionalJump <= 0;
            conditionalJump <= 0;
            conditionalSuccessfulJump <= 0;
        end
    end
endmodule

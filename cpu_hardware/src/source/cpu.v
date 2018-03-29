`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: HuSixu
//
// Create Date: 03/09/2018 05:37:42 PM
// Design Name:
// Module Name: cpu
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


///@brief the cpu
module Cpu(
        input wire clock,
        input wire resetButton,
        input wire frequency,
        input wire radix,
        input wire[2: 0] functionNumber,
        input wire[4: 0] checkRamAddress,   // by 4-bytes word, address = {4'b0000, checkRamAddress, 2'b00}
        output wire[7: 0] anode,
        output wire[7: 0] cathode
    );
    wire reset;
    assign reset = ~resetButton;
    
    wire[31: 0] syscallOutput;    // for debug
    // MiscController
    wire controlledClock;
    wire miscEnable;
    wire[31: 0] displayData;
    wire checkRam;

    // Rom
    wire[31: 0] instruction;
    wire[31: 0] programCounter;

    // Controller
    wire[1: 0] regWriteDestinationControl;
    wire[1: 0] pcWrite;
    wire[1: 0] aluX;
    wire[2: 0] aluY;
    wire[3: 0] aluOperator;
    wire regWriteEnable;
    wire regWriteSourceControl;
    wire syscall;
    wire jump;
    wire ramWrite;

    // RegFile
    wire[31: 0] ramAddress;
    wire[31: 0] aluResult;
    wire[31: 0] ramResult;
    wire[31: 0] regFileWriteData;
    wire[4: 0] regA;
    wire[4: 0] regB;
    wire[31: 0] regSData;
    wire[31: 0] regTData;
    wire[31: 0] exRamResult;        // ramResult with lbu support
    wire lbu;
    reg[4: 0] regWrite;
    assign regFileWriteData = regWriteSourceControl ? aluResult : exRamResult;
    assign exRamResult = lbu ? {24'h0, ramResult[{30'h0, ramAddress[1:0]} * 8 +: 8 ]} : ramResult;
    always @(regWriteDestinationControl, instruction) begin
        case (regWriteDestinationControl)
            2'd0: regWrite = instruction[15: 11];
            2'd1: regWrite = 5'h0;
            2'd2: regWrite = instruction[20: 16];
            2'd3: regWrite = 5'h1f;
        endcase
    end

    assign regA = syscall ? 5'h2 : instruction[25: 21];
    assign regB = syscall ? 5'h4 : instruction[20: 16];

    // PC
    wire enable;
    wire controlledEnable;
    wire aluEqual;
    wire bltz;
    wire[31: 0] totalCycle;
    wire[31: 0] unconditionalJump;
    wire[31: 0] conditionalJump;
    wire[31: 0] conditionalSuccessfulJump;
    assign controlledEnable = enable & miscEnable;

    // Alu Input
    wire[31: 0] aluInputResultX;
    wire[31: 0] aluInputResultY;

    // Alu
    wire[31: 0] aluResult2;
    wire aluSignedOverflow;
    wire aluUnsignedOverflow;

    assign ramAddress = checkRam
        ? {4'b0, checkRamAddress, 2'b0}
        : (regSData +  (instruction[15] ? {16'hffff, instruction[15: 0]} : {16'h0000, instruction[15: 0]})) ;

    MiscController miscController(
        .clock(clock),
        .frequency(frequency),
        .functionNumber(functionNumber),
        .syscallOutput(syscallOutput),
        .memory(ramResult),
        .pc(programCounter),
        .totalCycle(totalCycle),
        .unconditionalJump(unconditionalJump),
        .conditionalJump(conditionalJump),
        .conditionalSuccessfulJump(conditionalSuccessfulJump),
        //--------//
        .enable(miscEnable),
        .memoryAddressControl(checkRam),
        .data(displayData),
        .clockOut(controlledClock)
    );

    Rom rom(
        .address(programCounter),
        //--------//
        .result(instruction));

    Controller controller(
        .operator(instruction[31: 26]),
        .special(instruction[5: 0]),
        //--------//
        .aluOperator(aluOperator),
        .aluX(aluX),
        .aluY(aluY),
        .regWriteEnable(regWriteEnable),
        .regWriteDestinationControl(regWriteDestinationControl),
        .regWriteSourceControl(regWriteSourceControl),
        .ramWrite(ramWrite),
        .pcWrite(pcWrite),
        .jump(jump),
        .syscall(syscall),
        .lbu(lbu),
        .bltz(bltz));

    Reg regfile(
        .clock(controlledClock),
        .writeData(regFileWriteData),
        .writeEnable(regWriteEnable),
        .regWrite(regWrite),
        .regA(regA),
        .regB(regB),
        //--------//
        .resultA(regSData),
        .resultB(regTData));

    Pc pc(
        .regSValue(regSData),
        .instruction(instruction[25: 0]),
//        .immediate(instruction[15: 0]),
        .pcWrite(pcWrite),
        .aluEqual(aluEqual),
        .reset(reset),
        .enable(controlledEnable),
        .clock(controlledClock),
        .jump(jump),
        .bltz(bltz),
        //--------//
        .pc(programCounter),
        .totalCycle(totalCycle),
        .unconditionalJump(unconditionalJump),
        .conditionalJump(conditionalJump),
        .conditionalSuccessfulJump(conditionalSuccessfulJump));

    AluInput aluInput(
        .pc(programCounter),
        .regTValue(regTData),
        .regSValue(regSData),
        .instruction(instruction[15:0]),
        .aluX(aluX),
        .aluY(aluY),
        //--------//
        .resultX(aluInputResultX),
        .resultY(aluInputResultY));

    Alu alu(
        .x(aluInputResultX),
        .y(aluInputResultY),
        .operator(aluOperator),
        //--------//
        .result(aluResult),
        .result2(aluResult2),
//        .signedOverflow(aluSignedOverflow),
//        .unsignedOverflow(aluUnsignedOverflow),
        .equal(aluEqual));

    // Syscall
    Syscall syscallController(
        .regSValue(regSData),
        .regTValue(regTData),
        .syscall(syscall),
        .clock(controlledClock),
        .reset(reset),
        //--------//
        .enable(enable),
        .syscallOutput(syscallOutput));

    Ram ram(
        .clock(controlledClock),
        .reset(reset),
        .store(ramWrite),
        .address(ramAddress[9:0]),
        .data(regTData),
        //--------//
        .result(ramResult));

    // Display, not part of cpu but still here, use default clock rather than
    // controlledClock
    Display display(
        .data(displayData),
        .radix(radix),
        .clock(clock),
        .reset(reset),
        //--------//
        .cathode(cathode),    // from 7:CA to 0:DP
        .anode(anode)         // form 7:AN7 to 0:AN0
    );
endmodule

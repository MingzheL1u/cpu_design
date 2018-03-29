`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: HuSixu
//
// Create Date: 03/10/2018 10:18:01 PM
// Design Name:
// Module Name: cpu_test
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


module cpu_test();
    reg clock = 0;
    reg reset = 0;
    reg frequency = 0;
    reg[2: 0] functionNumber = 0;
    reg[9: 0] checkRamAddress = 0;

    wire[7: 0]  anode;
    wire[7: 0]  cathode;
    wire[31: 0] syscallOutput;

    Cpu cpu(.clock(clock), .reset(reset), .frequency(frequency),
        .functionNumber(functionNumber), .checkRamAddress(checkRamAddress),
        .anode(anode), .cathode(cathode), .syscallOutput(syscallOutput));

    always #0.5 clock = ~clock;
    initial begin
        reset = 1;
        #10 reset = 0;
    end
endmodule

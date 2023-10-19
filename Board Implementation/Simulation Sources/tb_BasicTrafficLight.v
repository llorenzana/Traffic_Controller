`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 12:51:07 AM
// Design Name: 
// Module Name: tb_BasicTrafficLight
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


module tb_BasicTrafficLight();

    // Signals
    reg clk;
    reg rst;
    wire [2:0] NS_light;
    wire [2:0] EW_light;

    // Instantiate the module under test
    BasicTrafficLight uut (
        .clk(clk),
        .rst(rst),
        .NS_light(NS_light),
        .EW_light(EW_light)
    );

    // Clock generation
    initial begin
       clk=0;
     forever #5 clk = ~clk; 
    end 

    // Initial block
    initial begin
        rst = 1; // Active low reset, initially high
        
        #5 rst = 0;
        
        #5 rst = 1;
        
        #10;   //10 time 

        #1000 $finish;
    end
    
endmodule

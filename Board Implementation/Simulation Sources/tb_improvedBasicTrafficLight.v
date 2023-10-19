`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 12:53:24 AM
// Design Name: 
// Module Name: tb_improvedBasicTrafficLight
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


module tb_improvedBasicTrafficLight();

  
  // Inputs
  reg clk;
  reg rst;

  // Outputs
  wire [2:0] NS_light;
  wire [2:0] EW_light;


  // Instantiate the module
  improvedBasicTrafficLight uut (
    .clk(clk),
    .rst(rst),
    .NS_light(NS_light),
    .EW_light(EW_light)
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Assuming a 10ns clock period, adjust as needed
  end

  // Initial Reset
  initial begin
    rst = 1; // Active low reset
    #10 rst = 0;
    #10 rst = 1;
    
    #500 rst = 0;
        
    #5 rst = 1;
        
    #250 $finish;
  end

  // Monitor signals
  always @(posedge clk) begin
    $display("Time=%0t: NS_light=%b EW_light=%b ",
             $time, NS_light, EW_light);
  end


endmodule

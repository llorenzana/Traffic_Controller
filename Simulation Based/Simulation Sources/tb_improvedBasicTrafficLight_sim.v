`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 12:54:24 AM
// Design Name: 
// Module Name: tb_improvedBasicTrafficLight_sim
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


module tb_improvedBasicTrafficLight_sim();
  
  // Inputs
  reg clk;
  reg rst;

  // Outputs
  wire [2:0] NS_light;
  wire [2:0] EW_light;
  wire [3:0] clk_count;
  wire [2:0] state;
  wire [2:0] prev_state;

  // Instantiate the module
  improvedBasicTrafficLight_sim uut (
    .clk(clk),
    .rst(rst),
    .NS_light(NS_light),
    .EW_light(EW_light),
    .clk_count(clk_count),
    .state(state),
    .prev_state(prev_state)
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
    $display("Time=%0t: NS_light=%b EW_light=%b clk_count=%b state=%b prev_state=%b",
             $time, NS_light, EW_light, clk_count, state, prev_state);
  end


endmodule

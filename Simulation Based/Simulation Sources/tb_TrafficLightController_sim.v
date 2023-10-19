`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 12:56:06 AM
// Design Name: 
// Module Name: tb_TrafficLightController_sim
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


module tb_TrafficLightController_sim();

    reg clk, rst, NS_sensor, EW_sensor;
    wire [2:0] NS_light, EW_light;
    wire [3:0] clk_count;
    wire [2:0] state, prev_state;

    // Instantiate the TrafficLightController_sim module
    TrafficLightController_sim uut (
        .clk(clk),
        .rst(rst),
        .NS_sensor(NS_sensor),
        .EW_sensor(EW_sensor),
        .NS_light(NS_light),
        .EW_light(EW_light),
        .clk_count(clk_count),
        .state(state),
        .prev_state(prev_state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        NS_sensor = 0;
        EW_sensor = 0;

        // Apply reset
        #10 rst = 0;

        #5 rst =1;
        
        // Allow some time for the state machine to stabilize
        #20

        // Test case 1: See if it runs with constant traffic at both lights aka default
        NS_sensor = 1;
        EW_sensor = 1; 
        #280
        NS_sensor = 0;
        EW_sensor = 0;
        
        // Apply reset to start 2nd Scenario
        // A car arrives at the red light and a car is already present at the green light.
        #10 rst = 0;
        #5 rst =1;
        
        #10
        NS_sensor = 1;
        EW_sensor = 0;
        
        #40 
        NS_sensor = 1;
        EW_sensor = 1;
                
        #80
        NS_sensor = 0;
        EW_sensor = 1;
       
        #80
        NS_sensor = 1;
        EW_sensor = 1;

        #85 
        NS_sensor = 1;
        EW_sensor = 0;
        
        // Apply reset to start 3rd Scenario
        // the red light before the 5 second mark and no car is present at the green light
        #20
        NS_sensor = 0;
        EW_sensor = 0;
        rst = 0;
        
        #5 rst =1;
        
        #160 // car at NS sensor transition from NSR_EWG to NSG_EWR
        NS_sensor = 1;
        EW_sensor = 0;
        
        #200 //reset to no cars
        NS_sensor = 0;
        EW_sensor = 0;

        #250 //EW signal on transition from NSG_EWR to NSR_EWG
        NS_sensor = 0; 
        EW_sensor = 1;

        // Apply reset to start 4rd Scenario
        // A car arrives at the red light after the 5 second mark and no car is present at the green light.
        #65 
        NS_sensor = 0; 
        EW_sensor = 0;
        rst = 0; 
        
        #5 rst = 1;
        
        #5 // car on NSG_EWR --> car only NS
        NS_sensor = 1;
        EW_sensor = 0;
        
        #40 //no cars NSG_EWR
        NS_sensor = 0;
        EW_sensor = 0;

        //causes transition
        #45 //NSG_EWR car arrives EW after 5+ seconds of running
        NS_sensor = 0;
        EW_sensor = 1;
        
        
        #130 //no cars 
        NS_sensor = 0; 
        EW_sensor = 0;
        
        //test NSG_EWR --> car arrives at EW
        #155
        NS_sensor = 0; 
        EW_sensor = 1;
        
        // Finish simulation
        #80 $finish;
    end
    
endmodule


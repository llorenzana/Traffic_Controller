`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 12:00:30 AM
// Design Name: 
// Module Name: BasicTrafficLight
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


module BasicTrafficLight(
    input clk, //clock dependencies
    input rst, //active low
    output reg [2:0] NS_light, //North-South light 
    output reg [2:0] EW_light  //East-West light
);
    
    //define states
    parameter
        NSG_EWR = 2'b00, //North-South Green & East-West Red
        NSY_EWR = 2'b01, //North-South Yellow & East-West Red
        NSR_EWG = 2'b10, //North-South Red & East-West Green
        NSR_EWY = 2'b11; //North-South Red & East-West Yellow
    
    //define seconds parameter
    parameter 
        tenSec   =  4'b1010,
        twoSec   =  4'b0010,
        zeroSec  =  4'b0000; 
    
    //define light colors use One-Hot Encoding
    parameter 
        red      =  3'b100,
        yellow   =  3'b010,
        green    =  3'b001; 
        
    //define state registers 
    reg [1:0] state, next_state;     
    
    //define clk for count down
    reg [3:0] clk_count; //used to verify timing 
    
    //next state
    always@(posedge clk, negedge rst) 
        state <= (!rst) ? 2'b00 : next_state;        
     
    //Create State-Machine
    always @(*) begin 
        case(state) 
            NSY_EWR:  //North-South Yellow & East-West Red
                if(clk_count != zeroSec )begin 
                    NS_light = yellow;
                    EW_light = red;
                end else   
                    next_state = NSR_EWG;      
            
            NSR_EWG:  //North-South Red & East-West Green
                if(clk_count != zeroSec) begin 
                    NS_light = red;
                    EW_light = green;
                end else  
                    next_state = NSR_EWY;              
            
            
            NSR_EWY:  //North-South Red & East-West Yellow
                if(clk_count != zeroSec) begin 
                    NS_light = red;
                    EW_light = yellow;
                end else 
                    next_state = NSG_EWR;         
 
            default:  //North-South Green & East-West Red
                if(clk_count != zeroSec ) begin  
                    next_state = NSG_EWR;
                    NS_light = green;
                    EW_light = red;
                end else   
                    next_state = NSY_EWR; //transition to Yellow-Red state
             
        endcase 
    end 
    
    // state actions 
    always @(posedge clk) begin  
        case (state)                
             NSG_EWR, NSR_EWG: //case of Green-Red or Red-Green
                clk_count <= (clk_count != zeroSec) ? (clk_count - 1'b1) : twoSec; //using downcounter for simplified logic
                
             NSY_EWR, NSR_EWY: //case of Yellow-Red or Red-Yellow 
                clk_count <= (clk_count != zeroSec) ? (clk_count - 1'b1) : tenSec; //using downcounter for simplified logic           
              
              default: clk_count <= tenSec; //case of reset
              
        endcase
    end
    
endmodule

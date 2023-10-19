`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 08:11:59 PM
// Design Name: 
// Module Name: default_light
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
module default_light(
    input clk, //clock dependencies
    input rst, //active low
    output reg [2:0] NS_light, //North-South light 
    output reg [2:0] EW_light,  //East-West light
    output reg [3:0] clk_count
    );
    
    //define states
    parameter
        NSG_EWR = 2'b00, //North-South Green & East-West Red
        NSY_EWR = 2'b01, //North-South Yellow & East-West Red
        NSR_EWG = 2'b10, //North-South Red & East-West Green
        NSR_EWY = 2'b11; //North-South Red & East-West Yellow
    
    //define seconds parameter
    parameter 
        tenSec = 4'b1010,
        threeSec = 4'b0011,
        zeroSec = 4'b0000; 
    
    //define light colors use One-Hot Encoding
    parameter 
        red = 3'b100,
        yellow = 3'b010,
        green = 3'b001; 
        
    //define state registers 
    reg [1:0] state, next_state;     
    
    //next state
    always@(posedge clk, negedge rst) begin
        if (!rst)      
            state <= 2'b00;
        else
            state <= next_state;        
    end 
        
    //Create State-Machine
    always @(*) begin 
        case(state) 
            NSY_EWR: begin //North-South Yellow & East-West Red
                if(clk_count != zeroSec )begin 
                    next_state = NSY_EWR;
                    NS_light = yellow;
                    EW_light = red;
                end else   
                    next_state = NSR_EWG; 
            end            
            
            NSR_EWG: begin //North-South Red & East-West Green
                if(clk_count != zeroSec) begin 
                    next_state = NSR_EWG;
                    NS_light = red;
                    EW_light = green;
                end else  
                    next_state = NSR_EWY;              
            end 
            
            NSR_EWY: begin //North-South Red & East-West Yellow
                if(clk_count != zeroSec) begin 
                    next_state = NSR_EWY;
                    NS_light = red;
                    EW_light = yellow;
                end else 
                    next_state = NSG_EWR;         
            end 
            default: begin //North-South Green & East-West Red
                if(clk_count != zeroSec ) begin  
                    next_state = NSG_EWR;
                    NS_light = green;
                    EW_light = red;
                end else   
                    next_state = NSY_EWR;
            end 
        endcase 
    end 
    
    // state actions 
    always @(posedge clk) begin  
        case (state)                
             NSG_EWR, NSR_EWG: begin 
                if (clk_count != zeroSec)   
                    clk_count <= clk_count - 1'b1; //using downcounter for simplified logic
                else 
                    clk_count <= threeSec;                        
             end
                
             NSY_EWR, NSR_EWY: begin //North-South Yellow & East-West Red
                    if (clk_count != zeroSec) 
                        clk_count <= clk_count - 1'b1; //downcounter for simplified logic
                    else
                        clk_count <= tenSec;
                end             
                default: clk_count <= tenSec; //case of reset
            endcase  
     end
endmodule







`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 08:44:14 PM
// Design Name: 
// Module Name: improvedTrafficLight
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


module improvedTrafficLight(
    input clk, //clock dependencies
    input rst, //active low
    output reg [2:0] NS_light, //North-South light 
    output reg [2:0] EW_light,  //East-West light
    output reg [3:0] clk_count //used to verify timing 
    );
    
    //define states
    parameter
        NSR_EWR  =  3'b000, //North-South Red & East-West Red
        NSG_EWR  =  3'b001, //North-South Green & East-West Red
        NSY_EWR  =  3'b010, //North-South Yellow & East-West Red
        NSR_EWG  =  3'b011, //North-South Red & East-West Green
        NSR_EWY  =  3'b100, //North-South Red & East-West Yellow
        HOLD_RESET = 3'b101; //case to hold reset for one clock cycle 
    
    //define seconds parameter
    parameter 
        tenSec   =  4'b1010,
        twoSec   =  4'b0010,
        oneSec   =  4'b0001,
        zeroSec  =  4'b0000; 
    
    //define light colors use One-Hot Encoding
    parameter 
        red      =  3'b100,
        yellow   =  3'b010,
        green    =  3'b001; 
        
        //define state registers 
    reg [2:0] state, prev_state, cur_state, next_state;     
    
    //next state
    always @(posedge clk, negedge rst)begin
        if(~rst) begin 
            state <= 3'b000;
            prev_state <= HOLD_RESET; //case of reset to hold for one clock cycle
        end else begin 
            state <= next_state; 
            prev_state <= cur_state; 
        end 
    end
        
    //Create State-Machine
    always @(*) begin 
        case(state) 
            NSG_EWR: begin
                if(clk_count != zeroSec ) begin  
                    next_state = NSG_EWR;
                    NS_light = green;
                    EW_light = red;
                end else begin 
                    cur_state = NSG_EWR;
                    next_state = NSY_EWR;
                end 
            end 
            
            NSY_EWR: begin //North-South Yellow & East-West Red
                if(clk_count != zeroSec )begin 
                    next_state = NSY_EWR;
                    NS_light = yellow;
                    EW_light = red;
                end else begin   
                    cur_state = NSY_EWR;
                    next_state = NSR_EWR;
                end 
            end                       
            
            NSR_EWG: begin //North-South Red & East-West Green
                if(clk_count != zeroSec) begin 
                    next_state = NSR_EWG;
                    NS_light = red;
                    EW_light = green;
                end else begin 
                    cur_state = NSR_EWG; 
                    next_state = NSR_EWY; 
                end              
            end 
            
            NSR_EWY: begin //North-South Red & East-West Yellow
                if(clk_count != zeroSec) begin 
                    next_state = NSR_EWY;
                    NS_light = red;
                    EW_light = yellow;
                end else begin
                    cur_state = NSR_EWY; 
                    next_state = NSR_EWR;
                end         
            end 
            
            default:begin //NSR_EWR
                if (prev_state == HOLD_RESET) begin //holds reset for one clock cycle for safe reset
                    next_state = NSR_EWR;
                    NS_light = red;
                    EW_light = red;
                end else if(clk_count != zeroSec)begin 
                    next_state = NSR_EWR;
                    cur_state = prev_state;
                    NS_light = red;
                    EW_light = red;
                end else begin
                    if (prev_state == NSY_EWR)
                        next_state = NSR_EWG;
                    else 
                        next_state = NSG_EWR;
                end              
            end              
        endcase 
    end 
    
    
    // state actions 
    always @(posedge clk) begin         
        case (state)
            NSR_EWR: begin
                if(prev_state ==  HOLD_RESET) 
                    clk_count <= oneSec;
                else begin 
                    if (clk_count != zeroSec)
                        clk_count <= clk_count - 1'b1;
                     else 
                        clk_count <= tenSec;
                end 
            end    
                         
            NSG_EWR, NSR_EWG: begin 
                if (clk_count != zeroSec)   
                    clk_count <= clk_count - 1'b1; //using downcounter for simplified logic
                else 
                    clk_count <= twoSec;                        
            end 
            
            NSY_EWR, NSR_EWY: begin //North-South Yellow & East-West Red
                    if (clk_count != zeroSec) 
                        clk_count <= clk_count - 1'b1; //downcounter for simplified logic
                    else
                        clk_count <= oneSec;
             end    
                      
             default: clk_count <= oneSec; //case of reset
             
          endcase  
     end

endmodule

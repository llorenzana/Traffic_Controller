`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2023 11:57:40 PM
// Design Name: 
// Module Name: TrafficLightController
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


module TrafficLightController(
    input clk, //clock dependencies
    input rst, //active low
    input NS_sensor, //represents traffic at the North-South sensor
    input EW_sensor, //represents traffic at the East-West sensor
    output reg [2:0] NS_light, //North-South light 
    output reg [2:0] EW_light  //East-West light
    );
    
    //define states
    parameter
        NSR_EWR    =  3'b000, //North-South Red & East-West Red
        NSG_EWR    =  3'b001, //North-South Green & East-West Red
        NSY_EWR    =  3'b010, //North-South Yellow & East-West Red
        NSR_EWG    =  3'b011, //North-South Red & East-West Green
        NSR_EWY    =  3'b100, //North-South Red & East-West Yellow
        HOLD_RESET =  3'b101; //case to hold reset for one clock cycle 
    
    //define seconds parameter
    parameter 
        tenSec   =  4'b1010,
        fiveSec  =  4'b0101,
        twoSec   =  4'b0010,
        oneSec   =  4'b0001,
        zeroSec  =  4'b0000; 
    
    //define light colors use One-Hot Encoding
    parameter 
        red      =  3'b100,
        yellow   =  3'b010,
        green    =  3'b001; 
        
    //define state registers 
    reg [2:0] state, cur_state, prev_state, next_state;     
    
    // define clk_count for down counter
    reg [3:0] clk_count; 
    
    //next state transitions 
    always @(posedge clk, negedge rst)begin
        if(!rst) begin //active-low reset 
            state <= 3'b000;
            prev_state <= HOLD_RESET; //case of reset to hold for one clock cycle
        end else begin 
            state <= next_state; 
            prev_state <= cur_state; 
        end 
    end
        
    //Create Moore State Machine
    always @(*) begin 
        case(state) 
            NSG_EWR:           
                if(clk_count != zeroSec ) begin  //count down timer not reached 0
                    if ( !NS_sensor && EW_sensor && fiveSec >= clk_count ) begin //check car
                        cur_state = NSG_EWR;
                        next_state = NSY_EWR;
                    end else begin 
                        next_state = NSG_EWR;
                        NS_light = green;
                        EW_light = red;
                    end 
                end else begin 
                    cur_state = NSG_EWR;
                    next_state = NSY_EWR;
                end
              
            NSY_EWR:  //North-South Yellow & East-West Red
                if( clk_count != zeroSec ) begin 
                    next_state = NSY_EWR;
                    NS_light = yellow;
                    EW_light = red;
                end else begin   
                    cur_state = NSY_EWR;
                    next_state = NSR_EWR;
                end                            
            
            NSR_EWG:  //North-South Red & East-West Green
                if(clk_count != zeroSec) begin 
                    if (NS_sensor && !EW_sensor && fiveSec >= clk_count ) begin
                        cur_state = NSR_EWG;
                        next_state = NSR_EWY;
                    end else begin 
                        next_state = NSR_EWG;
                        NS_light = red;
                        EW_light = green;
                    end
                end else begin 
                    cur_state = NSR_EWG; 
                    next_state = NSR_EWY; 
                end              
            
            NSR_EWY:  //North-South Red & East-West Yellow
                if(clk_count != zeroSec) begin 
                    next_state = NSR_EWY;
                    NS_light = red;
                    EW_light = yellow;
                end else begin
                    cur_state = NSR_EWY; 
                    next_state = NSR_EWR;
                end          
            
            default: //NSR_EWR
                if (prev_state == HOLD_RESET) begin //holds reset for one clock cycle for safe reset
                    next_state = NSR_EWR;
                    cur_state = NSR_EWR;
                    NS_light = red;
                    EW_light = red;
                end else if (clk_count != zeroSec)begin 
                    next_state = NSR_EWR;
                    NS_light = red;
                    EW_light = red;
                end else 
                    next_state = (prev_state == NSY_EWR) ? NSR_EWG : NSG_EWR;
                          
        endcase //end case
    end //end always block
    
    
    // state actions  
    always @(posedge clk) begin         
        case (state)
            NSR_EWR: 
                clk_count <= (prev_state ==  HOLD_RESET) ? oneSec : (clk_count != zeroSec) ? (clk_count - 1'b1) : tenSec;   
                         
            NSG_EWR, NSR_EWG:  
                clk_count <= (clk_count != zeroSec) 
                    ?    
                        (( (!NS_sensor && EW_sensor && ( state == NSG_EWR) ) || 
                           (NS_sensor && !EW_sensor && ( state == NSR_EWG))) && 
                            fiveSec >= clk_count ) 
                    ? 
                        twoSec : (clk_count - 1'b1) //using downcounter for simplified logic
                    : clk_count <= twoSec;                         
            
            NSY_EWR, NSR_EWY:  //North-South Yellow & East-West Red
                clk_count <= (clk_count != zeroSec) ?  (clk_count - 1'b1) : oneSec; //downcounter for simplified logic
                      
             default: clk_count <= oneSec; //case of reset
             
          endcase  
     end
     
endmodule

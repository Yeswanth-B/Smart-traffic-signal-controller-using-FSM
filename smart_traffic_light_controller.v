`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2026 12:13:00
// Design Name: 
// Module Name: smart_traffic_light_controller
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


module smart_traffic_light_controller(
    input clk,
    input reset,

    // Feature Inputs
    input pedestrian,
    input emergency,
    input high_density,
    input night_mode,

    // Traffic Outputs
    output reg [2:0] highway,
    output reg [2:0] side,

    // Pedestrian Signal
    output reg ped_green,

    // Error Detection
    output reg error
);

    //==================================================
    // STATE DECLARATION
    //==================================================

    parameter S0 = 3'b000; // Highway Green
    parameter S1 = 3'b001; // Highway Yellow
    parameter S2 = 3'b010; // Side Green
    parameter S3 = 3'b011; // Side Yellow
    parameter S4 = 3'b100; // Pedestrian Crossing
    parameter S5 = 3'b101; // Emergency Mode

    reg [2:0] state, next_state;

    //==================================================
    // LIGHT ENCODING
    //==================================================

    parameter RED    = 3'b100;
    parameter YELLOW = 3'b010;
    parameter GREEN  = 3'b001;

    //==================================================
    // PARAMETERIZED TIMING
    //==================================================

    parameter GREEN_TIME   = 10;
    parameter YELLOW_TIME  = 3;
    parameter PED_TIME     = 5;
    parameter EMERGENCY_TIME = 7;

    reg [4:0] count;

    //==================================================
    // STATE REGISTER
    //==================================================

    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            state <= S0;
            count <= 0;
        end
        else
        begin
            // Dynamic timing based on state

            case(state)

                S0:
                begin
                    // Longer green for high density
                    if(high_density)
                    begin
                        if(count == GREEN_TIME + 5)
                        begin
                            state <= next_state;
                            count <= 0;
                        end
                        else
                            count <= count + 1;
                    end
                    else
                    begin
                        if(count == GREEN_TIME)
                        begin
                            state <= next_state;
                            count <= 0;
                        end
                        else
                            count <= count + 1;
                    end
                end

                S1, S3:
                begin
                    if(count == YELLOW_TIME)
                    begin
                        state <= next_state;
                        count <= 0;
                    end
                    else
                        count <= count + 1;
                end

                S4:
                begin
                    if(count == PED_TIME)
                    begin
                        state <= S0;
                        count <= 0;
                    end
                    else
                        count <= count + 1;
                end

                S5:
                begin
                    if(count == EMERGENCY_TIME)
                    begin
                        state <= S0;
                        count <= 0;
                    end
                    else
                        count <= count + 1;
                end

                default:
                begin
                    if(count == GREEN_TIME)
                    begin
                        state <= next_state;
                        count <= 0;
                    end
                    else
                        count <= count + 1;
                end

            endcase
        end
    end

    //==================================================
    // NEXT STATE LOGIC
    //==================================================

    always @(*)
    begin

        // Emergency has highest priority
        if(emergency)
            next_state = S5;

        // Pedestrian request
        else if(pedestrian)
            next_state = S4;

        else
        begin
            case(state)

                S0: next_state = S1;

                S1: next_state = S2;

                S2: next_state = S3;

                S3: next_state = S0;

                default: next_state = S0;

            endcase
        end
    end

    //==================================================
    // OUTPUT LOGIC
    //==================================================

    always @(*)
    begin

        // Default Outputs
        highway   = RED;
        side      = RED;
        ped_green = 0;
        error     = 0;

        // NIGHT MODE
        if(night_mode)
        begin
            highway = YELLOW;
            side    = YELLOW;
        end

        else
        begin
            case(state)

                // Highway Green
                S0:
                begin
                    highway = GREEN;
                    side    = RED;
                end

                // Highway Yellow
                S1:
                begin
                    highway = YELLOW;
                    side    = RED;
                end

                // Side Green
                S2:
                begin
                    highway = RED;
                    side    = GREEN;
                end

                // Side Yellow
                S3:
                begin
                    highway = RED;
                    side    = YELLOW;
                end

                // Pedestrian Crossing
                S4:
                begin
                    highway   = RED;
                    side      = RED;
                    ped_green = 1;
                end

                // Emergency Mode
                S5:
                begin
                    highway = GREEN;
                    side    = RED;
                end

                // Fault Recovery
                default:
                begin
                    highway = RED;
                    side    = RED;
                end

            endcase
        end

        //==================================================
        // FAULT DETECTION
        //==================================================

        if(highway == GREEN && side == GREEN)
            error = 1;

    end

endmodule

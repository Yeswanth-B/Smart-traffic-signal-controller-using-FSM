`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2026 12:14:17
// Design Name: 
// Module Name: smart_traffic_light_tb
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


module smart_traffic_light_tb;

    //==================================================
    // INPUTS
    //==================================================

    reg clk;
    reg reset;

    reg pedestrian;
    reg emergency;
    reg high_density;
    reg night_mode;

    //==================================================
    // OUTPUTS
    //==================================================

    wire [2:0] highway;
    wire [2:0] side;

    wire ped_green;
    wire error;

    //==================================================
    // DUT INSTANTIATION
    //==================================================

    smart_traffic_light_controller DUT (
        .clk(clk),
        .reset(reset),
        .pedestrian(pedestrian),
        .emergency(emergency),
        .high_density(high_density),
        .night_mode(night_mode),
        .highway(highway),
        .side(side),
        .ped_green(ped_green),
        .error(error)
    );

    //==================================================
    // CLOCK GENERATION
    //==================================================

    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==================================================
    // TEST SEQUENCE
    //==================================================

    initial
    begin

        // Initialize Inputs
        reset        = 1;
        pedestrian   = 0;
        emergency    = 0;
        high_density = 0;
        night_mode   = 0;

        // Apply Reset
        #20;
        reset = 0;

        //------------------------------------------------
        // NORMAL TRAFFIC OPERATION
        //------------------------------------------------
        #120;

        //------------------------------------------------
        // HIGH DENSITY MODE
        //------------------------------------------------
        high_density = 1;

        #120;

        high_density = 0;

        //------------------------------------------------
        // PEDESTRIAN REQUEST
        //------------------------------------------------
        pedestrian = 1;

        #20;

        pedestrian = 0;

        #100;

        //------------------------------------------------
        // EMERGENCY VEHICLE
        //------------------------------------------------
        emergency = 1;

        #40;

        emergency = 0;

        #100;

        //------------------------------------------------
        // NIGHT MODE
        //------------------------------------------------
        night_mode = 1;

        #80;

        night_mode = 0;

        #100;

        //------------------------------------------------
        // END SIMULATION
        //------------------------------------------------
        $finish;

    end

    //==================================================
    // MONITOR OUTPUTS
    //==================================================

    initial
    begin

        $display("==============================================================");
        $display("TIME\tRESET\tPED\tEMG\tHD\tNIGHT\tHIGHWAY\tSIDE\tPED_GREEN\tERROR");
        $display("==============================================================");

        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t\t%b",
                 $time,
                 reset,
                 pedestrian,
                 emergency,
                 high_density,
                 night_mode,
                 highway,
                 side,
                 ped_green,
                 error);

    end

endmodule
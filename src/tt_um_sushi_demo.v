/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */


module tt_um_sushi_demo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  //  |-----------H_DISPLAY-----------|-----H_FRONT-----|-----H_SYNC-----|-----H_BACK-----|

    // horizontal constants
    parameter H_DISPLAY       = 640; // horizontal display width
    parameter H_BACK          =  48; // horizontal left border (back porch)
    parameter H_FRONT         =  16; // horizontal right border (front porch)
    parameter H_SYNC          =  96; // horizontal sync width
    // vertical constants
    parameter V_DISPLAY       = 480; // vertical display height
    parameter V_TOP           =  33; // vertical top border
    parameter V_BOTTOM        =  10; // vertical bottom border
    parameter V_SYNC          =   2; // vertical sync # lines
    // derived constants
    parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
    parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC - 1;
    parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
    parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
    parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
    parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;
    //frame
    parameter FRAME_PERIOD      = 10; //5 bit - 2^4 = 32 max
    //sprite position
    parameter SPRITE_X = 100;
    parameter SPRITE_Y = 100;
    parameter SPRITE_WIDTH = 100;
    parameter SPRITE_HEIGHT = 100;




  //unused outputs
  assign uio_out = 0;
  assign uio_oe  = 0; 



  //vga signals
  reg h_sync;
  reg v_sync;
  reg [1:0] r;
  reg [1:0] g;
  reg [1:0] b;

  reg display_on;
  reg [9:0] pix_x;
  reg [9:0] pix_y;


  
  assign uo_out = {h_sync, b[0], g[0], r[0], v_sync, b[1], g[1], r[1]};

  


  //hvsync gen
  always @(posedge clk) begin
        
        if (!rst_n) begin
            pix_x        <= 0;
            pix_y        <= 0;
            h_sync       <= 1;
            v_sync       <= 1;
        end
        else begin
            pix_x        <= (pix_x >= H_MAX) ? 0: pix_x + 1;
            pix_y        <= (pix_y >= V_MAX) ? 0: pix_y + 1;
            h_sync       <= (pix_x >= H_SYNC_START) && (pix_x <= H_SYNC_END);
            v_sync       <= (pix_y >= V_SYNC_START) && (pix_y <= V_SYNC_END);;
        end
    end

    assign display_on = (pix_x<H_DISPLAY) && (pix_y<V_DISPLAY);



  //counter
  reg [4:0] counter;

  always @(posedge v_sync) begin
    if(!rst_n) begin
      counter <= 0;
    end
    else begin
      counter <= counter + 1;
    end
  end

  //pixel output
  always @(posedge clk) begin
    if(pix_x >= SPRITE_X && 
       pix_x < SPRITE_X + SPRITE_WIDTH &&
       pix_y >= SPRITE_Y && 
       pix_y < SPRITE_Y + SPRITE_HEIGHT) begin
        r <= counter == 5'b11111 ? 2'b11 : 2'b00;
        g <= counter == 5'b11111 ? 2'b11 : 2'b00;
        b <= counter == 5'b11111 ? 2'b11 : 2'b00;
       end
  end

  
  





endmodule





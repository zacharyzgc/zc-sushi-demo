
module hvsync_gen(
                  input wire        clk,
                  input wire        nRst,
                  output reg       h_sync, v_sync, //active low
                  output wire       display_on,
                  output reg [9:0] h_pos, 
                  output reg [9:0] v_pos 
                  );



    // VGA Signal 640 x 480 @ 60 Hz Industry standard timing


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


    always @(posedge clk) begin
        
        if (!nRst) begin
            h_pos        <= 0;
            v_pos        <= 0;
            h_sync       <= 1;
            v_sync       <= 1;
        end
        else begin
            h_pos        <= (h_pos >= H_MAX) ? 0: h_pos + 1;
            v_pos        <= (v_pos >= V_MAX) ? 0: v_pos + 1;
            h_sync       <= (h_pos >= H_SYNC_START) && (h_pos <= H_SYNC_END);
            v_sync       <= (v_pos >= V_SYNC_START) && (v_pos <= V_SYNC_END);;
        end
    end

    assign display_on = (h_pos<H_DISPLAY) && (v_pos<V_DISPLAY);


endmodule
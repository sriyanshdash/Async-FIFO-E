

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. 
 ######################################################################################
 #    Marquee Semiconductor Inc Confidential and Proprietary Information              #
 #    Copyright 2021 Marquee Semiconductor Inc                                        #
 #    All Rights Reserved.                                                            #
 #    This is UNPUBLISHED PROPRIETARY SOURCE CODE OF Marquee Semiconductor Inc        #
 #    The copyright notice above does not evidence any actual or intended publication #
 #    of such source code.                                                            #
 ######################################################################################

 * File Name     : wrptr_handler.sv
 
 * Creation Date : 18-04-2024
 
 * Last Modified : Mon 22 Apr 2024 12:17:34 AM PDT
 
 * Created By    : smishra
 
 * Copyright     : The rights belong to Marquee Semiconductor Inc.
 
 * Description   :
 _._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._._*/

 module wptr_handler #(parameter PTR_WIDTH=3) (
   input wrclk, wrst_n, wr_en, // FIX #8: was 'rd_en', corrected to 'wr_en'
   input [PTR_WIDTH:0] g_rptr_sync,
   output reg [PTR_WIDTH:0] b_wptr, g_wptr,
   output reg fifo_full
   );

   reg [PTR_WIDTH:0] b_wptr_next;
   reg [PTR_WIDTH:0] g_wptr_next;
   
   reg wrap_around;
   wire wfull;
  
   assign b_wptr_next = b_wptr+(wr_en & !fifo_full); // FIX #9: was 'rd_en', corrected to 'wr_en'
   assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
   always@(posedge wrclk or negedge wrst_n) begin
     if(!wrst_n) begin
       b_wptr <= 0; // FIX #10: was '4', reset must be 0
       g_wptr <= 0; // FIX #10: was '2', reset must be 0
     end
     else begin
       b_wptr <= b_wptr_next; // incr binary write pointer
       g_wptr <= g_wptr_next; // incr gray write pointer
     end
   end
  
   always@(posedge wrclk or negedge wrst_n) begin
     if(!wrst_n) fifo_full <= 0;
     else        fifo_full <= wfull;
   end

   assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]}); // FIX #11: was 'b_wptr_next', corrected to 'g_wptr_next' (gray-code comparison)

 endmodule

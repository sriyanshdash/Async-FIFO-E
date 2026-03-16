// =============================================================================
// File        : test_overflow_underflow.sv
// Description : TEST 6 - OVERFLOW AND UNDERFLOW PROTECTION
//               Covers: test_overflow_underflow, test_write_when_full_data_check,
//                       test_read_when_empty_pointer_check, test_back_to_back_overflow,
//                       test_back_to_back_underflow
// =============================================================================

`ifndef TEST_OVERFLOW_UNDERFLOW_SV
`define TEST_OVERFLOW_UNDERFLOW_SV

`timescale 1ns/1ps

class test_overflow_underflow #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Single overflow — write when full (should be ignored)
        $display("\n  --- Part A: Single overflow attempt ---");
        write_n(FIFO_DEPTH);
        wait_drain();
        check_flag("fifo_full before overflow", vif.fifo_full, 1);
        // Force a write directly on VIF while full
        @(posedge vif.wrclk); #1;
        vif.wr_en   = 1;
        vif.data_in = 64'hBADD_A1A0_0000_0001;
        @(posedge vif.wrclk); #1;
        vif.wr_en   = 0;
        vif.data_in = '0;
        // Read back — should get original data only
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part B: 10 back-to-back overflow attempts
        $display("  --- Part B: 10 back-to-back overflow writes ---");
        write_n(FIFO_DEPTH);
        wait_drain();
        for (int i = 0; i < 10; i++) begin
            @(posedge vif.wrclk); #1;
            vif.wr_en   = 1;
            vif.data_in = {32'hDEAD_0000 + i[31:0], 32'h0};
            @(posedge vif.wrclk); #1;
            vif.wr_en   = 0;
        end
        vif.data_in = '0;
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part C: Single underflow — read when empty (should be ignored)
        $display("  --- Part C: Single underflow attempt ---");
        check_flag("fifo_empty before underflow", vif.fifo_empty, 1);
        @(posedge vif.rdclk); #1;
        vif.rd_en = 1;
        @(posedge vif.rdclk); #1;
        vif.rd_en = 0;
        repeat (10) @(posedge vif.rdclk);
        // Verify FIFO still works normally
        write_n(1);
        read_n(1);
        wait_drain();

        // Part D: 10 back-to-back underflow attempts
        $display("  --- Part D: 10 back-to-back underflow reads ---");
        for (int i = 0; i < 10; i++) begin
            @(posedge vif.rdclk); #1;
            vif.rd_en = 1;
            @(posedge vif.rdclk); #1;
            vif.rd_en = 0;
        end
        repeat (10) @(posedge vif.rdclk);
        // Verify pointer integrity
        write_n(1);
        read_n(1);
        wait_drain();
    endtask
endclass : test_overflow_underflow

`endif

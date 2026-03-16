// =============================================================================
// File        : test_basic_rw.sv
// Description : TEST 1 - BASIC READ/WRITE
//               Covers: test_basic, test_single_entry, test_alternating_rw
// =============================================================================

`ifndef TEST_BASIC_RW_SV
`define TEST_BASIC_RW_SV

`timescale 1ns/1ps

class test_basic_rw #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Write several random values, then read them all back
        $display("\n  --- Part A: Write %0d random values, read all back ---", FIFO_DEPTH);
        write_n(FIFO_DEPTH);
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part B: Single entry — smallest possible FIFO usage
        $display("  --- Part B: Single entry write and read ---");
        write_data(64'hDEAD_BEEF_CAFE_BABE);
        read_n(1);
        wait_drain();

        // Part C: Alternating write-read pattern (20 pairs)
        $display("  --- Part C: Alternating write-read (20 pairs) ---");
        for (int i = 0; i < 20; i++) begin
            write_n(1);
            read_n(1);
            wait_drain();
        end
    endtask
endclass : test_basic_rw

`endif

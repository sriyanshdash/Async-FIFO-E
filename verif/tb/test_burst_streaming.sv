// =============================================================================
// File        : test_burst_streaming.sv
// Description : TEST 3 - BURST AND STREAMING
//               Covers: test_burst_write_burst_read, test_continuous_streaming,
//                       test_simultaneous_rw
// =============================================================================

`ifndef TEST_BURST_STREAMING_SV
`define TEST_BURST_STREAMING_SV

`timescale 1ns/1ps

class test_burst_streaming #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Burst write all at once, then burst read all at once
        $display("\n  --- Part A: Burst write %0d, then burst read ---", FIFO_DEPTH);
        write_n(FIFO_DEPTH);
        wait_drain();
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part B: Simultaneous reads and writes across clock domains
        // Half-fill first so reads don't stall immediately
        $display("  --- Part B: Simultaneous writes and reads ---");
        write_n(FIFO_DEPTH / 2);
        wait_drain();
        fork
            write_n(20);
            read_n(20 + FIFO_DEPTH / 2);
        join
        wait_drain();

        // Part C: High-throughput continuous streaming (100 transactions)
        $display("  --- Part C: Continuous streaming (100 writes, 100 reads) ---");
        write_n(FIFO_DEPTH / 2);
        wait_drain();
        fork
            write_n(100);
            read_n(100 + FIFO_DEPTH / 2);
        join
        wait_drain();
    endtask
endclass : test_burst_streaming

`endif

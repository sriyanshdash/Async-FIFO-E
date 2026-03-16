// =============================================================================
// File        : test_fill_drain_wrap.sv
// Description : TEST 2 - FILL, DRAIN, AND POINTER WRAP-AROUND
//               Covers: test_fill_drain, test_pointer_wrap, test_fifo_depth_boundary
// =============================================================================

`ifndef TEST_FILL_DRAIN_WRAP_SV
`define TEST_FILL_DRAIN_WRAP_SV

`timescale 1ns/1ps

class test_fill_drain_wrap #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Fill to capacity, verify full, drain, verify empty
        $display("\n  --- Part A: Fill to full, drain to empty ---");
        write_n(FIFO_DEPTH);
        wait_drain();
        check_flag("fifo_full", vif.fifo_full, 1);
        read_n(FIFO_DEPTH);
        wait_drain();
        check_flag("fifo_empty", vif.fifo_empty, 1);

        // Part B: Do fill-drain 3 times to exercise pointer wrap-around
        // Gray code pointers wrap at 2*DEPTH — this catches wrap bugs
        $display("  --- Part B: 3x fill-drain cycles (pointer wrap) ---");
        for (int i = 0; i < 3; i++) begin
            $display("    Cycle %0d", i);
            write_n(FIFO_DEPTH);
            read_n(FIFO_DEPTH);
            wait_drain();
        end

        // Part C: Interleaved operations at the depth boundary
        // Write DEPTH-1, read 1, write 2 (reaching full), drain rest
        $display("  --- Part C: Depth boundary interleave ---");
        write_n(FIFO_DEPTH - 1);
        read_n(1);
        wait_drain();
        write_n(2);
        wait_drain();
        check_flag("fifo_full", vif.fifo_full, 1);
        read_n(FIFO_DEPTH);
        wait_drain();
    endtask
endclass : test_fill_drain_wrap

`endif

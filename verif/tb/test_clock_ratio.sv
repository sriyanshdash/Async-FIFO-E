// =============================================================================
// File        : test_clock_ratio.sv
// Description : TEST 8 - CLOCK RATIO
//               Covers: test_clock_ratio (3 frequency scenarios)
// =============================================================================

`ifndef TEST_CLOCK_RATIO_SV
`define TEST_CLOCK_RATIO_SV

`timescale 1ns/1ps

class test_clock_ratio #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Fast write (200 MHz) / Slow read (50 MHz) — 4:1 ratio
        $display("\n  --- Part A: Fast write (200 MHz) / Slow read (50 MHz) ---");
        fifo_tb_top.wrclk_half = 2.5;    // 200 MHz
        fifo_tb_top.rdclk_half = 10.0;   // 50 MHz
        repeat (5) @(posedge vif.wrclk);
        reset_phase();
        write_n(FIFO_DEPTH);
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part B: Slow write (50 MHz) / Fast read (200 MHz) — 1:4 ratio
        $display("  --- Part B: Slow write (50 MHz) / Fast read (200 MHz) ---");
        fifo_tb_top.wrclk_half = 10.0;   // 50 MHz
        fifo_tb_top.rdclk_half = 2.5;    // 200 MHz
        repeat (5) @(posedge vif.wrclk);
        reset_phase();
        write_n(FIFO_DEPTH);
        read_n(FIFO_DEPTH);
        wait_drain();

        // Part C: Same frequency (100 MHz both)
        $display("  --- Part C: Same frequency (100 MHz both) ---");
        fifo_tb_top.wrclk_half = 5.0;
        fifo_tb_top.rdclk_half = 5.0;
        repeat (5) @(posedge vif.wrclk);
        reset_phase();
        write_n(FIFO_DEPTH);
        read_n(FIFO_DEPTH);
        wait_drain();

        // Restore defaults
        fifo_tb_top.wrclk_half = 5.0;
        fifo_tb_top.rdclk_half = 6.5;
        repeat (5) @(posedge vif.wrclk);
    endtask
endclass : test_clock_ratio

`endif

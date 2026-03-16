// =============================================================================
// File        : test_reset_scenarios.sv
// Description : TEST 7 - RESET SCENARIOS
//               Covers: test_reset, test_reset_when_empty, test_reset_when_full,
//                       test_reset_during_write, test_reset_during_read,
//                       test_reset_partial_fill, test_simultaneous_reset_write,
//                       test_simultaneous_reset_read
// =============================================================================

`ifndef TEST_RESET_SCENARIOS_SV
`define TEST_RESET_SCENARIOS_SV

`timescale 1ns/1ps

class test_reset_scenarios #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Reset when empty — should stay empty
        $display("\n  --- Part A: Reset when empty ---");
        check_flag("fifo_empty before reset", vif.fifo_empty, 1);
        reset_phase();
        check_flag("fifo_empty after reset", vif.fifo_empty, 1);
        check_flag("fifo_full after reset", vif.fifo_full, 0);
        // Verify recovery
        write_n(1);
        read_n(1);
        wait_drain();

        // Part B: Reset when full — should clear everything
        $display("  --- Part B: Reset when full ---");
        write_n(FIFO_DEPTH);
        wait_drain();
        check_flag("fifo_full before reset", vif.fifo_full, 1);
        reset_phase();
        check_flag("fifo_empty after full-reset", vif.fifo_empty, 1);
        check_flag("fifo_full after full-reset", vif.fifo_full, 0);
        // Write new data and read back to confirm old data is gone
        write_data(64'hF0E5_0000_0000_0001);
        read_n(1);
        wait_drain();

        // Part C: Reset when partially filled
        $display("  --- Part C: Reset when partially filled ---");
        write_n(FIFO_DEPTH / 2);
        wait_drain();
        reset_phase();
        check_flag("fifo_empty after partial-reset", vif.fifo_empty, 1);
        write_n(1);
        read_n(1);
        wait_drain();

        // Part D: Reset while wr_en is active
        $display("  --- Part D: Reset during active write ---");
        @(posedge vif.wrclk); #1;
        vif.wr_en   = 1;
        vif.data_in = 64'hD01C_0000_0000_0001;
        // Slam reset
        vif.wrst_n  = 0;
        vif.rrst_n  = 0;
        vif.wr_en   = 0;
        vif.data_in = '0;
        repeat (5) @(posedge vif.wrclk);
        @(posedge vif.wrclk); #1;
        vif.wrst_n  = 1;
        vif.rrst_n  = 1;
        @(posedge vif.wrclk); #1;
        env.reset();
        check_flag("fifo_empty after wr-during-reset", vif.fifo_empty, 1);
        write_n(1);
        read_n(1);
        wait_drain();

        // Part E: Reset while rd_en is active
        $display("  --- Part E: Reset during active read ---");
        write_n(4);
        wait_drain();
        @(posedge vif.rdclk); #1;
        vif.rd_en   = 1;
        vif.wrst_n  = 0;
        vif.rrst_n  = 0;
        vif.rd_en   = 0;
        repeat (5) @(posedge vif.wrclk);
        @(posedge vif.wrclk); #1;
        vif.wrst_n  = 1;
        vif.rrst_n  = 1;
        @(posedge vif.wrclk); #1;
        env.reset();
        check_flag("fifo_empty after rd-during-reset", vif.fifo_empty, 1);
        write_n(1);
        read_n(1);
        wait_drain();

        // Part F: Simultaneous reset + wr_en (reset should win)
        $display("  --- Part F: Simultaneous reset + write ---");
        vif.wrst_n  = 0;
        vif.rrst_n  = 0;
        vif.wr_en   = 1;
        vif.data_in = 64'h5100_0000_0000_0001;
        repeat (5) @(posedge vif.wrclk);
        vif.wr_en   = 0;
        vif.data_in = '0;
        @(posedge vif.wrclk); #1;
        vif.wrst_n  = 1;
        vif.rrst_n  = 1;
        @(posedge vif.wrclk); #1;
        env.reset();
        check_flag("fifo_empty after simul wr+reset", vif.fifo_empty, 1);
        write_n(1);
        read_n(1);
        wait_drain();

        // Part G: Simultaneous reset + rd_en (reset should win)
        $display("  --- Part G: Simultaneous reset + read ---");
        write_n(4);
        wait_drain();
        vif.wrst_n  = 0;
        vif.rrst_n  = 0;
        vif.rd_en   = 1;
        repeat (5) @(posedge vif.wrclk);
        vif.rd_en   = 0;
        @(posedge vif.wrclk); #1;
        vif.wrst_n  = 1;
        vif.rrst_n  = 1;
        @(posedge vif.wrclk); #1;
        env.reset();
        check_flag("fifo_empty after simul rd+reset", vif.fifo_empty, 1);
        write_n(1);
        read_n(1);
        wait_drain();
    endtask
endclass : test_reset_scenarios

`endif

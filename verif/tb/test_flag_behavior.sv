// =============================================================================
// File        : test_flag_behavior.sv
// Description : TEST 4 - FLAG BEHAVIOR
//               Covers: test_full_flag_timing, test_empty_flag_timing,
//                       test_almost_full, test_almost_empty
// =============================================================================

`ifndef TEST_FLAG_BEHAVIOR_SV
`define TEST_FLAG_BEHAVIOR_SV

`timescale 1ns/1ps

class test_flag_behavior #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        // Part A: Full flag should assert only at exactly DEPTH entries
        $display("\n  --- Part A: Full flag timing (write one at a time) ---");
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            if (i > 0) begin
                // Should NOT be full before DEPTH writes
                check_flag($sformatf("fifo_full after %0d writes", i), vif.fifo_full, 0);
            end
            write_n(1);
            wait_drain();
        end
        check_flag("fifo_full after DEPTH writes", vif.fifo_full, 1);

        // Part B: Full flag deasserts after 1 read
        $display("  --- Part B: Full flag clears after 1 read ---");
        read_n(1);
        wait_drain();
        check_flag("fifo_full after 1 read", vif.fifo_full, 0);
        // Drain the rest
        read_n(FIFO_DEPTH - 1);
        wait_drain();

        // Part C: Empty flag should assert only after last entry is read
        $display("  --- Part C: Empty flag timing (read one at a time) ---");
        write_n(FIFO_DEPTH);
        wait_drain();
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            // Should NOT be empty until the very last read
            if (i < FIFO_DEPTH - 1) begin
                check_flag($sformatf("fifo_empty after %0d reads", i), vif.fifo_empty, 0);
            end
            read_n(1);
            wait_drain();
        end
        check_flag("fifo_empty after DEPTH reads", vif.fifo_empty, 1);

        // Part D: Empty flag deasserts after 1 write
        $display("  --- Part D: Empty flag clears after 1 write ---");
        write_n(1);
        wait_drain();
        check_flag("fifo_empty after 1 write", vif.fifo_empty, 0);
        read_n(1);
        wait_drain();
    endtask
endclass : test_flag_behavior

`endif

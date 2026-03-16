// =============================================================================
// File        : fifo_test_base.sv
// Description : Base test class with helper tasks shared by all FIFO tests.
//
//               Provides: write_n(), read_n(), write_data(), wait_drain(),
//                         reset_dut(), reset_phase(), check_flag().
// =============================================================================

`ifndef FIFO_TEST_BASE_SV
`define FIFO_TEST_BASE_SV

`timescale 1ns/1ps

class fifo_test_base #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8);

    fifo_env #(FIFO_WIDTH) env;
    virtual fifo_if #(FIFO_WIDTH) vif;

    function new();
    endfunction

    // Call this right after new() to set handles
    function void init(virtual fifo_if #(FIFO_WIDTH) vif, fifo_env #(FIFO_WIDTH) env);
        this.vif = vif;
        this.env = env;
    endfunction

    // Override this in each test
    virtual task run();
        $fatal(1, "run() not overridden!");
    endtask

    // --- Queue N writes with random data ---
    task write_n(int n);
        fifo_transaction #(FIFO_WIDTH) txn;
        repeat (n) begin
            txn = new();
            if (!txn.randomize() with { wr_en == 1; rd_en == 0; })
                $fatal(1, "Randomize failed");
            txn.txn_type = FIFO_WRITE;
            env.wr_mbx.put(txn);
        end
    endtask

    // --- Queue N reads ---
    task read_n(int n);
        fifo_transaction #(FIFO_WIDTH) txn;
        repeat (n) begin
            txn          = new();
            txn.wr_en    = 0;
            txn.rd_en    = 1;
            txn.txn_type = FIFO_READ;
            env.rd_mbx.put(txn);
        end
    endtask

    // --- Queue a write with a specific data value ---
    task write_data(bit [FIFO_WIDTH-1:0] data);
        fifo_transaction #(FIFO_WIDTH) txn;
        txn          = new();
        txn.wr_en    = 1;
        txn.rd_en    = 0;
        txn.data     = data;
        txn.txn_type = FIFO_WRITE;
        env.wr_mbx.put(txn);
    endtask

    // --- Wait for all queued transactions to complete ---
    // Uses fork-join to avoid killing env threads with disable fork.
    task wait_drain(int timeout_ns = 5000);
        fork begin
            fork
                begin
                    wait (env.wr_mbx.num() == 0 && env.rd_mbx.num() == 0);
                    // Extra settling for monitor pipeline + CDC latency
                    repeat (20) @(posedge vif.wrclk);
                    repeat (20) @(posedge vif.rdclk);
                end
                begin
                    #(timeout_ns * 1ns);
                    $display("[WARN] wait_drain timed out after %0d ns", timeout_ns);
                end
            join_any
            disable fork;
        end join
    endtask

    // --- Assert reset, hold 5 cycles, deassert ---
    task reset_dut();
        vif.wr_en   = 0;
        vif.rd_en   = 0;
        vif.data_in = '0;
        vif.wrst_n  = 0;
        vif.rrst_n  = 0;
        repeat (5) @(posedge vif.wrclk);
        @(posedge vif.wrclk); #1;
        vif.wrst_n  = 1;
        vif.rrst_n  = 1;
        @(posedge vif.wrclk); #1;
    endtask

    // --- Reset DUT + clear env state (call between tests) ---
    // Uses the driver's flush flag to discard any in-flight transactions
    // that are stuck waiting on fifo_full/fifo_empty.
    task reset_phase();
        // Tell driver to discard any in-flight work
        env.drv.flush = 1;
        // Wait for driver threads to notice the flush flag
        repeat (3) @(posedge vif.wrclk);
        repeat (3) @(posedge vif.rdclk);
        // Drain all mailboxes and reset scoreboard
        env.reset();
        // Clear flush so driver accepts new work
        env.drv.flush = 0;
        // Now reset the DUT
        reset_dut();
        // Final cleanup of any stale monitor captures during reset
        env.reset();
    endtask

    // --- Check a flag value and report ---
    task check_flag(string name, logic actual, logic expected);
        if (actual !== expected) begin
            $display("  [FLAG] FAIL: %s = %0b, expected %0b @ %0t", name, actual, expected, $time);
            env.scb.fail_count++;
        end else begin
            $display("  [FLAG] OK:   %s = %0b @ %0t", name, actual, $time);
        end
    endtask

endclass : fifo_test_base

`endif

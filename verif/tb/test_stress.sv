// =============================================================================
// File        : test_stress.sv
// Description : TEST 9 - STRESS TEST
//               Covers: randomized heavy traffic with mixed operations
// =============================================================================

`ifndef TEST_STRESS_SV
`define TEST_STRESS_SV

`timescale 1ns/1ps

class test_stress #(parameter FIFO_WIDTH = 64, parameter FIFO_DEPTH = 8)
    extends fifo_test_base #(FIFO_WIDTH, FIFO_DEPTH);

    function new();
    endfunction

    task run();
        int scenario;
        int num_scenarios = 10;

        $display("\n  --- Running %0d random stress scenarios ---", num_scenarios);

        for (int s = 0; s < num_scenarios; s++) begin
            scenario = $urandom_range(0, 4);
            $display("    Scenario %0d: type=%0d", s, scenario);

            case (scenario)
                0: begin  // Fill and drain
                    write_n(FIFO_DEPTH);
                    read_n(FIFO_DEPTH);
                    wait_drain();
                end

                1: begin  // Concurrent traffic
                    write_n(FIFO_DEPTH / 2);
                    wait_drain();
                    fork
                        write_n(FIFO_DEPTH);
                        read_n(FIFO_DEPTH + FIFO_DEPTH / 2);
                    join
                    wait_drain();
                end

                2: begin  // Alternating single ops
                    for (int i = 0; i < FIFO_DEPTH; i++) begin
                        write_n(1);
                        read_n(1);
                        wait_drain();
                    end
                end

                3: begin  // Burst write then read
                    write_n(FIFO_DEPTH);
                    wait_drain();
                    read_n(FIFO_DEPTH);
                    wait_drain();
                end

                4: begin  // Overflow attempt then drain
                    write_n(FIFO_DEPTH);
                    wait_drain();
                    // Overflow write (ignored by DUT)
                    @(posedge vif.wrclk); #1;
                    vif.wr_en   = 1;
                    vif.data_in = 64'h5700_5500_00E0_F100;
                    @(posedge vif.wrclk); #1;
                    vif.wr_en   = 0;
                    vif.data_in = '0;
                    read_n(FIFO_DEPTH);
                    wait_drain();
                end
            endcase
        end
    endtask
endclass : test_stress

`endif

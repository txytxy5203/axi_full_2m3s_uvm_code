# AXI Full 2M3S UVM Code Project

This is a teaching-oriented AXI4-Full-style UVM project for QuestaSim.

Project learning site: **www.bcbaoic.top**

## Scope

- RTL DUT: `rtl/axi_2m3s_full_dut.v`
- 2 AXI master-facing ports: M0 and M1
- 3 internal RAM slave regions: S0/S1/S2
- 32-bit address, 32-bit data, 4-bit ID
- INCR bursts: 1/2/4/8/16 beats
- Multiple outstanding requests through fixed-depth slots
- Out-of-order responses across different IDs through different slave latencies
- WSTRB partial write support
- DECERR for invalid address or burst crossing slave boundary
- UVM scoreboard with reference memory model
- Functional coverage collector

## Code structure updates

- Each testcase is now in a separate `.sv` file under `tb/tests/`.
- Source files have English header comments for teaching/project documentation.
- `run.do` now saves the Questa transcript log under `logs/`.

## Run smoke test

In Questa Transcript:

```tcl
do run.do
```

Default test:

```text
axi_smoke_single_rw_test
```

Run another test:

```tcl
set TESTNAME axi_outstanding_read_test
do run.do
```

After simulation, check:

```text
logs/<TESTNAME>.log
```

## Run all tests

```tcl
do run_all.do
```

Each testcase will generate its own transcript log in `logs/`.

## Test list

1. `axi_smoke_single_rw_test`
2. `axi_all_path_basic_test`
3. `axi_burst_len_sweep_test`
4. `axi_burst_data_integrity_test`
5. `axi_write_strobe_test`
6. `axi_multi_master_same_slave_test`
7. `axi_multi_master_diff_slave_test`
8. `axi_outstanding_write_test`
9. `axi_outstanding_read_test`
10. `axi_out_of_order_read_test`
11. `axi_out_of_order_write_resp_test`
12. `axi_downstream_backpressure_test`
13. `axi_master_backpressure_test`
14. `axi_deadlock_stress_test`
15. `axi_error_boundary_test`

## Notes

This project is intentionally a teaching RTL and UVM framework, not a commercial AXI VIP.
It focuses on the interview-worthy topics: burst, outstanding, out-of-order response, scoreboard matching, coverage, backpressure and deadlock stress.

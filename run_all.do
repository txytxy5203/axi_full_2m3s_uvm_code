#-------------------------------------------------------------------------------
# File        : run_all.do
# Project     : AXI4 Full 2M3S UVM Teaching Project
# Purpose     : Run all 15 teaching tests and save one log file per testcase.
# Learn More  : www.bcbaoic.top
#-------------------------------------------------------------------------------

# set TESTLIST {
#     axi_smoke_single_rw_test
#     axi_all_path_basic_test
#     axi_burst_len_sweep_test
#     axi_burst_data_integrity_test
#     axi_write_strobe_test
#     axi_multi_master_same_slave_test
#     axi_multi_master_diff_slave_test
#     axi_outstanding_write_test
#     axi_outstanding_read_test
#     axi_out_of_order_read_test
#     axi_out_of_order_write_resp_test
#     axi_downstream_backpressure_test
#     axi_master_backpressure_test
#     axi_deadlock_stress_test
#     axi_error_boundary_test
# }
# 
# foreach t $TESTLIST {
#     echo "============================================================"
#     echo "Running $t"
#     echo "============================================================"
#     set TESTNAME $t
#     do run.do
# }


echo "AAA"

do run.do

echo "BBB"

do run.do

echo "CCC"


#!/bin/bash


TESTLIST=(
axi_smoke_single_rw_test
axi_all_path_basic_test
axi_burst_len_sweep_test
axi_burst_data_integrity_test
axi_write_strobe_test
axi_multi_master_same_slave_test
axi_multi_master_diff_slave_test
axi_outstanding_write_test
axi_outstanding_read_test
axi_out_of_order_read_test
axi_out_of_order_write_resp_test
axi_downstream_backpressure_test
axi_master_backpressure_test
axi_deadlock_stress_test
axi_error_boundary_test
)

mkdir -p logs
for TESTNAME in "${TESTLIST[@]}"
do

    echo "============================================================"
    echo "Running TEST = $TESTNAME"
    echo "============================================================"


    vsim \
    -onfinish stop \
    -batch \
    -l logs/${TESTNAME}.log \
    -do "set TESTNAME $TESTNAME; source run.do"


    if [ $? -ne 0 ]
    then
        echo "ERROR: $TESTNAME failed"
    else
        echo "PASS: $TESTNAME finished"
    fi


done


echo "============================================================"
echo "ALL TESTS DONE"
echo "============================================================"
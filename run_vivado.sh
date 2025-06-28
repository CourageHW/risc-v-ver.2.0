#!/bin/zsh
clear

echo "============================================"
echo "| Starting Vivado Simulation in Batch Mode |"
echo "============================================"

if [ "$1" = "-gui" ]; then
    echo "INFO: GUI mode requested. Waveform viewer will open after simulation."
    # Vivado를 실행하며, Tcl 스크립트에 'gui'라는 인자를 전달합니다.
    vivado -mode batch -notrace -nojournal -nolog -source simulate.tcl -tclargs gui
else
    # 인자가 없으면, 기존처럼 GUI 없이 순수하게 실행합니다.
    echo "INFO: Batch mode only. No GUI will be launched."
    vivado -mode batch -notrace -nojournal -nolog -source simulate.tcl
fi

echo "\n=========================================="
echo "|       Vivado Simulation Finished       |"
echo "=========================================="


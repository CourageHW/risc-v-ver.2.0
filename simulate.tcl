# ===================================================================
# Vivado Batch Simulation Script (Ultra-Robust Disk-Based Version)
# ===================================================================
# This version creates a temporary project on disk to ensure
# compatibility with all Vivado simulation commands.
# --- 1. Project Setup ---
# Define the temporary project directory and name.
set PROJ_DIR "./vivado_sim_project"
set PROJ_NAME "riscv_simulation"

# The -force flag will overwrite the project if it already exists.
create_project ${PROJ_NAME} ${PROJ_DIR} -part xc7z020clg400-1 -force


# --- 2. Add Source Files ---
# Add all necessary source files using relative paths from the project root.
add_files -fileset sim_1 [list \
    ./src/header/defines.sv \
    ./src/3.Execute_Stage/alu.sv \
    ./testbench/3.Execute_Stage/tb_alu.sv \
]

#add_files -fileset sim_1 -norecurse ./src/program.mem

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
set_property top tb_alu [get_filesets sim_1]
update_compile_order -fileset sim_1


# --- 4. Launch Simulation ---
launch_simulation

# --- 5. Run Simulation ---
run -all

if { $argc > 0 && [lindex $argv 0] == "gui" } {
    # '-gui' 옵션이 있으면, 파형 분석을 위해 GUI를 실행합니다.
    puts "INFO: Simulation stopped. Opening waveform GUI..."
    start_gui
    # GUI 모드에서는 사용자가 직접 닫을 것이므로, 자동으로 종료하지 않습니다.
} else {
    # '-gui' 옵션이 없으면 (기본 동작), 프로젝트를 닫고 종료합니다.
    puts "INFO: Simulation finished. Closing project."
    close_project
    exit
}


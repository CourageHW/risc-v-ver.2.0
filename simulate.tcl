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
    ./src/0.Pipeline_Register/IF_to_ID.sv \
    ./src/0.Pipeline_Register/ID_to_EX.sv \
    ./src/0.Pipeline_Register/EX_to_MEM.sv \
    ./src/0.Pipeline_Register/MEM_to_WB.sv \
    ./src/1.Fetch_Stage/module/pc_add.sv \
    ./src/1.Fetch_Stage/module/pc_sel.sv \
    ./src/1.Fetch_Stage/module/program_counter.sv \
    ./src/1.Fetch_Stage/module/instruction_memory.sv \
    ./src/1.Fetch_Stage/fetch_stage.sv \
    ./src/2.Decode_Stage/module/branch_comparator.sv \
    ./src/2.Decode_Stage/module/branch_determination.sv \
    ./src/2.Decode_Stage/module/target_address_adder.sv \
    ./src/2.Decode_Stage/module/immediate_generator.sv \
    ./src/2.Decode_Stage/module/main_control_unit.sv \
    ./src/2.Decode_Stage/module/immediate_sel.sv \
    ./src/2.Decode_Stage/module/register_file.sv \
    ./src/2.Decode_Stage/decode_stage.sv \
    ./src/3.Execute_Stage/module/MUX_3to1.sv \
    ./src/3.Execute_Stage/module/alu.sv \
    ./src/3.Execute_Stage/module/alu_control_unit.sv \
    ./src/3.Execute_Stage/execute_stage.sv \
    ./src/4.Memory_Stage/module/data_memory.sv \
    ./src/4.Memory_Stage/memory_stage.sv \
    ./src/5.WriteBack_Stage/module/write_back_sel.sv \
    ./src/5.WriteBack_Stage/writeback_stage.sv \
    ./src/riscv_core.sv \
    ./testbench/3.Execute_Stage/module/tb_alu.sv \
    ./testbench/tb_riscv_core.sv \
]

add_files -fileset sim_1 -norecurse ./program.mem \

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
set_property top tb_riscv_core [get_filesets sim_1]
update_compile_order -fileset sim_1


# --- 4. Launch Simulation ---
puts "INFO: Launching simulation..."
launch_simulation

# --- 5. Run Simulation ---
puts "INFO: Running simulation until \$finish..."
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


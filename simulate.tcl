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
    ./src/0.Pipeline_Register/ID_to_EX.sv \
    ./src/0.Pipeline_Register/EX_to_MEM.sv \
    ./src/0.Pipeline_Register/MEM_to_WB.sv \
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
    ./testbench/2.Decode_Stage/module/tb_register_file.sv \
    ./testbench/2.Decode_Stage/tb_decode_stage.sv \
    ./testbench/3.Execute_Stage/module/tb_alu.sv \
    ./testbench/3.Execute_Stage/module/tb_alu_control_unit.sv \
    ./testbench/3.Execute_Stage/tb_execute_stage.sv \
    ./testbench/4.Memory_Stage/module/tb_data_memory.sv \
    ./testbench/tb_riscv_core.sv \
]

#add_files -fileset sim_1 -norecurse ./src/program.mem

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
set_property top tb_riscv_core [get_filesets sim_1]
update_compile_order -fileset sim_1


# --- 4. Launch Simulation & Control ---
# Check if the 'gui' argument was passed from the shell script
if { $argc > 0 && [lindex $argv 0] == "gui" } {
    # GUI Mode: Launch the simulation and open the GUI.
    puts "INFO: GUI mode requested. Launching simulation with GUI."
    launch_simulation -gui
    run -all
    # The GUI will remain open for analysis.
} else {
    # Batch Mode: Launch, run, and exit.
    puts "INFO: Batch mode requested. Launching simulation without GUI."
    launch_simulation
    run -all
    close_project
    exit
}


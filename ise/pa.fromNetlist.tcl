
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name TrafficLight -dir "Z:/P/ise/TrafficLight/ise/planAhead_run_2" -part xc3s50antqg144-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "Z:/P/ise/TrafficLight/ise/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {Z:/P/ise/TrafficLight/ise} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "Z:/P/ise/TrafficLight/src/pin.ucf" [current_fileset -constrset]
add_files [list {Z:/P/ise/TrafficLight/src/pin.ucf}] -fileset [get_property constrset [current_run]]
link_design

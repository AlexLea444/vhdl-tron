if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2022.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/Alexander Lea/Downloads/vhdl-tron"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- game_impl_1_cpe.ldc
run_engine_newmsg cpe -f "game_impl_1.cprj" "vga_pll.cprj" -a "iCE40UP"  -o game_impl_1_cpe.ldc
# synthesize top design
file delete -force -- game_impl_1.vm game_impl_1.ldc
run_engine_newmsg synthesis -f "game_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o game_impl_1_syn.udb game_impl_1.vm] "C:/Users/Alexander Lea/Downloads/vhdl-tron/impl_1/game_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}

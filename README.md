# vhdl-tron

This project was developed for ES-4, Digital Logic Circuits, at Tufts University.

Two-player Tron game created in VHDL, uses two NES controllers for input and outputs display to 640x480 VGA.
Code was written in Radiant and programmed to iCE40UP5k-SG48I FPGA.

The purpose of this project was to demonstrate an understanding of digital design, including VHDL, VGA, and RAM. The purpose was not to create a complete, for-production game. However, the resulting game is working with only one major bug, and we find the game to be quite enjoyable.

The code for this project demonstrates much of what VHDL has to offer. Given that it was developed in under 2 weeks, it is in no way optimized but was created to be fast and practical. A greater revision is needed to fix communication between RAM and display which creates an off-by-one error. The temporary fix in this version can be found under pattern_gen, in which collisions are only detected if the player is moving vertically or to the left.

VHD can be found in source\impl_1\

#!/bin/bash

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/randomguy/Documents/Vivado/testing/Vitis/bin:/home/randomguy/Documents/Vivado/testing/Vivado/ids_lite/ISE/bin/lin64:/home/randomguy/Documents/Vivado/testing/Vivado/bin
else
  PATH=/home/randomguy/Documents/Vivado/testing/Vitis/bin:/home/randomguy/Documents/Vivado/testing/Vivado/ids_lite/ISE/bin/lin64:/home/randomguy/Documents/Vivado/testing/Vivado/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/randomguy/Desktop/Escuela/TT/Vivado/PW-8-Components/RV8I/RV8I.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log Procesador.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source Procesador.tcl -notrace



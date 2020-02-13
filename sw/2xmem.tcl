#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
#-----------------------------------------------------------------
# © 2017   CCE Lab
#
# mem to Xilinx mem conversion
#
# argv0 - project_name
# argv1 - mem size (18-b words)
#
# 2xmem.tcl <mem_file_name>
#-----------------------------------------------------------------

set name [lindex $argv 0]
set size [lindex $argv 1]

#---------------------------------------------------------
proc read_mem {memfile nol} {
set input [ open "$memfile.mem" r ]
set data2mem [ open "$memfile.x.mem" w ]
set line 0
 puts $data2mem "\@0000"
 while {![eof $input] && ($line < $nol)} {
    gets $input a
    #set a [string trim $a]
    set row [split $a]
           foreach elem [lrange $row 1 end] {
           if {[string length $elem] > 1} {
               set elem [string range [string trim $elem] 3 end]
               puts $data2mem $elem
			   incr line
			   #puts $line
              }
           }
 }
 close $input
 close $data2mem
}

#-- main -------------------------------------------
read_mem $name $size

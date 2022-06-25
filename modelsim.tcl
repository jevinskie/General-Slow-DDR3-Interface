
# a run command that suppresses metavalue warnings before reset
proc runq args {
   echo "Suppressing divsion by 0 warnings during reset";
   suppress 8630;
   when -label enable_div0_warn \
      { $now > 0 } \
      { echo "Re-enabled divsion by 0 warnings"; suppress -clear 8630; };
   run $args;
}

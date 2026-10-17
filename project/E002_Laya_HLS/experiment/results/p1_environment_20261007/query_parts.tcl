puts "LAYA_LOCAL_PART_CATALOG_BEGIN"
foreach p [get_parts -quiet xcu55c*] {
    puts "CANDIDATE_PART $p"
}
puts "LAYA_LOCAL_PART_CATALOG_END"
exit

#!/bin/bash
file_names=()
args=()
for f in inputFiles/*.csv 
do  
    base=$(basename -- $f) 
    file_names+=($base)
    input_files=($(pwd)"/"$f)
    output_files=($(pwd)"/outputFiles/output_"$base)
    args+=("$input_files" "$output_files")
done
echo "Sorting files ..."
python3 order.py ${file_names[@]} 

echo "Processing files ..."
 
java -jar Mars45.jar nc main.asm pa ${args[@]}
    
echo "Ploting graphics..."
python3 scriptPlot.py
    
echo "Done"

#!/bin/bash
echo "Path to Mars.jar"
read marsPath
if test -f "$marsPath";then

    file_names=()
    input_files=()
    output_files=()
    args=()
    for f in ./inputFiles/*.csv 
    do 
        base=$(basename -- $f) 
        file_names+=($base)
    done

    echo "Sorting files ..."
    python3 order.py ${file_names[@]} 
    
    echo "Processing files ..."
    
    for f in ${file_names[@]}
    do
        input_files+=($(pwd)"/inputFiles/"$f)
        output_files+=($(pwd)"/outputFiles/output_"$f)
    done
    
    for((i=0;i<${#input_files[*]};i++));do
        args+=("${input_files[$i]}" "${output_files[$i]}")
    done
    java -jar $marsPath nc main.asm pa ${args[@]}
    
    echo "Ploting graphics..."
    python3 scriptPlot.py
    
    echo "Done"
else
    echo -e "Mars jars does not exist in this location"
fi

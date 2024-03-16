#!/bin/bash

options=(
    "-l 1000 -n 1"
    "-l 1000 -n 5"
    "-l 1000 -n 10"
    "-l 550000 -n 1"
    "-l 550000 -n 5"
    "-l 550000 -n 10"
    "-l 1999999 -n 1"
    "-l 1999999 -n 5"
    "-l 1999999 -n 10"
)

base_command () {
    /home/karlenko/.jdks/openjdk-21.0.1/bin/java -javaagent:/snap/intellij-idea-ultimate/486/lib/idea_rt.jar=33559:/snap/intellij-idea-ultimate/486/bin -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 -classpath /home/karlenko/IdeaProjects/lab2/out/production/lab2:/home/karlenko/.m2/repository/com/anaptecs/jeaf/owalibs/org.apache.commons.cli/4.3.1/org.apache.commons.cli-4.3.1.jar Main "$@"
}

benchmark() {
     local threads
     local length
     local filename

     for arg in "${options[@]}";
     do
         touch temp.txt
         # add "-m index (for base_command)" to manual set index of a minimal value
         (time base_command -v ${arg} -m 987) &>> temp.txt
         threads=$(< temp.txt awk '/Threads:/ {print $2}')
         length=$(< temp.txt awk '/Arr length:/ {print $3}')
         filename="benchmark/${threads}_${length}.txt"
         < temp.txt awk '/real/ {print $2}' >> "${filename}"
         rm temp.txt
     done
}

run_benchmarks() {
    if [ -d benchmark ]; then
        date=$(date '+%Y%m%d_%H%M%S')
        mkdir -p bench_backup
        mv benchmark bench_backup
        mv bench_backup/benchmark bench_backup/"bench_${date}"
    fi
    mkdir -p benchmark

    local times=${1:-1}
    for ((i=0; i < times; i++));
    do
        benchmark
    done

    rm -f benchmark/result.txt
    for filename in benchmark/*.txt;
    do
        local thread
        local length

        if [[ ${filename} =~ benchmark/([0-9]+)_([0-9]+)\.txt ]]; then
            thread="${BASH_REMATCH[1]}"
            length="${BASH_REMATCH[2]}"
        fi

        awk 'gsub(",", ".")' "${filename}" | awk -v n="${thread}" -v l="${length}" -F '[m]' '{sum+=$1*60+$2} END {printf "%3i | %12i | %.5fs\n", n, l, sum/NR}' >> benchmark/result.txt
    done;

    sort -n -t '|' -k1,1 -k2,2 -o benchmark/result.txt benchmark/result.txt
}

run_benchmarks "$@"
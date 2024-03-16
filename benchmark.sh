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
        awk 'gsub(",", ".")' "${filename}" | awk -v file="${filename}" -F '[m]' '{sum+=$1*60+$2} END {printf "%s = %.5f s\n", file, sum/NR}' >> benchmark/result.txt
    done;
}

run_benchmarks "$@"
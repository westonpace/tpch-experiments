#!/bin/bash

for i in {1..22}
do
    echo "Query ${i}"
    strace -y -f -e pread64 --status=successful Rscript repr.R --engine=duckdb_sql --query=${i} 2>&1 | grep \.parquet\> | rev | cut -d"=" -f 1 | rev | paste -s -d+ | bc
done


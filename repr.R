library(arrowbench)
library(dplyr, warn.conflicts = FALSE)
library(arrow, warn.conflicts = FALSE)
library(DBI)
library(bench)
library(duckdb)
library(optparse)

parser <- OptionParser(formatter = IndentedHelpFormatter)
parser <- add_option(parser, c("-c", "--ncpus"), help = "# of CPUs to use on the query", default=16)
parser <- add_option(parser, c("-q", "--query"), help = "The query # to run", default=1)
parser <- add_option(parser, "--chunksize", help = "# of rows to put in a single row group / record batch", default=1000000)
parser <- add_option(parser, "--silent", action = "store_true", help = "If set, parameter values will not be printed", default=FALSE)
parser <- add_option(parser, "--engine", help = "The engine to use, either arrow or duckdb_sql", default="arrow")

args <- parse_args(parser)

if (args$silent == FALSE) {
   print(paste0("Query: ", args$query))
   print(paste0("# CPU: ", args$ncpus))
   print(paste0("RB Sz: ", args$chunksize))
   print(paste0("Engin: ", args$engine))
}

con <- NULL
if (args$engine == "duckdb_sql") {
  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con, paste0("PRAGMA threads=", args$ncpus, ";"))
} else {
  arrow::set_cpu_count(args$ncpus)
}

input_func <- get_input_func(
  engine = args$engine,
  scale_factor = 5,
  query_id = args$query,
  format = "parquet",
  chunk_size = args$chunksize,
  con = con
)

print(bench_time(get_query_func(args$query, args$engine)(input_func, collect_func=compute, con=con)))

###############################################################################
#           Aydin Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           anc_table2bed.R
###############################################################################

.libPaths("~/R/x86_64-pc-linux-gnu-library/4.5")

library(dplyr)
library(readr)
library(glue)
library(stringr)

# rle-based ancestry extraction
get.anc.rle <- function(values, positions, pad = 1) {
  anc.rle <- rle(values)
  ends <- cumsum(anc.rle$lengths)
  starts <- c(1, head(ends, -1) + 1)
  
  tibble::tibble(
    value = anc.rle$values,
    start = positions[starts] - pad,
    end = positions[ends] + pad
  )
}

# use ancestry table to create bed of ancestral runs
anc.table2bed <- function(input.file, output.file) {
  file.name <- basename(input.file)
  file.info <- stringr::str_match(file.name, "^([A-Z]+)_chr(\\d+)_anc_pos\\.tsv\\.gz$")
  chr.num <- file.info[3]
  chr.label <- paste0("chr", chr.num)
  
  anc.table <- readr::read_tsv(input.file, show_col_types = FALSE)
  pos <- anc.table$POS
  
  sample.cols <- names(anc.table)[-1]
  samples <- unique(gsub("_(AN1|AN2)$", "", sample.cols))
  
  all.runs <- list()
  
  for (sample in samples) {
    for (an.tag in c("AN1", "AN2")) {
      colname <- paste0(sample, "_", an.tag)
      values <- anc.table[[colname]]
      
      runs <- get.anc.rle(values, pos) %>%
        mutate(
          chr = chr.label,
          info = paste0(sample, "_", an.tag, "_", value)
        ) %>%
        select(chr, start, end, info)
      
      all.runs[[paste0(sample, ".", an.tag)]] <- runs
    }
  }
  
  bed <- bind_rows(all.runs)
  readr::write_tsv(bed, output.file, col_names = FALSE)
  message("wrote: ", output.file)
}

# command-line interface
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 2) {
  anc.table2bed(args[1], args[2])
} else {
  stop("Usage: Rscript /path/to/anc_table2bed.R <input_file.tsv.gz> <output_file.bed>")
}

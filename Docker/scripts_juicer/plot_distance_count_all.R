print.usage <- function() {
	cat('\nUsage: plot_distance_count_all.R <datadir> <output>\n',file=stderr())
	cat('   <datadir>, data directory (e.g., "CustardPyResults_Hi-C/Juicer_hg38/")\n',file=stderr())
	cat('   <output>, output filename (e.g., "plot.pdf") \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  print.usage()
  q()
}
datadir <- args[1]
outputfile <- args[2]

library(reshape2)
library(ggplot2)
library(dplyr)

folders <- list.dirs(datadir, full.names = TRUE, recursive = FALSE)

combined_data <- data.frame()
for (folder in folders) {
  filepath <- file.path(folder, "/distance/distance_vs_count.MAPQ30.txt")

  if (file.exists(filepath) && file.info(filepath)$size > 0) {
    data <- read.table(filepath)
    data <- data[c(3,5)]
    names(data) <- c("distance", "count")
    data$Sample <- basename(folder)
    combined_data <- rbind(combined_data, data)
  }
}

combined_data <- combined_data %>%
  group_by(Sample) %>%
  mutate(total_cis_contact = sum(count),
         probability = count / total_cis_contact)

xbreaks <- c(10000, 100000, 1000000, 10000000, 100000000, 1000000000)
ybreaks <- c(1, 0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001)

pdf(outputfile, width = 6, height = 5)

g <- ggplot(combined_data, aes(distance, probability, colour = Sample))
g <- g + scale_x_log10(breaks=xbreaks, labels=xbreaks)
g <- g + scale_y_log10(breaks=ybreaks, labels=ybreaks)
g <- g + geom_line()
g <- g + theme_minimal() +
  theme(panel.background = element_rect(fill = "white", colour = NA))
print(g)
dev.off()

#libraries
library(ggplot2)
library(plotly, warn.conflicts = FALSE)

#loading variables from command line
args = commandArgs(trailingOnly=TRUE)

#Loading the data frames
early <- read.csv(args[1], header = TRUE)
late <- read.csv(args[2], header = TRUE)


#normalize pansyp1
early$normalized_pansyp1 <- early$pansyp1_corrected / mean(early$pansyp1_corrected)
late$normalized_pansyp1 <- late$pansyp1_corrected / mean(early$pansyp1_corrected)


#normalize syp1phos
early$normalized_syp1phos <- early$syp1phos_corrected / mean(early$syp1phos_corrected)
late$normalized_syp1phos <- late$syp1phos_corrected / mean(early$syp1phos_corrected)

#background_average pansyp1
early$pansyp1_background_average <- early$pansyp1_background / early$pansyp1_background_pixels
late$pansyp1_background_average <- late$pansyp1_background / late$pansyp1_background_pixels

#background_average syp1phos
early$syp1phos_background_average <- early$syp1phos_background / early$syp1phos_background_pixels 
late$syp1phos_background_average <- late$syp1phos_background / late$syp1phos_background_pixels

#normalize_average_pansyp1
early$normalize_background_average_pansyp1 <- early$pansyp1_background_average / mean(early$pansyp1_background_average)
late$normalize_background_average_pansyp1 <- late$pansyp1_background_average / mean(early$pansyp1_background_average)

#normalize_average_syp1phos 
early$normalize_background_average_syp1phos <- early$syp1phos_background_average / mean(early$syp1phos_background_average)
late$normalize_background_average_syp1phos <- late$syp1phos_background_average / mean(early$syp1phos_background_average)

#add genstage
early$genstage <- args[3]
late$genstage <- args[4]


#add gonad
early$gonad <- args[5]
late$gonad <- args[5]

#fuse early and late normalized tables
normalized <- do.call("rbind", list(early,late))

#save the csv file
write.csv(normalized, args[6])

#saving as png 
png(file = paste(args[7],"pansyp1.png",sep = ""))

#plotting pansyp1
ggplot(normalized, aes(x=stage, y=normalized_pansyp1)) +geom_boxplot() +geom_jitter(width = 0.15)

dev.off()

#saving as png
png(file = paste(args[7],"syp1phos.png",sep = ""))

#plotting syp1phos
ggplot(normalized, aes(x=stage, y=normalized_syp1phos)) +geom_boxplot() +geom_jitter(width = 0.15)

dev.off()





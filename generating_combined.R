#calling libraries
library(ggplot2)
library(plotly, warn.conflicts = FALSE)

#getting arguments
args = commandArgs(trailingOnly=TRUE)

#making the file list
temp = list.files(path = args[1], pattern = "*.csv")

#making the complete file table
all_intensities <- do.call("rbind", lapply(temp, function(x) read.csv(paste(args[1], x,sep = ""), header = TRUE)))

#saving the file table
write.csv(all_intensities, args[2])

#generating ggplots
ggplot_pan <- ggplot(all_intensities, aes(x=genstage, y=normalized_pansyp1, col=gonad)) +geom_jitter(aes(name = sbs, normal = normalized_pansyp1), width = 0.15) +labs(x = "", y = "Normalized panSYP1", col = "Gonad")
ggplot_phos <- ggplot(all_intensities, aes(x = genstage, y= normalized_syp1phos, col=gonad)) +geom_jitter(aes(name = sbs, normal = normalized_syp1phos), width = 0.15) +labs(x = "", y = "Normalized SYP1phos", col = "Gonad")
ggplot_pan_background <- ggplot(all_intensities, aes(x = genstage, y = normalize_background_average_pansyp1, col = gonad)) +geom_jitter(aes(name = sbs, normal = normalize_background_average_pansyp1, avg_background = pansyp1_background_average), width = 0.15) +labs(x = "", y = "panSYP-1 average background", col = "Gonad")
ggplot_phos_background <- ggplot(all_intensities, aes(x = genstage, y = normalize_background_average_syp1phos, col = gonad)) +geom_jitter(aes(name = sbs, normal = normalize_background_average_syp1phos, avg_background = syp1phos_background_average), width = 0.15) +labs(x = "", y = "SYP-1Phos average background", col = "Gonad")

#generating plotly plots
plotly_pan <- ggplotly(ggplot_pan, tooltip = c("name", "normal"))
plotly_phos <- ggplotly(ggplot_phos, tooltip = c("name", "normal"))
plotly_pan_background <- ggplotly(ggplot_pan_background, tooltip = c("name", "normal", "avg_background"))
plotly_phos_background <- ggplotly(ggplot_phos_background, tooltip = c("name", "normal", "avg_background"))

save.image(args[3])

library(RSQLite)
library(tidyverse)
library(scales)

con <- dbConnect(RSQLite::SQLite(), "/home/andrej/Documents/dev/medline/medline_full.sqlite")
tbl <- dbReadTable(con, "tab1")
data <- tbl %>% group_by(year) %>% summarise(size = median(size), activity = median(activity))
data <- data %>% gather(variable, value, -year)
dbDisconnect(con)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

plt <- ggplot(mapping = aes(x = year, colour = variable, group = variable)) +
  geom_line(data = data %>% filter(variable == "size"), mapping = aes(y = value), size = 1.5) +
  geom_line(data = data %>% filter(variable == "activity"), mapping = aes(y = value / 35), size = 1.5) +
  scale_y_continuous("Community size", limits = c(0, 120), sec.axis = sec_axis(~. * 35, name = "Activity level", labels = comma)) +
  scale_color_manual(values = c("size" = cbPalette[1], "activity" = cbPalette[2]), breaks = c("size", "activity"), labels = c("Size", "Activity")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", aspect.ratio = 1)

ggsave("size-activity.pdf", plt, height = 5, width = 5)

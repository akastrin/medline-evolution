library(data.table)
library(tidyverse)
library(scales)
library(cowplot)


# A colourblind friendly palette.
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Figure 1
data <- fread("../data/xml2txt-majr.txt", col.names = c("pmid", "year", "doi"))

pmid2year <- data %>%
  select(pmid, year) %>% 
  filter(year <= 2015) %>% 
  group_by(year) %>% 
  summarise(freq = n_distinct(pmid)) %>% 
  mutate(cumfreq = cumsum(freq)) %>% 
  select(year, cumfreq)

data <- fread("../data/coc-data.txt", col.names = c("doi1", "doi2", "year", "freq"))

coc2year <- data %>% 
  select(year, freq) %>% 
  filter(year <= 2015) %>% 
  group_by(year) %>% 
  summarise(freq = sum(freq)) %>% 
  mutate(cumfreq = cumsum(freq)) %>% 
  select(year, cumfreq)

data <- inner_join(x = pmid2year, y = coc2year, by = "year") %>% filter(year <= 2014)

formatter1000 <- function(x) { 
  comma(x / 1000) 
}

plt <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = freq.x, color = "cumfreq.x"), size = 1.5) +
  geom_line(aes(y = freq.y / 3.5, color = "cumfreq.y"), size = 1.5) +
  scale_y_continuous("Number of citations with MeSH terms", sec.axis = sec_axis(~. * 3.5, name = "Number of co-occurrences of MeSH terms", labels=formatter1000), labels = formatter1000) +
  scale_color_manual(labels= c("Citations", "Co-occurrences"), values = col_palette, breaks = c("cumfreq.x", "cumfreq.y")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", aspect.ratio = 1)

# plt <- ggplot(data, aes(x = year)) +
#   geom_line(aes(y = cumfreq.x, color = "cumfreq.x"), size = 1.5) +
#   geom_line(aes(y = cumfreq.y / 3.5, color = "cumfreq.y"), size = 1.5) +
#   scale_y_continuous("Number of citations with MeSH terms", sec.axis = sec_axis(~. * 3.5, name = "Number of co-occurrences of MeSH terms", labels=formatter1000), labels = formatter1000) +
#   scale_color_manual(labels= c("Citations", "Co-occurrences"), values = cbPalette, breaks = c("cumfreq.x", "cumfreq.y")) +
#   labs(x = "Year") +
#   theme_bw() +
#   theme(legend.title = element_blank(), legend.position = "bottom", aspect.ratio = 1) +
#   coord_equal()

ggsave("../figures/tmp.pdf", plt, width = 5, height = 5)
system(paste("pdfcrop", "../figures/tmp.pdf", "../figures/growth.pdf"))
system("rm ../figures/tmp.pdf")

# Figure 2
data <- read_tsv(file = "../data/networks_statistics.txt")

p1 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = n_nodes, color = "n_nodes"), size = 1.5) +
  geom_line(aes(y = n_edges / 25, color = "n_edges"), size = 1.5) +
  scale_y_continuous("Number of nodes", sec.axis = sec_axis(~. * 25, name = "Number of edges", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Nodes", "Edges"), values = col_palette, breaks = c("n_edges", "n_nodes")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("A")

p2 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = ave_deg, color = "ave_deg"), size = 1.5) +
  geom_line(aes(y = cen * 140, color = "cen"), size = 1.5) +
  scale_y_continuous("Average Degree", sec.axis = sec_axis(~. / 140, name = "Average centrality", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Degree", "Centrality"), values = col_palette, breaks = c("ave_deg", "cen")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("B")

p3 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = apl, color = "apl"), size = 1.5) +
  geom_line(aes(y = cc * 15, color = "cc"), size = 1.5) +
  scale_y_continuous("Average path length", sec.axis = sec_axis(~. / 15, name = "Clustering coefficient", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Average path length", "Clustering"), values = col_palette, breaks = c("apl", "cc")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("C")

p4 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = comm_size, color = "comm_size"), size = 1.5) +
  geom_line(aes(y = modul * 1000, color = "modul"), size = 1.5) +
  scale_y_continuous("Number of communities", sec.axis = sec_axis(~. / 1000, name = "Modularity", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Communities", "Modularity"), values = col_palette, breaks = c("comm_size", "modul")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("D")

all <- plot_grid(p1, p2, p3, p4, ncol = 2, align = "v")
save_plot("../figures/tmp.pdf", all, base_height = 8, base_width = 10)
system(paste("pdfcrop", "../figures/tmp.pdf", "../figures/statistics.pdf"))
system("rm ../figures/tmp.pdf")

################################################
################################################
################################################

library(tidyverse)
library(igraph)
library(poweRlaw)
library(data.table)

data <- fread("../data/coc-data.txt", header = FALSE)
data <- data %>% group_by(V1, V2) %>% summarise(weight = sum(V4))


g <- graph_from_data_frame(d = data, directed = FALSE)
g <- simplify(g)
deg <- degree(g)
clu <- transitivity(g = g, type = "local")




# Degree distribution

deg <- degree(g)
deg <- deg[deg>0]

m_pl <- displ$new(deg)
est_pl <- estimate_xmin(m_pl)
m_pl$setXmin(est_pl)

m_w = conweibull$new(deg)
est_w = estimate_xmin(m_w)
m_w$setXmin(est_w)

m_ln = dislnorm$new(deg)
est_ln = estimate_xmin(m_ln)
m_ln$setXmin(est_ln)

data_pl <- plot(m_pl, draw = F)
fit_data_pl <- lines(m_pl, draw = F)
fit_data_ln <- lines(m_ln, draw = F)
fit_data_w <- lines(m_w, draw = F)

col_palette <- brewer.pal(3, "Set1")

plt1 <- ggplot(data_pl) + 
  geom_point(aes(x=x, y=y), size = 0.5) +
  labs(x="k", y="CDF") +
  geom_line(data = fit_data_w, aes(x=x, y=y, colour = "a"), size = 1) +
  geom_line(data = fit_data_ln, aes(x=x, y=y, colour = "b"), size = 1) +
  geom_line(data = fit_data_pl, aes(x=x, y=y, colour = "c"), size = 1) +
  scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  annotation_logticks() +
  labs(x = "Degree", y = "Cumulative distribution function") +
  scale_color_manual(name = "Distribution", labels= c("Log-normal", "Power-law", "Weibull"), values = col_palette, breaks = c("a", "b", "c")) +
  theme_bw() +
  theme(panel.grid.minor = element_blank(),
        legend.position = c(0.25, 0.23),
        legend.background = element_rect(fill=alpha('transparent', 0)),
        plot.title = element_text(face = "bold"),
        aspect.ratio = 1) +
  ggtitle("A")

# ggsave(filename = "../figures/deg.pdf", plot = plt, height = 6, width = 6)

# Degree vs. clustering

df <- tibble(deg, clu)

plt2 <- ggplot(data = df, aes(x = deg, y = clu)) + 
  geom_point(size = 0.5) +
  geom_smooth(aes(colour = "a"), method = "lm", se = FALSE, size = 1) +
  scale_colour_manual(values = col_palette) +
  scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  annotation_logticks() +
  labs(x = "Degree", y = "Clustering coefficient") +
  theme_bw() +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"),
        aspect.ratio = 1) +
  ggtitle("B")

# ggsave(filename = "../figures/deg-clu.pdf", plot = plt, height = 6, width = 6)

all <- plot_grid(plt1, plt2, ncol = 2, align = "v")
save_plot("../figures/tmp.pdf", all, base_width = 10)
system(paste("pdfcrop", "../figures/tmp.pdf", "../figures/degree.pdf"))
system("rm ../figures/tmp.pdf")

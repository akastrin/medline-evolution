library(data.table)
library(tidyverse)
library(scales)
library(cowplot)

# A colourblind friendly palette.
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Figure 1
data <- fread("../data/xml2txt_majr.txt", col.names = c("pmid", "year", "doi"))

pmid2year <- data %>%
  select(pmid, year) %>% 
  filter(year <= 2015) %>% 
  group_by(year) %>% 
  summarise(freq = n_distinct(pmid)) %>% 
  mutate(cumfreq = cumsum(freq)) %>% 
  select(year, cumfreq)

data <- fread("../data/mesh_coc.txt", col.names = c("doi1", "doi2", "year", "freq"))

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
  geom_line(aes(y = cumfreq.x, color = "cumfreq.x"), size = 1.5) +
  geom_line(aes(y = cumfreq.y / 3.5, color = "cumfreq.y"), size = 1.5) +
  scale_y_continuous("Number of citations with MeSH terms", sec.axis = sec_axis(~. * 3.5, name = "Number of co-occurrences of MeSH terms", labels=formatter1000), labels = formatter1000) +
  scale_color_manual(labels= c("Citations", "Co-occurrences"), values = cbPalette, breaks = c("cumfreq.x", "cumfreq.y")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", aspect.ratio = 1) +
  coord_equal()
  
plt
save_plot("citations.pdf", plt, base_height = 5)

# Figure 2
data <- read_csv(file = "../data/networks_statistics.csv") %>% filter(year <= 2014)

p1 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = n_nodes, color = "n_nodes"), size = 1.5) +
  geom_line(aes(y = n_edges / 25, color = "n_edges"), size = 1.5) +
  scale_y_continuous("Number of nodes", sec.axis = sec_axis(~. * 25, name = "Number of edges", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Nodes", "Edges"), values = cbPalette, breaks = c("n_edges", "n_nodes")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("A")

p2 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = ave_deg, color = "ave_deg"), size = 1.5) +
  geom_line(aes(y = cen * 140, color = "cen"), size = 1.5) +
  scale_y_continuous("Average Degree", sec.axis = sec_axis(~. / 140, name = "Average centrality", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Degree", "Centrality"), values = cbPalette, breaks = c("ave_deg", "cen")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("B")

p3 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = apl, color = "apl"), size = 1.5) +
  geom_line(aes(y = cc * 15, color = "cc"), size = 1.5) +
  scale_y_continuous("Average path length", sec.axis = sec_axis(~. / 15, name = "Clustering coefficient", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Average path length", "Clustering"), values = cbPalette, breaks = c("apl", "cc")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("C")

p4 <- ggplot(data, aes(x = year)) +
  geom_line(aes(y = comm_size, color = "comm_size"), size = 1.5) +
  geom_line(aes(y = modul * 1000, color = "modul"), size = 1.5) +
  scale_y_continuous("Number of communities", sec.axis = sec_axis(~. / 1000, name = "Modularity", labels=comma), labels = comma) +
  scale_color_manual(labels= c("Communities", "Modularity"), values = cbPalette, breaks = c("comm_size", "modul")) +
  labs(x = "Year") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom", plot.title = element_text(face = "bold"), aspect.ratio = 1) +
  ggtitle("D")

all <- plot_grid(p1, p2, p3, p4, ncol = 2, align = "v")
save_plot("figure-2.pdf", all, base_height = 8, base_width = 10)


################################################

library(ggplot2)
library(igraph)
data <- fread("/home/andrej/Documents/dev/community-evolution-analysis/data/1.txt", header = FALSE)
data <- data %>% group_by(V1, V2) %>% summarise(weight = sum(V4))


g <- graph_from_data_frame(d = data, directed = FALSE)
g <- simplify(g)
deg <- degree(g)
str <- strength(g)
clu <- transitivity(g = g, type = "local")
clu_w <- transitivity(g = g, type = "weighted")

df <- tibble(deg, str, clu, clu_w)

ggplot(data = df, aes(x = deg, y = clu)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(trans = "log10")

graph.strength.distribution <- function (graph, cumulative = FALSE, ...)
{
  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }
  # graph.strength() instead of degree()
  cs <- graph.strength(graph, ...)
  hi <- hist(cs, -1:max(cs), plot = FALSE)$density
  if (!cumulative) {
    res <- hi
  }
  else {
    res <- rev(cumsum(rev(hi)))
  }
  res
}


data <- degree(g)
data <- data[data>0]
data.dist <- data.frame(k=0:max(data),p_k=degree_distribution(g))
data.dist <- data.dist[data.dist$p_k>0,]
ggplot(data.dist) + geom_point(aes(x=k, y=p_k)) + theme_bw()

data <- str
data <- data[data>0]
data.dist <- data.frame(k=0:max(data),p_k=graph.strength.distribution(g))
data.dist <- data.dist[data.dist$p_k>0,]
ggplot(data.dist) + geom_point(aes(x=k, y=p_k)) + theme_bw() + scale_x_continuous(trans = "log10") + scale_y_continuous(trans = "log10")


library(poweRlaw)
m_pl <- displ$new(data)
est_pl <- estimate_xmin(m_pl)
m_pl$setXmin(est_pl)

m_w = conweibull$new(data)
est_w = estimate_xmin(m_w)
m_w$setXmin(est_w)

m_ex = disexp$new(data)
est_ex = estimate_xmin(m_ex)
m_ex$setXmin(est_ex)

m_ln = dislnorm$new(data)
est_ln = estimate_xmin(m_ln)
m_ln$setXmin(est_ln)

m_pois = dispois$new(data)
est_pois = estimate_xmin(m_pois)
m_pois$setXmin(est_pois)

plot_data_pl <- plot(m_pl, draw = F)
fit_data_pl <- lines(m_pl, draw = F)
fit_data_pl <- lines(m_pl, draw = F)
fit_data_ln <- lines(m_ln, draw = F)
fit_data_w <- lines(m_w, draw = F)

ggplot(plot_data_pl) + 
  geom_point(aes(x=x, y=y)) + labs(x="log(k)", y="log(CDF)") +
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10") +
  theme_bw() + 
  geom_line(data = fit_data_w, aes(x=x, y=y), colour="green", size = 1.5) +
  geom_line(data = fit_data_ln, aes(x=x, y=y), colour="red", size = 1.5) +
  geom_line(data = fit.data, aes(x=x, y=y), colour="blue", size = 1.5)


blackouts <- read.table("http://tuvalu.santafe.edu/~aaronc/powerlaws/data/blackouts.txt")


source("discweib.R")
source("weibull.R")
fit_weib <- discweib.fit(data)

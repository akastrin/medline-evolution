library(igraph)
library(data.table)
library(Rcpp)
library(R.matlab)
library(tidyverse)
library(Matrix)
# source("clustercoef_kaiser.R")
sourceCpp("./scripts/kaiser.cpp")

# Create network-statistics.csv file
files <- paste0("../data/matlab/adj-mats/adj-mat-", 1:49, ".mm")
n_nodes <- vector(mode = "integer", length = length(files))
n_edges <- vector(mode = "integer", length = length(files))
ave_deg <- vector(mode = "double", length = length(files))
cen <- vector(mode = "integer", length = length(files))
apl <- vector(mode = "double", length = length(files))
cc <- vector(mode = "double", length = length(files))

for (i in 1:length(files)) {
  file <- files[i]
  data <- readMM(file)
  g <- graph_from_adjacency_matrix(adjmatrix = data, mode = "undirected", weighted = TRUE)
  adj <- get.adjacency(g, sparse = FALSE)
  n_nodes[i] <- vcount(g)
  n_edges[i] <- ecount(g)
  ave_deg[i] <- mean(degree(g))
  cen[i] <- mean(eigen_centrality(g, directed = FALSE)$vector)
  apl[i] <- mean_distance(g = g, directed = FALSE)
  cc[i] <- kaiser(adj)
  cat(i, "\n")
}

modularity <- read_tsv("../data/matlab/other/modularity.txt")
comm_size <- readMat("../data/matlab/other/comm-sizes.mat")
comm_size <-  apply(comm_size$commSizes != 0, 1, sum)

year <- 1966:2014
tab <- data.frame(year, n_nodes, n_edges, ave_deg, cen, apl, cc, modul, comm_size)
write_tsv(tab, path = "../data/networks_statistics.txt")


####################################
# Heatmap
comm_evol_size <- readMat("../data/matlab/other/comm-evol-size.mat")$commEvolSize
# library(heatmap3)
library(RColorBrewer)
data <- t(comm_evol_size)
data2 <- data

data2 <- log(data2 + 1)
library(reshape2)
data_melt <- melt(data)
data_melt2 <- melt(data2)

library(ggplot2)
library(scales)

plt <- ggplot(data_melt2, aes(Var2, Var1)) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_continuous(labels = seq(1965, 2015, 5), breaks = seq(1, 51, 5)) +
  scale_y_reverse() +
  labs(x = "Year", y = "Community") +
  theme(panel.background = element_blank(),
        panel.border=element_rect(fill=NA),
        legend.position = "none")
plt
ggsave("../figures/community-heatmap.pdf", plt, height = 9, width = 5)

####################################

# How many ... each particular community active
life_span <- apply(X = comm_evol_size, MARGIN = 2, FUN = function(x) sum(x != 0))

med_comm_size <- apply(X = comm_evol_size, MARGIN = 2, FUN = function(x) median(x[x != 0]))

# Read community structure from MATLAB

comm1 <- readMat("/home/andrej/Documents/dev/community-evolution-analysis/data/mats/medline/strComms1.mat")$strComms

mesh2cluster <- function(str_comms) {
  res <- list()
  n <- length(str_comms)
  for (i in 1:n) {
    mesh_terms <- unlist(str_comms[[i]])
    setNames(object = mesh_terms, nm = rep(n, length(mesh_terms)))
    res[[i]] <- mesh_terms
  }
  return(res)
}



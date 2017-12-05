library(data.table)
library(igraph)
library(jsonlite)
library(Matrix)
library(tidyverse)

set.seed(12345)

setwd("./")
source("./computation/community-detection/scripts/functions.R")

# Precompute frequency distribution of MeSH terms in papers for each year
xml2txt <- fread("./data/xml2txt-majr.txt", col.names = c("pmid", "year", "doi"))

# Load pre-prepared data
data_input <- fread(input = "./data/coc-data.txt", header = FALSE, col.names = c("doi1", "doi2", "year", "freq"))
freq_data <- fread(input = "./data/freq.txt", header = FALSE, col.names = c("doi", "year", "freq"))
mesh <- fread(input = "./data/doi2name.txt", header = FALSE, col.names = c("doi", "name"))
mesh_idx <- tibble(idx = 1:nrow(mesh), mesh = mesh$doi)

# Main loop
start <- 1966
end <- 2014
counter <- 1
modularity <- vector(mode = "double", length = length(seq(start, end)))
for (i in seq(from = start, to = end, by = 1)) {
  # Subset data
  data <- data_input %>% filter(year == i) %>% select(doi1, doi2, freq)
  xml2txt_cur <- xml2txt %>% filter(year == i)
  data_agg <- data %>% group_by(doi1, doi2) %>% summarize_all(sum)
  # Go through co-occurrence data and compute normalized weight
  tmp_tbl <- freq_data %>% filter(year == i)
  dt <- data.table(tmp_tbl, key = c("doi", "year"))
  doi2freq <- dt[, sum(freq), doi]
  names(doi2freq) <- c("doi", "freq")
  vec <- setNames(doi2freq$freq, doi2freq$doi)
  setDT(data_agg)[, freq_norm := freq^2 / (vec[doi1] * vec[doi2])]
  # Create graph and compute clustering
  g <- graph_from_data_frame(data_agg, directed = FALSE)
  # We cluster network with the normalized weights
  E(g)$weight <- data_agg$freq_norm
  cluster <- cluster_louvain(g)
  #  Store adjacency matrix in MM format
  adj <- as_adjacency_matrix(graph = g, attr = "weight", sparse = TRUE)
  filename <- paste0("./data/matlab/adj-mats/adj-mat-", counter, ".mm")
  writeMM(obj = adj, file = filename)
  # Store mesh - cluster - idx triples for year i
  membs <- as.numeric(membership(cluster))
  membs_names <- names(membership(cluster))
  clu_tbl <- tibble(mesh = membs_names, cluster = membs)
  clu_tbl <- left_join(x = clu_tbl, y = mesh_idx, by = "mesh")
  filename <- paste0("./data/matlab/clu-tabs/clu-tbl-", counter, ".txt")
  write_tsv(clu_tbl, filename)
  # Store modularity
  modularity[counter] <- modularity(cluster)
  counter <- counter + 1
  # Continue with the analysis
  # Compute density according to Callon's equation
  density <- vector(mode = "numeric", length = length(cluster))
  for (j in 1:length(cluster)) {
    edges <- get_internal(graph = g, cluster = cluster, m = j)
    w <- sum(membership(cluster) == j)
    density[j] <- 100 * (sum(edges$weight) / w)
  }
  # Compute centrality according to Callon's equation
  centrality <- vector(mode = "numeric", length = 0)
  for (j in 1:length(cluster)) {
    edges <- get_external(graph = g, cluster = cluster, m = j)
    centrality[j] <- 10 * sum(edges$weight)
  }
  # Create JSON object
  res_list <- list()
  tab <- table(membership(cluster))
  # Pack values for each cluster
  for (k in 1:length(tab)) {
    cent <- centrality[k]
    dens <- density[k]
    idx <- membership(cluster) == k
    terms <- names(membership(cluster)[idx])
    # Compute activity for a cluster
    activity <- xml2txt_cur %>% filter(doi %in% terms) %>% summarise(n_distinct(pmid)) %>% pull
    # Compute z-score
    g_sub <- induced_subgraph(graph = g, vids = terms)
    deg <- degree(g_sub)
    z <- (deg - mean(deg)) / sd(deg)
    tmp_list <- list()
    for (m in 1:length(terms)) {
      term <- terms[m]
      name <- mesh[mesh$doi == term, ]$name
      weight <- z[term]
      foo <- list(dui = term, name = name, weight = weight)
      tmp_list[[m]] <- foo
    }
    res_list[[k]] <- list(year = i, cluster = k, size = length(terms), activity = activity, centrality = cent, density = dens, terms = tmp_list)
  }
  # Write JSON to file
  my_json <- toJSON(res_list)
  file_name <- paste("./data/json/data-", i, ".json", sep = "")
  write(x = my_json, file = file_name)
}
modularity <- as_tibble(list(modularity = modularity))
write_tsv(modularity, "./data/matlab/other/modularity.txt")

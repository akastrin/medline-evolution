# Get all edges which belong to particular community
get_internal <- function(graph, cluster, m) {
  res <- E(induced_subgraph(graph, which(cluster$membership == m)))
  return(res)
}

# Get all edges which go from community nodes to all other nodes, excluding community nodes
get_external <- function(graph, cluster, m) {
  all_edges <- E(graph)[inc(V(graph)[membership(cluster) == m])]
  all_edges_m <- get.edges(graph, all_edges)
  res <- all_edges[!(all_edges_m[, 1] %in% V(graph)[membership(cluster) == m] &
                       all_edges_m[, 2] %in% V(g)[membership(cluster) == m])]
  return(res)
}
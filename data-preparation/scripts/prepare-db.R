library(jsonlite)
library(dplyr)
library(RSQLite)
library(DBI)

con <- dbConnect(RSQLite::SQLite(), "./data/medline.sqlite")

files <- list.files(path = "./data/json", pattern = "^data", full.names = TRUE)
for (file in files) {
    data <- fromJSON(txt = file, flatten = TRUE)
    for (i in 1:nrow(data)) {
      year <- unlist(data[i, "year"])
      cluster <- unlist(data[i, "cluster"])
      size <- unlist(data[i, "size"])
      activity <- unlist(data[i, "activity"])
      centrality <- unlist(data[i, "centrality"])
      density <- unlist(data[i, "density"])
      desc <- data.frame(year = year, cluster = cluster, size = size, activity = activity, centrality = centrality, density = density)
      dui <- unlist(data[i, "terms"][[1]]$dui)
      name <- unlist(data[i, "terms"][[1]]$name)
      z <- unlist(data[i, "terms"][[1]]$weight)
      mesh <- data.frame(year = year, cluster = cluster, dui = dui, name = name, z = z)
      dbWriteTable(con, name = "tab1", value = desc, append = TRUE)
      dbWriteTable(con, name = "tab2", value = mesh, append = TRUE)
   }
}

dbDisconnect(con)




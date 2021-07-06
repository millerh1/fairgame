clean_proxies <- function(raw_file, output) {
  proxies <- readr::read_table(raw_file, col_names = "Proxies")
  prox <- dplyr::mutate(proxies, Proxies = paste0(gsub(Proxies, pattern = "(.+:.+):(.+):(.+)", replacement = "\\2"), ":",
                                                  gsub(Proxies, pattern = "(.+:.+):(.+):(.+)", replacement = "\\3"), "@",
                                                  gsub(Proxies, pattern = "(.+:.+):(.+):(.+)", replacement = "\\1")))
  proxylst <- list(
      'proxies' = lapply(dplyr::pull(prox, Proxies), function (proxnow) {
          list(
            "http" = paste0("http://", proxnow),
            "https" = paste0("https://", proxnow)
          )
        })
  )
  jsonlite::write_json(proxylst, path = output, auto_unbox = T, pretty = T)
}

args <- commandArgs(trailingOnly=TRUE)
clean_proxies(
  raw_file = args[1],
  output = args[2]
)

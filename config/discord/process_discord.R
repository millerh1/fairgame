library(dplyr)
library(readr)
library(magrittr)
library(stringr)
library(ggplot2)

files <- list.files(path = "config/discord", full.names = T, pattern = ".txt")
cats <- gsub(files, pattern = "config/discord/(.+)\\.txt", replacement = "\\1")
names(files) <- cats
dir.create("config/choose_asin/", showWarnings = FALSE)
dflist <- lapply(seq(files), function(i) {
  cat_now <- names(files)[i]
  print(cat_now)
  file_now <- files[i]
  lines <- readr::read_lines(file_now)

  res <- list()
  current_date <- NA
  current_asin <- NA

  if (! file.exists(paste0("config/choose_asin/", cat_now, ".csv"))) {

    for (j in seq(lines)) {
      line <- lines[j]
      if (grepl(line, pattern = "^\\[")) {
        print("Date line!")
        print(line)
        datenow <- as.Date(tolower(gsub(line, pattern = "^\\[([a-zA-Z0-9\\-]+) .+\\].+", replacement = "\\1")),
                             format = "%d-%B-%Y")
        print(datenow)
        current_date <- datenow
        current_asin <- NA
        next
      }

      if (grepl(line, pattern = ".+(B0[89]+[A-Z0-9]+).*|^https://amzn.to/.+")) {
        print(line)
        if (grepl(line, pattern = "^https://amzn.to/.+")) {
          resp <- httr::GET(line)
          line <- resp$url
          print("NEW LINE")
          print(line)
        }

        if (! grepl(line, pattern = ".+(B0[89]+[A-Z0-9]+).*")) {
          next
        }
        if (is.na(current_date)) {warning("ERROR AT ", line,  " --- ", i); next}
        asin <- gsub(line, pattern = ".+(B0[89]+[A-Z0-9]+)[ /\\?#&].*", replacement = "\\1")
        asin <- gsub(asin, pattern = ".+(B0[89]+[A-Z0-9]+)$", replacement = "\\1")
        print(asin)


        res <- c(res, list(data.frame(
        'date' = datenow,
        'asin' = asin
        )))

        current_date <- NA
        current_asin <- NA
      }
    }
    date_asin <- bind_rows(res)

    df <- date_asin %>%
      mutate(category = cat_now) %>%
      write_csv(paste0("config/choose_asin/", cat_now, ".csv"))

  } else {
    print("Loading")
    df <- read_csv(paste0("config/choose_asin/", cat_now, ".csv"))
  }


  df %>%
  mutate(date = as.Date(date)) %T>%
   {ggplot(data = ., aes(x = date, fill = asin)) +
    geom_bar(width = 1) +
    facet_wrap(~asin) +
    labs(title = cat_now) +
    ggsave(filename = paste0("config/choose_asin/", cat_now, ".png"), height = 8, width = 8)}

  return(df)

})

library(lubridate)
final_df <- bind_rows(dflist)
final_df %>%
  mutate(date = as.Date(date)) %>%
  filter(! category %in% c("rtx3070ti", "rtx3080ti")) %>%
  filter(date >= as.Date("21-06-05")) %>%
  group_by(category, asin) %>%
  tally() %>%  arrange(desc(n)) -> countdf

drops <- countdf[1:10,]
write_csv(drops, file = "config/drops.csv")

tb <- table(drops$category)

price_df <- data.frame(
  category = c('rtx3060', 'rtx3060ti', 'rtx3070', 'rtx3080'),
  low = c(350, 350, 500, 500),
  high = c(700, 800, 850, 1200)
)
drops_and_price <- dplyr::left_join(drops, price_df)

resl <- lapply(rownames(drops_and_price), function (row) {
  rownow <- drops_and_price[row,]
  list(
    asins = c(rownow$asin),
    "min-price" = rownow$low,
    "max-price" = rownow$high,
    "condition" = "Any"
  )
})

resl2 <- list(
    "items" = rep(resl, 5),
    "amazon_domain" = "smile.amazon.com"
)
system('mv config/amazon_aio_config.json config/amazon_aio_config.tester.json')
jsonlite::write_json(x = resl2, pretty = T, path = "config/amazon_aio_config.json")



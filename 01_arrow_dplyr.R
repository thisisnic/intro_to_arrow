library(arrow)
library(dplyr)

# dataset - transcripts from The Office (US version)
?schrute::theoffice

# convert to an Arrow table for this demo
the_office <- open_dataset("data/transcripts")

# which character has the most lines in the show?
the_office %>%
  group_by(character) %>%
  summarise(lines = n()) %>%
  arrange(desc(lines)) %>%
  collect()

# in which episodes are beets mentioned?
beets <- office_table %>%
  filter(str_detect(text, "beets"))

# this is an in-memory dataset
beets

# how many rows? we can call functions like this as with a tibble
nrow(beets)

# let's collect and view
beets %>%
  select(character, text) %>%
  collect()

# which episode is the "same picture" meme from?
the_office %>%
  filter(grepl("the same picture", text)) %>%
  collect()

# which characters have most lines per season? let's plot it (with their full names)
library(ggplot2)
plot_data <- function(data){
  ggplot(aes(x = season, y = n, color = name), data = data) +
    geom_line(size = 2) +
    theme_minimal(base_size = 14) +
    scale_x_continuous(name = "Season", breaks =  c(1:9))
}

character_full_names <- arrow::read_csv_arrow("data/the_office_characters.csv", as_data_frame = FALSE)

the_office %>%
  group_by(season, character) %>%
  summarise(n = n()) %>%
  right_join(character_full_names, by = c("character" = "forename")) %>%
  mutate(name = paste(character, surname)) %>%
  select(season, name, n) %>%
  collect() %>%
  plot_data()

# Function to use at end of 01_arrow_dplyr.R - saved here so can source in
# instead of typing out
plot_data <- function(data){
  ggplot(aes(x = season, y = n, color = name), data = data) +
    geom_line(size = 2) +
    theme_minimal(base_size = 14) +
    scale_x_continuous(name = "Season", breaks =  c(1:9))
}

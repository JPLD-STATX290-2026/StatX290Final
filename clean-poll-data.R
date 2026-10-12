library(tidyverse)

# Election Results Clean --------------------------------------------------

# Read .csv file for election results 1976-2024
raw_election_results <- read.csv("Data/Raw/1976-2024-president.csv")

# Remove unneeded identifications
clean_election_results <- raw_election_results %>%
  select(-party_detailed, -version, -notes, -writein, -state_fips, -state_cen, -state_po, -state_ic, -office)

clean_election_results <- clean_election_results %>%
  # Classify parties into three categories
  mutate(
    party_simplified = case_when(
      party_simplified == "DEMOCRAT" ~ "DEMOCRAT",
      party_simplified == "REPUBLICAN" ~ "REPUBLICAN",
      party_simplified == "LIBERTARIAN" ~ "OTHER",
      TRUE ~ "OTHER"
    ),
    candidate = if_else(
      party_simplified == "OTHER",
      "OTHER",
      candidate
    )
  ) %>% 
  # Groups state election results for each party
  group_by(
    year,
    state,
    party_simplified,
    totalvotes
  ) %>%
  # Combines other classified party votes
  summarise(
    candidatevotes = sum(candidatevotes, na.rm = TRUE),
    .groups = "drop"
  )
# New derived variable for percentage of total votes
clean_election_results <- clean_election_results %>% 
  mutate(
    vote_percent = round((candidatevotes / totalvotes)*100, 2)
  )

write.csv(clean_election_results, "Data/Clean/1976-2024-president_clean.csv", row.names = FALSE)

# 2012 Poll Clean ---------------------------------------------------------

# Vector of election dates for 2012 and 2016
election_day <- c("2012" = as.Date("2012-11-06"),
                  "2016" = as.Date("2016-11-08"))

# Read the raw 2012 polling data from the data/raw folder
data_2012_poll <- read_csv("Data/Raw/state_polls_2012.csv")

# Clean the 2012 polling data
data_clean_2012_poll <- data_2012_poll %>% 
  mutate(
    # Convert start and end dates from character strings to Date objects
    start_date = as.Date(start_date),
    end_date = as.Date(end_date),
    
    # Calculate the number of days between the end of each poll
    # and the 2012 election day
    days_to_election = as.integer(election_day["2012"] - end_date)
  )

# Replace "Not included in poll" with NA in the Other column 
# so the column can be treated as numeric
data_clean_2012_poll <- data_clean_2012_poll %>%
  mutate(
    Other = na_if(Other, "Not included in poll")
  )

# Convert the Other column from character to integer
# after replacing "Not included in poll" with NA
data_clean_2012_poll <- data_clean_2012_poll %>%
  mutate(
    Other = as.integer(Other)
  )

# Convert categorical variables to factors
data_clean_2012_poll <- data_clean_2012_poll %>%
  mutate(
    mode = factor(mode),
    sample_subpopulation = factor(sample_subpopulation),
    partisanship = factor(partisanship),
    partisan_affiliation = factor(partisan_affiliation)
  )

# Save the cleaned dataset to the data/clean folder
# row.names = FALSE prevents R from adding row numbers as an extra column
write.csv(
  data_clean_2012_poll,
  "data/clean/state_polls_2012_clean.csv",
  row.names = FALSE
)

# 2016 Poll Clean ---------------------------------------------------------

# Loading in the raw 2016 state polling data
data_2016_poll <- read_csv("data/raw/state_polls_2016.csv")

# Create a cleaned version of this raw data which includes 'days to election'
# as a new variable which will be used for exploratory analysis later
data_clean_2016_poll <- data_2016_poll |>
  mutate(
    start_date = as.Date(start_date),
    end_date   = as.Date(end_date),
    days_to_election = as.integer(election_day["2016"] - end_date)
  )


# Classify all non-entries as hard NA's to make later plotting easier
data_clean_2016_poll <- data_clean_2016_poll %>% mutate(
  Other = na_if(Other, "Not included in poll")
)

# Change multiple variables from characters to factors to create distinct groups
# within the variables
data_clean_2016_poll <- data_clean_2016_poll %>% mutate(
  mode = factor(mode),
  sample_subpopulation = factor(sample_subpopulation),
  partisanship = factor(partisanship),
  partisan_affiliation = factor(partisan_affiliation)
)

# Change the 'other' variable to be of type integer rather than character
data_clean_2016_poll <- data_clean_2016_poll %>% mutate(
  Other = as.integer(Other)
) 

# Write the cleaned dataset to its own csv file for easier further use
write.csv(data_clean_2016_poll, "Data/Clean/state_polls_2016_clean.csv", row.names = FALSE)


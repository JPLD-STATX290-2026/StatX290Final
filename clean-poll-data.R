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

# New derived variables for share of total votes
# vote_election: proportion (0-1), not rounded so no accuracy is lost
# vote_percent:  percentage (0-100), rounded to 2 decimal places
clean_election_results <- clean_election_results %>% 
  mutate(
    vote_election = candidatevotes / totalvotes,
    vote_percent  = round(vote_election * 100, 2)
  )

write.csv(clean_election_results, "Data/Clean/1976-2024-president_clean.csv", row.names = FALSE)

# Actual Democrat and Republican result (percent) and margin for each state and year.
# Used to measure how far a poll's margin was from the real result.
actual_results <- clean_election_results %>%
  filter(party_simplified %in% c("DEMOCRAT", "REPUBLICAN")) %>%
  select(year, state, party_simplified, vote_percent) %>%
  pivot_wider(names_from = party_simplified, values_from = vote_percent) %>%
  rename(act_dem = DEMOCRAT, act_rep = REPUBLICAN) %>%
  mutate(act_margin = act_dem - act_rep)

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
    days_to_election = as.integer(election_day["2012"] - end_date),
    Undecided = replace_na(Undecided, 0),
    vote_poll = (Obama/(100-Undecided)),
    dem = Obama,
    rep = Romney,
    # A sample size of -1 is not a real value, so treat it as missing
    sample_size = replace(sample_size, sample_size <= 0, NA),
    year = str_extract(poll_info, "^\\d{4}"),
    state = str_extract(poll_info, "(?<=^\\d{4}-).*?(?=-president)")
  )

# Make state names match the election results file.
data_clean_2012_poll <- data_clean_2012_poll %>%
  mutate(
    state = state %>%
      str_replace(regex("^washington-d-?c$", ignore_case = TRUE), "DISTRICT OF COLUMBIA") %>%
      str_replace_all("\\.", "") %>%
      str_replace_all("-", " ") %>%
      str_to_upper()
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

# Drop columns no longer needed (dem and rep are kept)
data_clean_2012_poll <- data_clean_2012_poll %>% 
  select(-poll_info, -Obama, -Romney, -Undecided, -Other, -poll_id, -start_date, -end_date)

# Save the cleaned dataset to the data/clean folder
# row.names = FALSE prevents R from adding row numbers as an extra column
write.csv(
  data_clean_2012_poll,
  "Data/Clean/state_polls_2012_clean.csv",
  row.names = FALSE
)

# 2016 Poll Clean ---------------------------------------------------------

# Loading in the raw 2016 state polling data
data_2016_poll <- read_csv("Data/Raw/state_polls_2016.csv")

# Create a cleaned version of this raw data which includes 'days to election'
# as a new variable which will be used for exploratory analysis later
data_clean_2016_poll <- data_2016_poll %>%
  mutate(
    start_date = as.Date(start_date),
    end_date   = as.Date(end_date),
    days_to_election = as.integer(election_day["2016"] - end_date),
    Undecided = replace_na(Undecided, 0),
    vote_poll = (Clinton/(100-Undecided)),
    dem = Clinton,
    rep = Trump,
    sample_size = replace(sample_size, sample_size <= 0, NA),
    year = str_extract(poll_info, "^\\d{4}"),
    state = str_extract(poll_info, "(?<=^\\d{4}-).*?(?=-president)")
  )

data_clean_2016_poll <- data_clean_2016_poll %>%
  mutate(
    state = state %>%
      str_replace(regex("^washington-d-?c$", ignore_case = TRUE), "DISTRICT OF COLUMBIA") %>%
      str_replace_all("\\.", "") %>%
      str_replace_all("-", " ") %>%
      str_to_upper()
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

# Drop columns no longer needed (dem and rep are kept)
data_clean_2016_poll <- data_clean_2016_poll %>% 
  select(-poll_info, -Trump, -Clinton, -Undecided, -Other, -poll_id, -start_date, -end_date, -Johnson, -McMullin)

# Write the cleaned dataset to its own csv file for easier further use
write.csv(data_clean_2016_poll, "Data/Clean/state_polls_2016_clean.csv", row.names = FALSE)

# Combined Poll ---------------------------------------------------------

data_2012_16_poll <- bind_rows(data_clean_2012_poll, data_clean_2016_poll)

combined_data <- data_2012_16_poll %>%
  mutate(year = as.integer(year)) %>%
  # Democrat share of the vote as a proportion (used for poll_election_dif)
  left_join(
    clean_election_results %>%
      filter(party_simplified == "DEMOCRAT") %>%
      select(year, state, vote_election),
    by = c("year", "state")
  ) %>%
  # Actual Democrat %, Republican % and margin
  left_join(actual_results, by = c("year", "state"))

combined_data <- combined_data %>%
  mutate(
    poll_election_dif = vote_election - vote_poll
  )

# The join must not add rows, and every poll must find its state result
stopifnot(nrow(combined_data) == nrow(data_2012_16_poll))
stopifnot(!anyNA(combined_data$act_margin))

write.csv(combined_data, "Data/Clean/combined_data.csv", row.names = FALSE)
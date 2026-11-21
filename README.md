# Accuracy of Polled Data in Predicting Presidential Results

<!-- badges: start -->
![R](https://img.shields.io/badge/language-R-blue)
![Quarto](https://img.shields.io/badge/report-Quarto-75aadb)
![Tidyverse](https://img.shields.io/badge/package-tidyverse-1f77b4)
![ggplot2](https://img.shields.io/badge/visualisation-ggplot2-orange)
<!-- badges: end -->

This repository contains the group **final report** for **STAT X290 - Statistical Practice** group **JPLD** at Adelaide University. It builds on the earlier Exploratory Data Analysis (EDA) report, to answer three research questions in depth.

The project investigates how accurately state-level US presidential polls matched the actual results in 2012 and 2016, and whether the way a poll was run (mode, sampled population, partisanship, sample size, timing) is related to how accurate it was. The repository contains the data cleaning script, the cleaned datasets, and the source of the final report.

## Project Objectives

The analysis focuses on:

- Measuring poll accuracy two ways: the size of the error in the poll's margin (percentage points) and whether the poll picked the right winner.
- Fitting linear and logistic regression models of accuracy for each election, and comparing models using hypothesis tests, AIC/BIC and a train/test split.
- Checking model assumptions and looking for any unusual or influential polls.
- Judging how well poll accuracy can be predicted from the characteristics of the poll.

## Research Questions

- **Main question:** How accurately can we predict the accuracy of a poll based on the sampled population?
- **Sub-question 1:** How do different methods and factors in a polled population affect the accuracy of polls?
- **Sub-question 2:** How much do unexpected results affect the accuracy of prediction?

## Summary of Findings

Across both elections, polls taken closer to election day were more accurate, while the sampled population (likely vs registered voters) showed no clear effect. Poll characteristics explained only a small share of the variation in polling error, and predicting a poll's accuracy from them performed little better than guessing. For the full analysis, results and limitations, refer to the final report.

## Datasets

The raw data are the same three datasets used in the EDA report.

| Dataset | Description |
|---------|-------------|
| `state_polls_2012.csv` | State-level pre-election polling data for the 2012 US Presidential Election. |
| `state_polls_2016.csv` | State-level pre-election polling data for the 2016 US Presidential Election. |
| `1976-2024-president.csv` | Certified state-level US presidential election returns from 1976–2024. |

`clean-poll-data.R` turns these into the cleaned files below.

| Cleaned file | Description |
|--------------|-------------|
| `state_polls_2012_clean.csv` | Cleaned 2012 polls. |
| `state_polls_2016_clean.csv` | Cleaned 2016 polls. |
| `1976-2024-president_clean.csv` | Cleaned election results with each candidate's share of the vote. |
| `combined_data.csv` | One row per poll (2012 and 2016), with the actual result for that poll's state attached. |

`combined_data.csv` is the one used throughout the report.

### Key variables in our dataset

| Variable | Description |
|----------|-------------|
| `dem`, `rep` | The poll's percentage for the Democratic and Republican candidate respectively. |
| `act_dem`, `act_rep` | The actual Democratic and Republican percentage of the vote in that state. |
| `act_margin` | Actual Democratic minus Republican margin (percentage points). |
| `mode` | How the poll was conducted (for example Live Phone, Internet). |
| `sample_subpopulation` | Population sampled (Likely Voters, Registered Voters or Adults). |
| `partisanship` | Whether the poll was nonpartisan, run by a partisan pollster, or sponsored. |
| `sample_size` | Number of respondents. |
| `days_to_election` | Days between the end of the poll and election day. |

### Variables created in the report

| Variable | Description |
|----------|-------------|
| `abs_err` | Absolute margin error: \|(`dem` − `rep`) − `act_margin`\| in percentage points. |
| `correct` | 1 if the poll's leader won the state, 0 if not (ties are excluded). |
| `signed_err` | Poll margin minus actual margin (positive means the poll overstated the Democrat). |
| `n1000` | Sample size in thousands (for ease of coefficient interpretation). |
| `mode3` | `mode` with categories of fewer than 30 polls in a year grouped as "Other". |

### Data Sources

- **2012 and 2016 polling data:** HuffPost Pollster project (archived).
- **1976–2024 presidential returns:** MIT Election Data and Science Lab.

## Project structure

These are the files where our analysis is located:
```
StatX290Final/
├── README.md                   # project overview
├── StatX290Final.Rproj
├── EDA.qmd                     # exploratory data analysis report
├── clean-poll-data.R           # reproducible data-cleaning process
├── report-template-pdf.qmd     # source of the final report (renders to PDF)
├── bibliography.bib            # Bibliography 
└── Data/
    ├── Raw/
    │   ├── state_polls_2012.csv
    │   ├── state_polls_2016.csv
    │   └── 1976-2024-president.csv
    └── Clean/
        ├── state_polls_2012_clean.csv
        ├── state_polls_2016_clean.csv
        ├── 1976-2024-president_clean.csv
        └── combined_data.csv
```

## Required Packages

The analysis uses the following R packages:

- `tidyverse` – data manipulation, importing and visualisation (`dplyr`, `tidyr`, `readr`, `forcats`, `stringr`, `ggplot2` and related packages)
- `car` – Type II ANOVA (`Anova()`), variance inflation factors (`vif()`) and Box-Cox transformations (`powerTransform()`)
- `rsample` – included to implement the 75/25 train/test split
- `knitr` – for nicely formatted tables
- `modelsummary` – for regression tables

Rendering the report to PDF also needs Quarto and a LaTeX installation (for example TinyTeX).

Install the packages with:

```r
install.packages(c(
  "tidyverse",
  "car",
  "rsample",
  "knitr",
  "modelsummary"
))
```

You can also install TinyTeX (if you do not already have LaTeX) with:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

## How to Reproduce the Analysis



The random seed is set, so the train/test split and the results in the report are reproducible. Note that the first PDF render on a new LaTeX installation can take several minutes while LaTeX packages are downloaded.

## Notes on the data

- Washington DC is recoded explicitly to "DISTRICT OF COLUMBIA" in `clean-poll-data.R` so that it is not merged with Washington State.
- In the report, polls of "Adults" (12 in total) are removed because there are too few to estimate separately.
- The "Other" category is removed for logistic model fitting, as all polls in this category accurately predicted the outcome of their election.

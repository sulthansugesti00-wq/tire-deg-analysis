# Tire deg analysis
I will explain it here

## This is a subheading
I don't know what to write here

# Change log
All notable changes will appear here 

## [1.0] - 2026 - 02 - 23
Finally did it
### Changed 
- Slope rate was misleading, now it’s 0.07

### Added 
- Added cumulative tire loss *Again*
- Aggregated data (Mean total laptime) there was a lot of duplicates so I changed it into grouping per lap
- N <- number of lap for easier math
- Added pit time 22 seconds
- Added slots allocation for results of for in loop
- Added for in loop, to count the optimal time by counting the total time needed for stint 1 and stint 2 + pit time delta.
- Added data frame from results of for In loop
- Added final plotting to find minimum total race time


## [0.2] - 2025-02-20
### Changed
- fuel effect from 0.28 s/kg -> 0.03 s/kg
- Change variables name for easier readability
- Changing column names for easier readability
- Removing unnecessary comments and code for easier readability

### Added 
- Add a graph for pre-fuel correction and post-fuel correction

### Removed
- Cumulative tire deg calculation
- Plot cumulative tire deg

## [0.1] - 2025-02-18
### Added 
- Cleaned data
- Fuel corrected calculation
- Necessary variable for corrected fuel time (Current fuel, fuel load)
- Plot tire deg
- Plot cumulative tire deg time loss
- Tire deg model Linear
- Degradation slope

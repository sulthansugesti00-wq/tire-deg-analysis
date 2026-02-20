library(pacman)
p_load(tidyverse, readr, ggplot2, dplyr, stats)


# Read csv raw
raw_data <- read_csv("data/tire_deg.csv")

# Modifying ms to seconds
raw_data <- raw_data %>%
  mutate(Laptime=round(LapTimeMs/1000,2))

# cleaning data (aligning with context)
cleaned_data <- raw_data %>% 
  filter(Lap!=0) %>% 
  select(Lap, Laptime)

# Fuel correction and preparing plotting ----
fuel_corrected <- cleaned_data %>% 
  mutate(current_fuel=54.23-(3.19*Lap),
         corrected_laptime_fuel=round(Laptime-(current_fuel*0.03),2)
           )

#Fuel effect 0.03 s/kg

# Plotting pre-fuel correction ----
fuel_corrected %>% 
  ggplot(aes(x=Lap, y=Laptime))+geom_point()+geom_smooth(method='lm')

# Plotting w fuel correction ----
fuel_corrected %>% 
  ggplot(aes(x=Lap, y=corrected_laptime_fuel))+geom_point()+geom_smooth(method='lm')

# tire_deg model
tire_deg_model <- fuel_corrected %>% 
  lm(corrected_laptime_fuel~Lap, data=.)
# degradation rate slope
deg_rate <- coef(tire_deg_model)[2] #[1] is intercept
print(paste("Time lost due to deg per lap is~", round(deg_rate,2)))

## When to pit ----


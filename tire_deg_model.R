library(pacman)
p_load(tidyverse, readr, ggplot2, dplyr, stats)


# Read csv raw
raw_data <- read_csv("data/tire_deg.csv")

# Modifying ms to seconds | Ignore temp and pres (Not used)
modified_data <- raw_data %>% 
  mutate(laptime= round(LapTimeMs/1000,2),
         tyretemp= round(mean(c(TempFL,TempFR,TempRL,TempRR)),1),
         pressure=round(mean(c(PresFL,PresFR,PresRL,PresRR)),1)
         )


# Fuel correction and preparing plotting ----
tire_corrected <- modified_data %>% 
  select(Lap, laptime) %>% 
  mutate(current_fuel = 54.23 - (3.19*Lap), 
         corrected_fuel_time = round(laptime-(current_fuel*0.28),1)) 

#Fuel effect 0.28 s/kg

# Plotting w fuel correction ----
tire_corrected %>% 
  filter(Lap!=0) %>% 
  ggplot(aes(x=Lap, y=corrected_fuel_time))+
           geom_point()+
           geom_smooth(method = "lm")

# tire_deg model
tire_deg_model <- tire_corrected %>% 
  filter(Lap != 0) %>% 
  lm(corrected_fuel_time ~ Lap, data = .)
# degradation rate slope
deg_rate <- coef(tire_deg_model)[2]
print(paste("Time lost due to deg per lap is~", round(deg_rate,2)))

# Cumulative tire deg time loss (arithmetic) ----
tire_cumulative <- tire_corrected %>% 
  mutate(cumulative_loss = round(deg_rate * (Lap*(Lap-1)/2),2)
         )

## When to pit ----
# I will be using Cumulative deg overlap the cost of pitting (22 seconds)
# So what is it exactly? Tyre deg itself has a time loss so cumulative would represent the loss of time due to tire deg, so we pit right before it exceeds pitting time but not above, if we pit early we would waste the tire life, and if it's too late we lost lots of time due to pitting time + Tire deg cumulative.
tire_cumulative %>% 
  filter(Lap!=0) %>% 
  ggplot(aes(x=Lap, y=cumulative_loss))+geom_line(color="steelblue")+geom_hline(yintercept = 22, linetype="dashed", color ="red")+coord_cartesian(ylim=c(10, 50), xlim = c(1, 10))

# Optimal lap (W cumulative loss)
optimal_pit <- tire_cumulative %>% 
  filter(Lap!=0, cumulative_loss >=22) %>%
  slice(1) %>% 
  pull(Lap)

print(paste("Optimal pit window :", optimal_pit))
  

#----
## Predictive
future_data <- data.frame(Lap=25)

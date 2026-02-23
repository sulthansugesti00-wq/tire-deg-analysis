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
# Slope rate is ~ 0.07

# cumulative tire loss sn = n/2 (a1+an)
cumulative_tire_loss <- fuel_corrected %>% 
  mutate(an = deg_rate+(Lap-1)*deg_rate,
    cumulative_loss = Lap/2*(deg_rate+an)) %>% 
  select(Lap, current_fuel, corrected_laptime_fuel, cumulative_loss)

# total laptime with fuel corrected
aggregated_data <- cumulative_tire_loss %>% 
  mutate(total_laptime=corrected_laptime_fuel+cumulative_loss) %>% 
  select(Lap, total_laptime) %>% 
  group_by(Lap) %>% 
  summarise(total_laptime=mean(total_laptime))

n <- nrow(aggregated_data)
pit_time <- 22
optimal_pit <- vector("numeric", length = (n-1))

for (k in 1:(n-1)){
  optimal_pit[k] <- sum(aggregated_data$total_laptime[1:k]) + sum(aggregated_data$total_laptime[1:(n-k)]) +pit_time
}

optimal_pit_data <- tibble(
  total_time = c(optimal_pit),
  pit_lap = c(1:(n-1)) #n-1 for easy change
)

# Plotting optimal pit
ggplot(data=optimal_pit_data,aes(x=pit_lap, y=total_time))+geom_line(color="steelblue")+geom_vline(xintercept = which.min(optimal_pit_data$total_time),linetype="dashed"
)

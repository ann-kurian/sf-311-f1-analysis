rm(list = ls())
setwd("~/Desktop/MSMI_Applied Statistics/Pre Class Assignment")

install.packages("janitor")
library(tidyverse)
library(lubridate)
library(scales)
library(janitor)
library(broom)
library(ggplot2)

# F1 Showrun Analysis
# Marina vs Average of All Other Neighborhoods
 
# 1. Read dataset
 
data <- read.csv("311_Cases_20260307.csv", stringsAsFactors = FALSE)
data <- data %>% clean_names()

 
# 2. Convert opened column to date
 
data$date <- mdy_hms(data$opened)
data$date <- as.Date(data$date)

 
# 3. Aggregate complaints per day per neighborhood
 
daily_complaints <- data %>%
  group_by(neighborhood, date) %>%
  summarise(complaints_count = n(), .groups = "drop")

 
# 4. Clean neighborhood names
 
daily_complaints <- daily_complaints %>%
  mutate(neighborhood = str_to_title(neighborhood))
#unique(daily_complaints$neighborhood)
#daily_complaints[1000:1010, ]
 
# 5. Filter relevant timeframe
 
daily_complaints <- daily_complaints %>%
  filter(date >= as.Date("2026-01-01") &
           date <= as.Date("2026-03-01"))
#is filtering out the dates this way fine?
#not sure if adding days from 2025 is relevant to this analysis 
#but also not entirely sure if this is an adequately sized sample to confirm the findings
 
# 6. Create control group = average of all other neighborhoods
 
marina_data <- daily_complaints %>%
  filter(neighborhood == "Marina")
#nrow(daily_complaints[daily_complaints$neighborhood=="Marina", ])
#nrow(daily_complaints[daily_complaints$neighborhood!="Marina", ])

control_data <- daily_complaints %>%
  filter(neighborhood != "Marina") %>%
  group_by(date) %>%
  summarise(
    complaints_count = mean(complaints_count),
    neighborhood = "Other Neighborhoods",
    .groups = "drop")
#length(daily_complaints[daily_complaints$neighborhood!="Marina", ]$date)
#length(unique(daily_complaints[daily_complaints$neighborhood!="Marina", ]$date))

# Combine treatment + control
analysis_data <- bind_rows(marina_data, control_data)
#unique(analysis_data$neighborhood)
#nrow(analysis_data[analysis_data$neighborhood=="Marina", ])
 
# 7. Define event window
 
event_start <- as.Date("2026-02-20")
event_end <- as.Date("2026-02-22")
#setting a larger window than the actual event day to account for any disruptions caused prior to
#and a day after the event (is that fine?)

analysis_data <- analysis_data %>%
  mutate(period = case_when(
    date < event_start ~ "pre_event",
    date >= event_start & date <= event_end ~ "event_period",
    date > event_end ~ "post_event"
  ))

 
# 8. Visualization: Time series
 
ggplot(analysis_data,
       aes(x=date, y=complaints_count, color=neighborhood)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(event_start),
             linetype="dashed", color="red") +
  geom_vline(xintercept = as.numeric(event_end),
             linetype="dashed", color="red") +
  labs(
    title="Marina vs Average of Other Neighborhoods",
    subtitle="Impact of F1 Showrun",
    x="Date",
    y="Average Daily Complaints"
  ) +
  theme_minimal()
#we note that the number of complaints coming in from the Marina is generally higher on average
#F1 Showrun caused a temporary but significant increase in complaints in the Marina
#while the rest of the city remained largely unaffected

 
# 9. Prepare variables for DiD
 
analysis_data$marina_flag <- ifelse(analysis_data$neighborhood == "Marina", 1, 0)
analysis_data$event_flag <- ifelse(analysis_data$period == "event_period", 1, 0)
#nrow(analysis_data[analysis_data$marina_flag==1, ])

# 10. Difference-in-Differences Regression
 
did_model <- lm(complaints_count ~ marina_flag * event_flag,
                data = analysis_data)

# Regression summary
summary(did_model)
#the result tells us that the Marina experienced a surge of 12.31 complaints per day 
#on during the event period and this is statistically significant

# Tidy output
tidy_did <- tidy(did_model)
tidy_did

 
# 11. DiD Visualization
 
# Create the did_summary data frame to calculate the averages
did_summary <- analysis_data %>%
  group_by(neighborhood, period) %>%
  summarise(avg_complaints = mean(complaints_count, na.rm = TRUE), .groups = "drop")
#did_summary

# Factor the periods so they graph in the correct chronological order
did_summary$period <- factor(did_summary$period, levels = c("pre_event", "event_period", "post_event"))
#did_summary$period

# Clean DiD plot
ggplot(did_summary, aes(x = period, y = avg_complaints, color = neighborhood, group = neighborhood)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_text(aes(label = round(avg_complaints, 1)), vjust = -1, show.legend = FALSE) +
  labs(
    title = "Difference-in-Differences: Complaints in Marina vs Other Neighborhoods",
    subtitle = "F1 Showrun Impact",
    x = "Period",
    y = "Average Daily Complaints",
    color = "Neighborhood"
  ) +
  theme_minimal() +
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.2))) # Adds vertical space so top text labels don't get cut off
#the clear temporary spike in complaints in the Marina imply that it is a sole result of the event
#the other neighbourhoods which we've set as control remains stable throughout
#hence we conclude that the spike in the Marina neighbourhood can be isolated as an aftereffect of 
#the event and it's not a citywide trend

 
# 12. Most Common Complaints in Marina During Event
 

# Filter Marina complaints during the event period
marina_event_complaints <- data %>%
  filter(neighborhood == "Marina",
         date >= event_start & date <= event_end)
#unique(marina_event_complaints$date)

# Count complaints by type
complaint_counts <- marina_event_complaints %>%
  group_by(request_type) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count))
#length(unique(marina_event_complaints$request_type))
#complaint_counts

# Show top 10 complaint types
top_complaints <- head(complaint_counts, 10)
top_complaints

 
# 13. Visualization of Top Complaint Types
 
ggplot(top_complaints, aes(x = reorder(request_type, count), y = count)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top Complaint Types in Marina During F1 Showrun",
    x = "Complaint Type",
    y = "Number of Complaints"
  ) +
  theme_minimal()
#blocked driveways was the most common problem encountered by the residents in the Marina
#24 complaints requested for a citation for the blocking vehicle and 
#22 requested for citation and towing, which implies that those were cases where the driveway 
#was completely blocked


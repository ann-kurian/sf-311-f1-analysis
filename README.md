# SF 311 & the F1 Showrun
### Measuring the causal impact of a major urban event on city service complaints

![R](https://img.shields.io/badge/R-4.3%2B-276DC3?logo=r)
![Method](https://img.shields.io/badge/Method-Difference--in--Differences-1A7A6E)
![Data](https://img.shields.io/badge/Data-SF%20311%20Open%20Data-1C2B4A)
![Status](https://img.shields.io/badge/Status-Complete-22C55E)

---

## Overview

In February 2026, Formula 1 brought its Showrun event to the Marina neighborhood in San Francisco. This project uses the city's publicly available 311 service request data to measure — rigorously and causally — how much the event increased complaint volume in the Marina, while controlling for citywide trends.

**[→ Read Full Case Study](case_study.html)**

---

## Research Question

> Did the F1 Showrun cause a statistically significant increase in 311 complaints in the Marina neighborhood, controlling for citywide trends?

---

## Key Finding

The Difference-in-Differences regression isolates a **+12.31 complaints per day** causal effect attributable to the F1 Showrun in the Marina — statistically significant, and not reflected in any other San Francisco neighborhood during the same period.

---

## Results Summary

| Finding | Result |
|---|---|
| DiD estimate (interaction term) | **+12.31 complaints/day** (statistically significant) |
| Effect on other neighborhoods | Near zero — citywide trend unaffected |
| Marina baseline vs. city average | Structurally higher even pre-event |
| Top complaint type during event | Blocked Driveway — Citation Requested (24 cases) |
| Second complaint type | Blocked Driveway — Citation & Tow (22 cases) |

---

## Methodology

**Difference-in-Differences (DiD)** — a quasi-experimental method used in economics and policy research to estimate causal effects from observational data.

- **Treatment group:** Marina neighborhood daily complaint counts
- **Control group:** Average daily complaints across all other SF neighborhoods
- **Event window:** Feb 20–22, 2026 (day before + event day + day after)
- **Analysis period:** Jan 1 – Mar 1, 2026
- **Model:** `lm(complaints_count ~ marina_flag * event_flag)`

The interaction coefficient (`marina_flag × event_flag`) gives the DiD estimate — the causal effect of the event on Marina complaints, net of any citywide trends.

---

## Dataset

**SF 311 Cases — DataSF**
- Source: https://data.sfgov.org/City-Infrastructure/311-Cases/vw6y-z8j6
- Filter: Supervisor District 2, Jan 1 – Mar 1 2026
- Each row = one service request with timestamp, neighborhood, complaint type, status

---

## How to Run

### Prerequisites
```r
install.packages(c("tidyverse", "lubridate", "scales", "janitor", "broom"))
```

### Steps
1. Download the 311 dataset from DataSF (link above) — export as CSV
2. Save as `311_Cases_20260307.csv` in the same directory as the R script
3. Run `311_Complaints_Analysis.R`

The script produces:
- Time series chart: Marina vs. average of other neighborhoods
- DiD visualization: average complaints by period and neighborhood
- Top 10 complaint types bar chart
- Regression summary with the DiD estimate

---

## File Structure

```
sf-311-f1-analysis/
├── 311_Complaints_Analysis.R    ← main analysis script
├── case_study.html              ← full portfolio case study
└── README.md
```

---

## Tools

`R` `tidyverse` `lubridate` `ggplot2` `janitor` `broom` `SF Open Data`

---

*Portfolio project by Ann Mary Kurian — MS Marketing Intelligence, University of San Francisco*
*Applied Statistics coursework — Difference-in-Differences causal inference*

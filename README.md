# Compound Hot–Dry Extremes in Southeastern Türkiye

## Changes in Compound Temperature and Drought Extremes in Southeastern Türkiye

### Author
**Aydın Solmaz**

---

## Overview

Compound climate extremes occur when two or more adverse climate conditions occur simultaneously or within a closely connected period. Among these events, the simultaneous occurrence of unusually high temperatures and drought represents an important climate risk because their combined effects can be substantially greater than the effects of either hazard occurring independently.

This project investigates the temporal evolution of **compound hot–dry extremes in Southeastern Türkiye** using long-term climate data and statistical time-series analysis.

Rather than examining temperature and drought independently, the study focuses on their **joint occurrence, frequency, duration, and intensity**.

The analysis is designed and conducted by **Aydın Solmaz** using the R statistical environment and NASA POWER climate data.

---

## Research Questions

The study addresses the following questions:

1. How has the frequency of compound hot–dry events changed over time?
2. Has the duration of compound hot–dry events increased?
3. Has the intensity of these events changed during the study period?
4. Are compound hot–dry events becoming more persistent?
5. Are there statistically significant temporal trends in compound extremes?
6. Have major structural changes occurred in the compound-extreme time series?

---

## Study Region

The study focuses on **Southeastern Türkiye**, a climatically sensitive region characterized by hot summers, pronounced seasonal precipitation variability, and recurrent dry conditions.

The region provides an appropriate case study for investigating compound hot–dry extremes because increasing temperatures and precipitation variability may increase the likelihood of simultaneous heat and drought conditions.

---

## Data

Climate data are obtained from the **NASA Prediction of Worldwide Energy Resources (NASA POWER)** dataset.

The primary variables include:

- Air temperature
- Precipitation
- Monthly climate observations

The analysis is conducted using a long-term monthly time series.

### Data Processing

The general workflow consists of:

**NASA POWER Data → Quality Control → Monthly Time Series → Temperature Extremes → SPI → Compound Event Detection → Statistical Analysis**

---

## Methodological Framework

### 1. Temperature Extremes

Temperature anomalies are calculated from the long-term temperature distribution.

A percentile-based threshold is used to identify unusually warm conditions.

A month is classified as a **hot extreme** when its temperature exceeds the predefined percentile threshold.

The baseline threshold is defined using the:

**90th percentile (P90)**

---

### 2. Drought Identification

Meteorological drought conditions are identified using the:

**Standardized Precipitation Index (SPI)**

SPI is calculated from precipitation data and provides a standardized measure of precipitation deficits.

For the compound-event analysis, a short-to-medium accumulation period such as **SPI-3** is used to capture relatively persistent precipitation deficits.

A drought condition is defined when:

**SPI ≤ -1.0**

---

### 3. Compound Hot–Dry Events

A compound hot–dry event is identified when both conditions occur simultaneously:

**Temperature ≥ 90th percentile**

AND

**SPI ≤ -1.0**

This definition allows the study to distinguish compound events from isolated heat or drought events.

---

## Compound Event Characteristics

For each identified compound event, several characteristics are calculated:

### Frequency

The number of compound hot–dry events occurring during each year.

### Duration

The number of consecutive months affected by compound hot–dry conditions.

### Maximum Duration

The longest uninterrupted compound hot–dry episode recorded during each year.

### Intensity

The combined severity of anomalously high temperature and precipitation deficit.

### Persistence

The tendency of compound hot–dry conditions to continue across consecutive months.

---

## Statistical Analysis

The temporal evolution of compound hot–dry extremes is evaluated using several statistical approaches.

### Trend Analysis

- Mann–Kendall Trend Test
- Sen's Slope Estimator
- Spearman Rank Correlation

These methods are used to evaluate the direction, magnitude, and statistical significance of temporal changes.

### Change-Point Analysis

The **Pettitt Change-Point Test** is applied to identify potential abrupt shifts in the statistical characteristics of the compound-extreme series.

### Time-Series Analysis

Additional descriptive time-series analysis is used to investigate:

- Temporal persistence
- Event clustering
- Long-term variability
- Changes in event frequency
- Changes in event duration
- Changes in event intensity

---

## Analytical Workflow

```text
NASA POWER Climate Data
          │
          ▼
    Data Quality Control
          │
          ▼
     Monthly Time Series
          │
     ┌────┴────┐
     ▼         ▼
Temperature   Precipitation
     │         │
     ▼         ▼
  P90 Heat     SPI-3
 Threshold     │
     │         │
     └────┬────┘
          ▼
Compound Hot–Dry Detection
          │
          ▼
 ┌────────┼─────────┐
 ▼        ▼         ▼
Frequency Duration Intensity
          │
          ▼
 Statistical Analysis
          │
    ┌─────┼─────┐
    ▼     ▼     ▼
   MK    Sen   Pettitt
          │
          ▼
   Climate Interpretation

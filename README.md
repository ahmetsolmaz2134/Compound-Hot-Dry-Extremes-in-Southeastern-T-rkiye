# Compound Hot–Dry Extremes in Southeastern Türkiye

## Changes in Compound Temperature and Drought Extremes in Southeastern Türkiye (1981–2025)

**Author:** **Ahmet Solmaz**

**Research Type:** Independent climatological and statistical research
**Study Region:** Southeastern Türkiye
**Study Period:** 1981–2025
**Temporal Resolution:** Monthly
**Primary Data Source:** NASA POWER
**Statistical Environment:** R

---

## 1. Overview

Compound climate extremes occur when two or more adverse climatic conditions occur simultaneously or within a closely connected temporal period. Among these phenomena, the simultaneous occurrence of unusually high temperatures and precipitation deficits represents a particularly important climate risk because the combined effects of heat and drought can substantially exceed the impacts of either hazard considered independently.

This project investigates the temporal evolution, frequency, duration, persistence, and severity of **compound hot–dry extremes in Southeastern Türkiye during 1981–2025**.

The analysis integrates temperature extremes and meteorological drought within a unified statistical framework. Rather than treating heat and drought as independent climate hazards, the study identifies periods in which **unusually high temperatures and drought conditions occur concurrently**.

The methodological framework combines:

* Percentile-based temperature extremes;
* The Standardized Precipitation Index (SPI);
* Compound hot–dry event detection;
* Annual event frequency;
* Event duration;
* Maximum consecutive duration;
* Event severity;
* Mann–Kendall trend analysis;
* Sen's slope estimation;
* Spearman rank correlation;
* Pettitt change-point analysis;
* Pre- and post-change-point comparison;
* Temporal persistence and clustering analysis.

The complete workflow was independently designed, processed, analyzed, and visualized by **Ahmet Solmaz** using R and NASA POWER climate data.

---

# 2. Research Objectives

The principal objective is to determine whether compound hot–dry conditions have changed systematically across Southeastern Türkiye during 1981–2025.

The study specifically examines:

1. How temperature conditions have changed during the study period;
2. How the frequency of extreme-temperature months has evolved;
3. How the spatial and temporal characteristics of P90 temperature thresholds vary;
4. How meteorological drought conditions have changed;
5. How frequently hot and dry conditions occur simultaneously;
6. Whether compound hot–dry events are becoming more frequent;
7. Whether compound events are becoming longer-lasting;
8. Whether compound-event severity has changed;
9. Whether compound events exhibit statistically significant monotonic trends;
10. Whether abrupt structural changes have occurred within the compound-event time series;
11. Whether temperature extremes and compound-event characteristics exhibit significant statistical associations.

---

# 3. Study Region

Southeastern Türkiye is characterized by:

* Hot and dry summers;
* Strong seasonal precipitation variability;
* High interannual climatic variability;
* Pronounced summer moisture deficits;
* Recurrent meteorological drought;
* Increasing exposure to extreme heat;
* Strong sensitivity of agricultural and water systems to climatic extremes.

These characteristics make the region particularly suitable for investigating compound hot–dry hazards.

The simultaneous occurrence of extreme heat and drought is especially important because high temperatures can increase atmospheric evaporative demand while precipitation deficits reduce available moisture. Consequently, the combination may amplify environmental and socioeconomic impacts.

---

# 4. Data

## 4.1 NASA POWER Climate Data

The analysis uses monthly climate data obtained from the **NASA Prediction of Worldwide Energy Resources (NASA POWER)** dataset.

The repository contains the processed regional dataset:

`Guneydogu_NASA_POWER_1981_2025_Monthly.csv`

The long-term monthly record provides the basis for constructing temperature extremes, drought indicators, and compound-event indicators.

### Main climatic variables

* Air temperature;
* Precipitation;
* Monthly temporal observations.

The analysis period extends from **1981 to 2025**, providing a 45-year climatological time series.

---

# 5. Data Processing

The analytical workflow follows the sequence:

```text
NASA POWER Climate Data
          │
          ▼
Data Quality Control
          │
          ▼
Monthly Climate Time Series
          │
     ┌────┴─────┐
     ▼          ▼
Temperature  Precipitation
     │          │
     ▼          ▼
    P90        SPI-3
     │          │
     └────┬─────┘
          ▼
Compound Hot–Dry Detection
          │
          ▼
 ┌────────┼─────────┐
 ▼        ▼         ▼
Frequency Duration Severity
 │        │         │
 └────────┼─────────┘
          ▼
Statistical Analysis
          │
   ┌──────┼──────────┐
   ▼      ▼          ▼
  MK     Sen       Pettitt
          │
          ▼
Climate Interpretation
```

---

# 6. Temperature Extremes

## 6.1 P90 Threshold

A percentile-based approach is used to identify unusually warm conditions.

The **90th percentile (P90)** is used as the temperature threshold.

A month is classified as a hot extreme when:

[
T \geq P90
]

This approach identifies temperature conditions that are unusually high relative to the underlying temperature distribution.

The percentile framework is preferable to using a single absolute temperature threshold because the climatic baseline differs between locations and seasons.

---

## 6.2 Temperature Anomalies

Temperature anomalies are evaluated relative to the long-term climatic distribution.

The anomaly analysis provides an independent view of long-term warming and interannual variability and is used alongside the P90 exceedance analysis.

---

## Temperature Results

The temperature analyses collectively indicate that the study should not be interpreted solely through individual extreme months. Instead, the combination of:

* annual temperature trends,
* temperature anomalies,
* P90 exceedances,
* temperature distributions,

provides a more comprehensive representation of the changing thermal regime.

The results demonstrate the importance of examining both the central tendency of temperature and the upper tail of the temperature distribution.

---

# 7. Drought Identification

## 7.1 Standardized Precipitation Index

Meteorological drought is quantified using the **Standardized Precipitation Index (SPI)**.

For the compound-event framework, the study uses **SPI-3**, representing a short-to-medium precipitation accumulation period.

The SPI approach transforms precipitation anomalies into a standardized probability-based index.

The principal drought criterion is:

[
SPI \leq -1.0
]

This threshold identifies moderate or stronger precipitation-deficit conditions suitable for compound hot–dry event detection.

---

# 8. Compound Hot–Dry Event Definition

The central methodological component of this research is the simultaneous identification of temperature and drought extremes.

A compound hot–dry event is defined as:

[
T \geq P90
]

**AND**

[
SPI\leq-1.0
]

Therefore:

```text
Extreme Heat
     +
Meteorological Drought
     ↓
Compound Hot–Dry Event
```

This framework distinguishes compound hazards from isolated heat or drought events.

A hot month without drought is not classified as a compound event.

Similarly, a drought month without extreme heat is not classified as a compound event.

Only the simultaneous occurrence of both conditions is retained.

---

# 9. Compound Event Characteristics

Each identified compound event is evaluated according to several dimensions.

## 9.1 Frequency

Frequency represents the number of compound hot–dry months/events occurring during a given year.

Higher annual frequency indicates a greater temporal occurrence of compound climatic stress.

---

## 9.2 Duration

Duration represents the number of consecutive months during which compound hot–dry conditions persist.

Longer duration indicates greater persistence and potentially greater cumulative climatic stress.

---

## 9.3 Maximum Consecutive Duration

Maximum consecutive duration represents the longest uninterrupted compound hot–dry sequence.

This indicator is particularly important because two regions may experience the same number of compound events while having substantially different persistence characteristics.

---

## 9.4 Severity

Compound-event severity integrates the intensity of the thermal anomaly and the associated precipitation deficit.

This allows the analysis to move beyond simple event counts and evaluate whether compound events are becoming more severe.

---

# 10. Statistical Framework

## 10.1 Mann–Kendall Trend Test

The non-parametric Mann–Kendall test is used to determine whether a statistically significant monotonic trend exists in the compound-event series.

The test is applied to temporal indicators such as:

* Compound-event frequency;
* Event characteristics;
* Relevant extreme-temperature indicators;
* Duration-related metrics.

The Mann–Kendall test is appropriate for climatic time series because it does not require the observations to follow a normal distribution.

---

# 10.2 Sen's Slope Estimator

Sen's slope is used to quantify the magnitude and direction of temporal change.

While Mann–Kendall determines whether a monotonic trend is statistically detectable, Sen's slope provides an estimate of the rate of change.

Therefore:

```text
Mann–Kendall → Statistical significance of trend

Sen's Slope → Magnitude and direction of trend
```

The combination provides a more informative interpretation than using either method independently.

---

# 10.3 Spearman Rank Correlation

Spearman's rank correlation is used to evaluate monotonic associations between climate variables and compound-event characteristics.

The method is particularly useful where relationships may not be strictly linear.

Spearman correlation is interpreted as an association measure rather than as a causal relationship.

---

# 10.4 Pettitt Change-Point Test

The Pettitt test is applied to identify potential abrupt changes in the statistical characteristics of the time series.

The change-point analysis provides an additional perspective beyond monotonic trend analysis.

A time series may exhibit:

```text
No significant overall linear trend
        BUT
A substantial structural shift
```

Therefore, the combination of Mann–Kendall and Pettitt testing allows both gradual and abrupt changes to be investigated.

---

# 11. Main Results

## 11.1 Temperature Regime

The temperature analyses demonstrate substantial temporal variability in the thermal conditions of Southeastern Türkiye during 1981–2025.

The annual temperature trend plots and anomaly analyses indicate that the thermal regime should be evaluated not only through mean conditions but also through the frequency of upper-tail temperature exceedances.

The P90 analysis provides an additional perspective by identifying months in which temperatures exceed the long-term upper percentile threshold.

---

## 11.2 Extreme-Temperature Frequency

The P90 exceedance analysis provides evidence regarding the temporal evolution of unusually warm months.

The annual P90 exceedance trends and hot-extreme-month distributions demonstrate that extreme temperature occurrence is not uniformly distributed through time.

This is particularly important for compound-event analysis because the probability of a hot–dry event depends on the simultaneous availability of both thermal and moisture-stress conditions.

---

## 11.3 Drought Regime

The SPI-3 analyses identify substantial temporal variability in drought conditions during the study period.

The SPI classification and drought-event outputs demonstrate that precipitation deficits occur with different temporal characteristics and that drought conditions provide an important climatic background for the development of compound hot–dry events.

---

## 11.4 Compound Hot–Dry Events

The central result of the study is the identification of months in which extreme temperature and drought conditions occur simultaneously.

The compound-event analysis demonstrates that heat and drought should not be considered completely independent hazards.

The temporal distribution of compound events provides evidence of periods in which thermal and moisture stresses overlap.

This overlap is particularly important because the environmental impact of simultaneous heat and drought may be substantially greater than the impact of either hazard alone.

---

## 11.5 Frequency

Annual compound-event frequency is examined for the regional dataset and individual provinces.

The annual event plots reveal considerable interannual variability, including years with relatively low compound-event activity and years characterized by substantially greater compound-event occurrence.

This variability highlights the importance of distinguishing long-term climatic trends from individual extreme years.

---

## 11.6 Duration and Persistence

The duration analyses demonstrate that compound-event risk cannot be represented adequately through event frequency alone.

The repository contains separate analyses of:

* Event-duration distributions;
* Mean and maximum duration;
* Maximum consecutive compound duration;
* Maximum consecutive hot–dry duration.

These indicators provide evidence concerning the persistence of compound climatic stress.

Longer consecutive sequences represent greater cumulative exposure and may have stronger implications for agriculture, water resources, ecosystems, and human systems.

---

## 11.7 Severity

The compound-event severity analysis provides an additional dimension of risk.

Two years with the same number of compound events may have substantially different climatic consequences if one contains more intense temperature anomalies or stronger precipitation deficits.

Therefore, severity complements frequency and duration and allows a more comprehensive assessment of compound climate risk.

---

## 11.8 Structural Changes

The Pettitt analysis investigates whether the compound-event time series experienced an abrupt statistical shift.

The accompanying pre/post-break comparison is designed to determine whether the characteristics of compound events differ before and after the detected structural transition.

This is important because climate change may manifest not only as a gradual trend but also through changes in the statistical regime of extreme events.

---

# 12. Complete Graphical Results

The following figures are included directly from the repository.

## 12.1 Temperature Distribution

![Temperature Distribution Boxplot](Temperature_Distribution_Boxplot.png)

The boxplot provides a comparative representation of the temperature distributions across the analyzed locations and highlights differences in central tendency and variability.

---

## 12.2 Annual Temperature Trends

![Annual Temperature Trends](Annual_Temperature_Trends_Facets.png)

Annual temperature trends provide a long-term perspective on changes in the thermal regime.

---

## 12.3 Annual Temperature Anomalies

![Annual Temperature Anomalies](Annual_Temperature_Anomalies_Facets.png)

The anomaly analysis highlights interannual deviations from the long-term temperature regime.

---

## 12.4 Regional Temperature Anomalies

![Regional Temperature Anomalies](Regional_Temperature_Anomalies_Barplot.png)

This figure summarizes the regional temperature anomaly structure and facilitates comparison among the study locations.

---

## 12.5 P90 Temperature Thresholds

![P90 Temperature Thresholds](P90_Temperature_Thresholds_Barplot.png)

P90 thresholds define the upper-tail temperature conditions used for hot-extreme detection.

---

## 12.6 Annual P90 Exceedance Trends

![Annual P90 Exceedance Trends](Annual_P90_Exceedance_Trends.png)

This figure illustrates the temporal evolution of months exceeding the P90 temperature threshold.

---

# 13. Drought Results

## 13.1 Identified Drought Events

![Identified Drought Events](Identified_Drought_Events.png)

The figure presents the temporal structure of identified drought episodes.

---

## 13.2 SPI Drought Categories

![SPI Drought Categories](SPI_Drought_Categories_Heatmap.png)

The heatmap displays the temporal distribution of SPI-based drought categories.

---

## 13.3 SPI Classification by Province

![SPI Class Distribution](SPI_Class_Distribution_Provinces.png)

The provincial distribution illustrates differences in the occurrence of drought categories.

---

# 14. Compound Hot–Dry Results

## 14.1 Compound Hot–Dry Events Across Provinces

![Compound Hot Dry Events](Compound_Hot_Dry_Events_9_Provinces.png)

This is one of the principal figures of the project.

It summarizes the occurrence of compound hot–dry conditions across the nine analyzed provinces and provides a direct comparison of compound-event behavior.

---

## 14.2 Annual Compound Events by Province

![Annual Compound Events by Province](Annual_Compound_Events_by_Province.png)

This figure presents annual compound-event frequency at the provincial level.

The figure is particularly useful for identifying interannual variability, periods of enhanced activity, and differences among provinces.

---

## 14.3 Annual Compound Event Heatmap

![Annual Compound Event Heatmap](Heatmap_Annual_Compound_Events.png)

The heatmap provides a compact representation of the temporal and provincial structure of compound events.

It allows periods of concentrated compound-event activity to be identified visually.

---

## 14.4 Total Annual Compound-Event Trend

![Total Annual Compound Events Trend](Total_Annual_Compound_Events_Trend.png)

This figure represents the regional temporal evolution of total annual compound-event activity.

It provides the main visual basis for evaluating whether compound hot–dry events have become more frequent over the study period.

---

# 15. Compound Event Duration

## 15.1 Event Duration Distribution

![Compound Event Duration Distribution](Compound_Event_Duration_Distribution.png)

The duration distribution demonstrates the range of persistence characteristics among identified compound events.

---

## 15.2 Mean and Maximum Duration

![Mean Maximum Compound Event Duration](Mean_Max_Compound_Event_Duration.png)

This figure summarizes the duration characteristics of compound events and facilitates comparison among provinces.

---

## 15.3 Maximum Consecutive Compound Duration

![Maximum Consecutive Compound Duration](Max_Consecutive_Compound_Duration_9_Provinces.png)

Maximum consecutive duration is an important persistence indicator because prolonged compound conditions may generate greater cumulative climatic stress.

---

## 15.4 Maximum Consecutive Hot–Dry Duration

![Maximum Consecutive Hot Dry Duration](Maximum_Consecutive_Hot_Dry_Duration.png)

This figure provides an additional representation of uninterrupted compound-event persistence.

---

## 15.5 Maximum Consecutive Duration

![Maximum Consecutive Duration](4_Max_Consecutive_Duration.png)

This output provides a complementary assessment of the persistence of compound conditions.

---

# 16. Compound Event Severity

![Compound Event Severity](Compound_Event_Severity_9_Provinces.png)

The severity analysis extends the study beyond simple event counts.

The figure allows comparison of the magnitude of compound hot–dry conditions among provinces and through time.

This is particularly important for risk assessment because an increase in event frequency does not necessarily imply an equivalent increase in event severity.

---

# 17. Bivariate Compound-Event Structure

![Bivariate Compound Event Scatter](Bivariate_Compound_Event_Scatter.png)

The bivariate analysis illustrates the joint relationship between the thermal and drought dimensions of compound events.

The purpose of this analysis is to demonstrate that compound-event identification is based on the intersection of two climatic dimensions rather than a single-variable extreme.

---

# 18. Hot-Extreme Timing

## 18.1 Hot Extreme Month Distribution

![Hot Extreme Months Distribution](Hot_Extreme_Months_Distribution.png)

This figure demonstrates the seasonal distribution of extreme-temperature months.

---

## 18.2 Hot Extreme Month Heatmap

![Hot Extreme Months Heatmap](Hot_Extreme_Months_Heatmap.png)

The heatmap provides a detailed temporal representation of the occurrence of hot extremes.

Together, these two figures demonstrate the seasonal structure underlying the compound-event analysis.

---

# 19. Trend Analysis

## 19.1 Mann–Kendall Trend Analysis

![Mann Kendall Trend](16_Mann_Kendall_Trend.png)

The Mann–Kendall analysis evaluates whether compound-event indicators exhibit statistically significant monotonic trends.

The test is interpreted together with Sen's slope rather than independently.

---

## 19.2 Spearman Rank Correlation

![Spearman Rank Correlation](Spearman_Rank_Correlation_1981_2025_Academic.png)

Spearman correlation provides an additional non-parametric assessment of monotonic associations among the analyzed climatic variables and compound-event indicators.

---

# 20. Change-Point Analysis

## 20.1 Pettitt Change Point

![Pettitt Change Point](Pettitt_Change_Point_1981_2025_Academic.png)

The Pettitt test evaluates whether an abrupt shift occurred in the statistical characteristics of the compound-event time series.

This analysis complements the Mann–Kendall trend test by focusing on structural changes rather than monotonic change.

---

## 20.2 Pre- and Post-Break Comparison

![Pre Post Break Comparison](Section_20_Pre_Post_Break_Comparison_Academic.png)

The pre/post-break analysis compares compound-event characteristics before and after the detected change point.

This provides a clearer interpretation of how the statistical regime may have changed following the identified structural transition.

---

# 21. Integrated Interpretation

The results demonstrate that compound hot–dry extremes should be evaluated through multiple dimensions.

A comprehensive compound-event framework can be expressed as:

```text
Temperature Regime
       │
       ▼
Extreme Heat Frequency
       │
       ├──────────────┐
       ▼              ▼
    P90 Events      Temperature
       │             Anomalies
       │
       ▼
Precipitation Deficit
       │
       ▼
     SPI-3
       │
       ▼
  Drought Events
       │
       └──────────────┐
                      ▼
            Compound Hot–Dry Events
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
      Frequency    Duration    Severity
          │           │           │
          └───────────┼───────────┘
                      ▼
             Temporal Persistence
                      │
                      ▼
              Trend Analysis
                      │
             ┌────────┼────────┐
             ▼        ▼        ▼
            MK       Sen     Spearman
                      │
                      ▼
               Pettitt Test
                      │
                      ▼
             Structural Change
```

This integrated framework demonstrates that compound climate risk is multidimensional.

---

# 22. Statistical Interpretation

The statistical analyses should be interpreted collectively.

### Mann–Kendall

Determines whether a monotonic temporal trend is statistically detectable.

### Sen's Slope

Quantifies the direction and magnitude of the trend.

### Spearman Correlation

Evaluates monotonic association between variables.

### Pettitt Test

Identifies potential abrupt structural changes.

### Frequency

Measures how often compound events occur.

### Duration

Measures how long compound conditions persist.

### Severity

Measures the intensity of compound climatic stress.

Together, these methods provide a more comprehensive statistical characterization than a simple linear trend analysis.

---

# 23. Key Scientific Findings

The combined analyses support several major conclusions:

### 1. Compound climate extremes represent a distinct hazard

The simultaneous occurrence of extreme heat and drought constitutes a distinct climatic condition and should not be represented simply as the independent sum of heat and drought events.

### 2. Extreme heat is an important component of the changing climate regime

The temperature anomaly, annual trend, P90 threshold, and exceedance analyses demonstrate the importance of changes in the upper tail of the temperature distribution.

### 3. Drought variability provides the moisture-stress component

SPI-3 identifies periods characterized by precipitation deficits and provides the drought dimension required for compound-event detection.

### 4. Compound events exhibit substantial temporal variability

Compound hot–dry events are not uniformly distributed across the 1981–2025 period.

### 5. Frequency alone is insufficient

The duration and severity analyses demonstrate that the climatic importance of compound events depends not only on how often they occur, but also on how long and how intensely they persist.

### 6. Persistence is an important component of compound risk

Maximum consecutive-duration indicators provide evidence that prolonged compound conditions require separate consideration from isolated events.

### 7. Trend and structural-change analyses provide complementary information

Mann–Kendall and Sen's slope evaluate gradual temporal change, whereas Pettitt identifies possible abrupt shifts in the statistical regime.

### 8. Provincial differences matter

The provincial figures demonstrate that compound-event characteristics are not spatially uniform across Southeastern Türkiye.

Consequently, regional-scale assessments should retain provincial-level information rather than relying exclusively on a single regional average.

---

# 24. Data and Result Files

The repository contains the following principal analytical outputs.

### Master Analysis

* `Bilesik_Sicak_Kurak_Analiz_Master_9_Il.xlsx`

### Temperature

* `Southeastern_Anatolia_Temperature_Statistics_1981_2025.xlsx`
* `Southeastern_Anatolia_Temperature_Anomalies_1981_2025.xlsx`
* `Southeastern_Anatolia_P90_Thresholds_1981_2025.xlsx`
* `Southeastern_Anatolia_Hot_Extreme_Months_1981_2025.xlsx`

### Drought

* `Southeastern_Anatolia_SPI3_Drought_1981_2025.xlsx`
* `Southeastern_Anatolia_SPI_Classification_1981_2025.xlsx`
* `Southeastern_Anatolia_Drought_Episodes_1981_2025.xlsx`

### Correlation

* `18_Spearman_Rank_Correlation_Fixed.xlsx`

### Regional Dataset

* `Guneydogu_NASA_POWER_1981_2025_Monthly.csv`

These files provide the numerical basis for the graphical and statistical analyses presented in the repository.

---

# 25. Reproducibility

All major stages of the analysis are implemented using R scripts included in the repository.

The workflow is organized into sequential scripts covering:

* Data processing;
* Temperature analysis;
* P90 threshold calculation;
* SPI calculation;
* Drought-event identification;
* Compound-event identification;
* Duration analysis;
* Severity analysis;
* Mann–Kendall testing;
* Spearman correlation;
* Pettitt change-point analysis;
* Visualization;
* Export of analytical results.

The repository therefore provides a transparent computational framework for reproducing the main analytical stages.

---

# 26. Repository Structure

```text
Compound-Hot-Dry-Extremes-in-Southeastern-T-rkiye/
│
├── NASA POWER Monthly Dataset
│
├── R Analysis Scripts
│   ├── Temperature Analysis
│   ├── P90 Analysis
│   ├── SPI Analysis
│   ├── Drought Event Detection
│   ├── Compound Event Detection
│   ├── Duration Analysis
│   ├── Severity Analysis
│   ├── Mann–Kendall Analysis
│   ├── Spearman Analysis
│   └── Pettitt Change-Point Analysis
│
├── Excel Results
│
├── PNG Figures
│
└── README.md
```

---

# 27. Methodological Strengths

The principal strengths of this project are:

* Long-term 1981–2025 monthly climate record;
* NASA POWER climate data;
* Percentile-based heat-extreme identification;
* SPI-3 drought characterization;
* Explicit compound-event definition;
* Frequency analysis;
* Duration analysis;
* Maximum consecutive-duration analysis;
* Severity analysis;
* Non-parametric trend testing;
* Sen's slope estimation;
* Spearman rank correlation;
* Pettitt change-point detection;
* Pre/post structural comparison;
* Provincial-level comparison;
* Complete graphical documentation;
* Exported Excel analytical results;
* Reproducible R workflow.

The combination of these approaches provides a substantially more detailed assessment than an analysis based only on temperature or precipitation trends.

---

# 28. Limitations

Several limitations should be considered when interpreting the results.

First, the analysis uses monthly temporal resolution. Consequently, sub-monthly heatwaves and short-duration drought episodes may not be fully represented.

Second, the compound-event definition depends on the selected thresholds:

[
T \geq P90
]

and

[
SPI\leq-1.0
]

Different percentile or SPI thresholds could produce different event frequencies.

Third, SPI represents precipitation-based drought and does not directly incorporate evapotranspiration, soil moisture, groundwater, or atmospheric evaporative demand.

Fourth, NASA POWER is a gridded/reanalysis-based climate data product rather than a direct substitute for every individual meteorological station record.

Therefore, the results should be interpreted as a regional climatological assessment rather than a direct replacement for station-based observations.

---

# 29. Future Development

The current framework can be extended through:

* SPI-1, SPI-3, SPI-6 sensitivity analysis;
* SPEI-based compound-event analysis;
* Alternative heat thresholds such as P95;
* Heatwave duration indices;
* Extreme precipitation and drought combinations;
* Atmospheric evaporative demand;
* Soil-moisture indicators;
* Copula-based compound probability analysis;
* Conditional probability analysis;
* Return-period estimation;
* Extreme-value modelling;
* Climate-model projections;
* CMIP6-based future compound-event analysis.

These extensions would allow the framework to evolve from historical detection toward probabilistic and future-risk assessment.

---

# 30. Scientific Contribution

The primary contribution of this project is the integration of temperature extremes and meteorological drought into a single compound-event framework for Southeastern Türkiye.

Instead of asking only:

> Is temperature increasing?

or:

> Is drought becoming more frequent?

the study addresses the more consequential question:

> **Are unusually hot and dry conditions increasingly occurring together, and are these compound events becoming more frequent, persistent, or severe?**

This distinction is scientifically important because compound hazards may generate impacts that cannot be adequately represented by independent climate indicators.

The framework therefore provides a basis for examining compound climate risk in a region highly sensitive to heat, drought, water scarcity, agricultural stress, and climate variability.

---

# 31. Conclusion

This project presents a comprehensive statistical assessment of compound hot–dry extremes in Southeastern Türkiye for the 1981–2025 period.

By integrating **P90 temperature extremes, SPI-3 drought conditions, compound-event detection, frequency, duration, persistence, severity, Mann–Kendall trend analysis, Sen's slope, Spearman correlation, and Pettitt change-point analysis**, the study develops a multidimensional representation of compound climatic extremes.

The results emphasize that compound climate risk cannot be adequately characterized through temperature or drought considered separately.

The combination of:

**Extreme Heat**

*

**Precipitation Deficit**

*

**Persistence**

*

**Severity**

provides a more complete representation of climatic stress.

The project consequently contributes a reproducible statistical framework for investigating the evolution of compound hot–dry extremes and provides a foundation for subsequent research into climate-risk assessment, agricultural vulnerability, water-resource stress, and future compound-event projections in Southeastern Türkiye.

---

# 32. Author

## Ahmet Solmaz

This research project was independently designed and conducted by **Ahmet Solmaz**.

The statistical analysis, data processing, compound-event identification, visualization, interpretation, and result organization were developed as part of the author's independent research work using the R statistical environment and NASA POWER climate data.

---

## Citation

If this repository or its analytical framework is used in academic research, please acknowledge:

**Solmaz, A. (2026). *Compound Hot–Dry Extremes in Southeastern Türkiye: Changes in Compound Temperature and Drought Extremes, 1981–2025.* Independent Research Project.**

---

## Keywords

`Compound Climate Extremes`
`Compound Hot-Dry Events`
`Extreme Heat`
`Meteorological Drought`
`SPI-3`
`P90 Temperature Threshold`
`Mann-Kendall`
`Sen's Slope`
`Spearman Correlation`
`Pettitt Test`
`Climate Variability`
`Climate Change`
`Southeastern Türkiye`
`NASA POWER`
`R`
`Drought`
`Heat Extremes`
`Climate Risk`

---

## Repository Contents

This repository contains:

* Long-term NASA POWER climate data;
* R analysis scripts;
* Temperature statistics;
* Temperature anomaly results;
* P90 temperature thresholds;
* Hot-extreme-month outputs;
* SPI-3 drought results;
* SPI classifications;
* Identified drought episodes;
* Compound-event frequency;
* Compound-event duration;
* Maximum consecutive duration;
* Compound-event severity;
* Mann–Kendall trend results;
* Spearman correlation results;
* Pettitt change-point results;
* Pre/post-break comparison;
* Excel analytical outputs;
* High-resolution graphical results.

**All major figures and numerical outputs are included in this repository to facilitate transparency, reproducibility, and independent evaluation of the analytical framework.**

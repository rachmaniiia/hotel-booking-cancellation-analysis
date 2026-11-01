# Hotel Booking Cancellation Analysis

Analysis of 119,390 hotel bookings (City Hotel and Resort Hotel) to understand what drives cancellations: business process modelling (BPMN), data cleaning and EDA in Python, SQL analysis, and Hypothesis Testing.

> Group project from the Data Analytics for Business mid-term exam (Bitlabs Academy x Kampus Merdeka, 2024), completed in a team of two.
> **My contribution:** data cleaning and EDA in Python, Hypothesis Testing

## Business problem

High cancellation rates hurt revenue and make room planning harder. The goal is to find which factors are linked to cancellations and turn them into data-backed recommendations.

## Key findings

**1. Cancellations rise steadily with lead time.**
Overall, 37.0% of bookings were canceled (44,224 of 119,390). Among bookings with a recorded lead time (83,573), the cancellation rate climbs from 18.5% (0-30 days) to 36.9% (31-60), 40.0% (61-90), 44.6% (91-120), and 52.2% (over 120 days). Bookings made more than 120 days ahead are almost 3x as likely to be canceled as bookings made within 30 days.

**2. Portugal is the highest-cancellation market in both hotel types.**
Cancellation rate in Portugal is 64.9% (City Hotel) and 42.2% (Resort Hotel), followed by Brazil (40.6% / 23.5%) and Italy (37.9% / 17.4%). City Hotel has the higher rate in most countries; Switzerland and Sweden are the exceptions. Only countries with at least 300 bookings per hotel type are included.

**3. City Hotel earns a higher ADR than Resort Hotel.**
Median ADR is 100.00 for City Hotel versus 76.95 for Resort Hotel (bookings with ADR > 0; 54,645 and 27,556 bookings). A Mann-Whitney U test gives p < 0.001 with a rank-biserial effect size of 0.27 (small to medium): a random City Hotel booking has a higher ADR than a random Resort Hotel booking about 63.5% of the time.

**4. Seasonality differs between the two hotels.**
Resort Hotel ADR peaks in August and drops sharply in September. City Hotel is flatter and peaks in May. Last-minute bookings (lead time under 7 days) are most frequent at City Hotel and in January, February, and August (counts, not shares).

## Robustness check: identical rows

After cleaning, 15,087 rows are identical in all booking attributes. Because the dataset has no booking ID, they were kept in the main analysis. Repeating the key results without them (104,303 rows, see the last section of the notebook) leads to the same conclusions, with smaller magnitudes:

| Metric | All rows (119,390) | Without identical rows (104,303) |
|---|---|---|
| Overall cancellation rate | 37.0% | 31.6% |
| Cancellation rate, lead time 0-30 days | 18.5% | 17.4% |
| Cancellation rate, lead time over 120 days | 52.2% | 43.5% |
| Portugal cancellation rate (City / Resort) | 64.9% / 42.2% | 51.9% / 38.6% |
| Median ADR (City / Resort) | 100.00 / 76.95 | 103.50 / 78.94 |
| ADR effect size (rank-biserial) | 0.27 | 0.27 |

Every finding keeps its direction: cancellation rate still rises with lead time, Portugal is still the highest-cancellation market in both hotel types (followed by Brazil and Italy), and City Hotel ADR is still significantly higher than Resort Hotel ADR. About three quarters of the removed rows were canceled bookings, so the overall rate and the Portugal City Hotel rate drop the most. The exact percentages in Key findings should therefore be read as depending on how identical rows are treated.

## Recommendations

- Pilot reconfirmation requests for bookings made 90+ days ahead and measure the change in cancellation rate. The data shows where cancellations concentrate but cannot show which measure works, so a controlled pilot is the right next step.
- Build expected-cancellation rates by lead-time band (18.5% for 0-30 days up to 52.2% for 120+ days) into occupancy forecasts and room planning, so long-lead bookings are counted at a discount rather than as certain revenue.
- Apply market-specific policies for high-cancellation countries such as Portugal, Brazil, and Italy.
- Use seasonal pricing for Resort Hotel around its August peak and run targeted offers for City Hotel in low-demand months.

## Data

- **Source:** Hotel Booking Demand dataset (Antonio, Almeida and Nunes, 2019), provided as `midterm_hotel_data.csv` by Bitlabs Academy.
- **Size:** 119,390 bookings, July 2015 to August 2017, two hotel types.
- **Not included in this repository:** the raw and cleaned data files. The provided file also contained `name`, `email`, `phone-number`, and `credit_card` columns; they were not used in the analysis and are removed right after the cleaning step.

## Tools and workflow

| Step | Tool | What was done |
|---|---|---|
| Process modelling | Bizagi Modeler (BPMN) | Booking process with four actors: customer, receptionist, room service, administration (see `diagram/`) |
| Cleaning and EDA | Python (pandas, matplotlib, seaborn) in Google Colab | Missing and inconsistent values, EDA by lead time, hotel, country, and month |
| SQL analysis | SQL via pandasql | CTEs and CASE WHEN on cancellations, lead time, and ADR (see `sql/`) |
| Hypothesis Testing | scipy | Normality check (Shapiro-Wilk), then Mann-Whitney U for ADR |

## Data cleaning decisions

- No exact duplicate rows were found in the course file, because it has a row-index column and synthetic personal-data columns that make every row unique. However, over 10,000 rows are identical in all booking attributes. They were kept (see Limitations).
- Negative values in numeric columns were treated as inconsistent and set to missing.
- Missing `lead_time`, `stays_in_weekend_nights`, and `adr` were filled with the median. Before filling, rows with a missing `lead_time` or `adr` were flagged (`lead_time_missing`, `adr_missing`) so that analyses depending on these columns can use observed values only.
- Missing `country` and `agent` were set to `unknown`; missing `total_of_special_requests`, `adults`, `children`, and `company` were set to 0.
- Text columns were lowercased and trimmed.

## Limitations

- About 30% of `lead_time` and `adr` values (35,817 rows) were missing in the raw data and filled with the median during cleaning. That would make many bookings look like they were made 69 days ahead and share the same ADR, which blurs real differences. For this reason the cancellation-rate-by-lead-time analysis (section 4.1) and the ADR comparison (section 5) use observed values only and exclude those rows. The SQL queries and the monthly ADR chart still use the filled values and are likely smoothed toward the median.
- The dataset has no booking ID, so rows that are identical in all booking attributes (over 10,000) may be separate bookings, for example group bookings. They were kept to stay consistent with the original course analysis; the Robustness check section above shows the key results without them.
- ADR values of 0 or below were excluded from the A/B test.
- Mann-Whitney U compares the whole ADR distribution, not only the means.
- Cancellation rates describe patterns, not causes.
- Deposit type was not analysed in this version.

## Repository structure

```
hotel-booking-cancellation-analysis/
├── notebook/    Python cleaning, SQL, EDA, Hypothesis Testing (Colab notebook)
├── sql/         the four SQL queries used in the analysis
├── diagram/     BPMN diagram of the booking process
└── README.md
```

## How to reproduce

The analysis was run on the course file `midterm_hotel_data.csv` (Bitlabs Academy), which is not included in this repository. It is based on the public Hotel Booking Demand dataset (Antonio, Almeida and Nunes, 2019), available on Kaggle, with extra columns added for the course (`name`, `email`, `phone-number`, `credit_card`, and a row index `Unnamed: 0`).

1. Download the public dataset and save it as `midterm_hotel_data.csv`.
2. Open the notebook in Google Colab, mount Google Drive, and update `path` to your own location.
3. Run all cells from top to bottom. The SQL queries run through `pandasql` on the cleaned DataFrame.

Because the public file differs slightly from the course file, results may not match the numbers in this README exactly.

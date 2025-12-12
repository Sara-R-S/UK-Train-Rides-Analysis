# UK Train Rides

## Project Overview
This project aims to analyze a dataset of UK train ticket purchases to gain insights into passenger behaviour, pricing trends, and operational efficiency. 

The dataset includes details such as ticket prices, purchase methods, railcard usage, journey times, and delay information. 

By exploring this data, we hope to identify patterns and trends that can inform decision-making related to pricing strategies, service improvements, and resource allocation within the UK rail network.

## Contents
- [Data Summary](#Data-Summary)
- [Methodology](#Methodology)
- [Key Findings](#Key-Findings)
- [Recommendations](#Recommendations)
- [Usage](#Usage)
- [Acknowledgments](#acknowledgments)

## Data Summary
* Total Records: 31,653 
* Key Features: Transaction details (e.g., "Transaction_ID", "Purchase Date", "Payment Method"), Travel Details (e.g., "Departure Time" , "Arrival Time", "Journey Status"), Ticket Information (e.g., "Ticket Type", "Ticket Class", "Railcard")
* Timeframe: 08/12/2023 12:41:11 PM - 30/04/2024 08:05:39 PM

### Data Quality
* Missing Values: All Empty values are structurally valid nulls - they represent cases where the attribute does not apply (e.g., no delay reason is recorded when journeys are on time)
* Categorical Data Inconsistencies: Data standardization was applied to [Reason for Delay] to resolve categorical inconsistencies (e.g., 'Signal failure', 'Signal Failure').
* Invalid Data Values: None
* Duplicate Records: None

### Recommendations
* Standardize categorical labels across all relevant columns.
* Establish a data governance process for future data entry.


## Methodology
* **Data Preprocessing & Cleaning** using Python (Pandas,matplotlib) and **Data Modelling** using SQL. 
* **Exploratory Data Analysis** using Python (pandas, matplotlib, seaborn) and SQL.
* **Forecasting** using Python using (pandas, scikit-learn, matplotlib, seaborn).
* **Interactive Visualisation** using Tableau.

## Key Findings

### Journey Characteristics
* The Top 5 Popular Stations were found to have around 78% of total rides with the most popular station being Birmingham New Street with 15.6% of total rides 
* The Top 5 popular Routes were found to have around 73% of total rides with the most popular route being Manchester Piccadilly  »  Liverpool Lime Street with 16.82% of total Rides
* 27.58% of rides were found to have a Duration of 80 minutes  
* Peak hours were found to be mostly on weekdays between 6-8am and 4-6pm

### Operational Performance
* 86.82% were On Time with a delay rate of 7.24% and a Cancellation rate of 5.94% of total rides .
* The Most Common Reason for Cancellation was found to be Signal Failure contributing to 27.6% of total Cancellations while Weather Conditions contributed to 40.4% of delays.
* Technical Issues and Staffing Shortages were found to have the highest average delay duration of around 51.81 and 51.18 minutes . 
* Delays were found to mostly occur to Late Morning rides (8 a.m.–11 a.m.) while Night rides (8 p.m.–11 p.m.) had 100% on-time performance.
* Cancellations usually peaked towards the end of peak hours (8 a.m. and 5:00 p.m.).

### Passenger Behaviour
* Purchase Lead Time was around 89.10% for 0-3 days to departure of total Purchases
* Advance Tickets are the most popular at 55.5% of total purchases as they offer a 50% discount for tickets purchased at least a day before departure followed by the Off-Peak Tickets at 27.6% which offers 25% off departures outside of peak travel times.
* Standard Class Tickets were naturally contributing to the majority of the total purchases at 90.3% while First Class Tickets were at 9.7% .
* The most preferred Payment Method was found to be Credit Card at 60.5% of total purchases while the most preferred purchase method was online at 58.5%.
* National Railcard holders were found to be contributing to around 33.9 % of total purchases and are mostly adults contributing to around 45.1 % of purchases.

### Revenue Trends
* Advance Tickets were found to contribute to 41.7% of total revenue while Off-Peak Tickets contributed to 30.1%.
* Standard Class Tickets were naturally contributing to the majority of the total revenue at 79.9%.
* National Railcard holders contribute to around 22.7 % of total revenue are mostly adults contributing to around 11.6 % of total revenue.
* Refund requests in total amount to 5.2% of the total revenue with delays contributing to 3.5% and cancellations to 1.7% of total revenue.


## Recommendations
* **Investigate late morning rides** for potential delays and implement solutions to improve on-time performance.
* **Implement rigorous routine maintenance schedule** at all high demand stations in order to withstand harsh weather conditions and avoid technical issues. 
* **Focus on Standard Class and popular routes** for revenue optimization.
* **Monitor seasonal trends** and implement strategies to stabilize revenue during fluctuating months.
* **Address technical difficulties and staffing issues** to recover $24,293 (92%) of the revenue loss due to delays.

## Usage
1. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/UK_Train_Rides_Analysis.git
   ```
2. Navigate into the project directory:
   ```bash
   cd UK_Train_Rides_Analysis
   ```
3. Install dependencies:
   ```bash
   pip install pandas matplotlib seaborn scikit-learn
   ```
4. Run the Jupyter notebooks in sequence:
   * `Preprocessing.ipynb`
   * `EDA.ipynb`
   * `Forecasting.ipynb`

5. Open the Tableau dashboard for interactive visualization.


## Acknowledgments
This project was executed through the collaborative and coordinated efforts of the team members.

- **Sara Reda** – Provided leadership throughout the project, conducted exploratory data analysis (EDA), and meticulously documented and maintained a comprehensive record of all analyses and workflows.
- **Hend Tarek** – Oversaw data cleaning, preprocessing, and modeling, ensuring data accuracy and model reliability.
- **Salma Hassan** – Focused on the development, validation, and implementation of forecasting models that supported the project’s analytical outcomes and ensured their accuracy and relevance.
- **Aya Sameh** – Played a key role in the design and formatting of the final deliverables, developed visualizations to support key findings, and contributed significantly to the interpretation and presentation of results.
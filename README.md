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
* **Forecasting** using Python (pandas, scikit-learn, matplotlib, seaborn).
* **Interactive Visualisation** using Tableau.

## Key Findings
In progress...

## Recommendations
In progress...

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
   pip install pandas matplotlib scikit-learn
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

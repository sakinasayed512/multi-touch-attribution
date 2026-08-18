Multi-Touch Marketing Attribution & ROI Dashboard

4-week data analytics project built during the Infotact Solutions internship, simulating an in-house marketing analytics engine: distributing conversion credit across customer touchpoints, calculating CAC and ROAS per channel, and delivering an interactive Power BI dashboard for marketing decision-makers.

Objective
Marketing teams often default to Last-Touch attribution, which overweights bottom-funnel channels (like Direct Traffic and Search) and undervalues awareness-stage channels (like Display and Social). This project builds an attribution engine that lets a CMO or Performance Marketer toggle between First-Touch, Last-Touch, and Linear models to see how credit and therefore budget allocation, shifts depending on the lens applied.

CMO macro ROAS visibility to reallocate budget across channels
Performance Marketer campaign-level drill-down on funnel performance
Dataset

Kaggle: Multi-Touch Attribution dataset by vivekparasharr - 10,000 interaction rows, 2,847 unique users, 5 raw columns (User ID, Timestamp, Channel, Campaign, Conversion). No cost/spend data included - a companion spend table was built manually (see Week 3).

Tech Stack
Python (Pandas) - MySQL - Power BI

Project Structure
Week	Focus	Output
1	Data cleaning & EDA (Python/Pandas)	Cleaned dataset loaded into MySQL
2	Attribution modeling (MySQL window functions)	First-Touch, Last-Touch, Linear attribution
3	Cost modeling & star schema	CAC, ROAS, channel_spend table, dimensional model
4	Dashboard build (Power BI)	4 interactive visuals, published to GitHub

Week 1 - Data Cleaning & EDA
No nulls or duplicates found
Timestamp converted from object → datetime
Campaign placeholder - relabeled as "No Campaign" (~31.3% of rows)
Conversion mapped Yes/No → 1/0
6 channels present, Direct Traffic most frequent (~17.2% of touchpoints)
Touchpoints per user: range 1–12, median 3, mean ~3.5
Conversion rate: ~49.4% (noted as high - dataset is synthetic/simplified)
Loaded into MySQL table interactions

Week 2 - Attribution Modeling
Built using ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp) window functions in MySQL.
Model	Logic	Top Channel
First-Touch	Credit to earliest touchpoint	Display Ads (428)
Last-Touch	Credit to final touchpoint	Direct Traffic (425)
Linear Equal credit split across all touchpoints	Direct Traffic (408)
Key insight: Display Ads drives awareness (wins First-Touch) but is undervalued by Last-Touch reporting the standard model most teams default to.

Week 3 - Cost Modeling & Star Schema
Since the dataset had no spend data, a channel_spend table was built manually using assumed industry-typical CPC benchmarks:
Channel	CPC (₹)	CAC (₹)	ROAS
Email	2	8.53	58.6x
Referral	5	
Display Ads	8	
Social Media	12
Search Ads	25	105.43	4.74x
Direct Traffic	0 (organic)	N/A	N/A
(AOV assumed at ₹500 for ROAS calculation.)
Key insight: Email is the most cost-efficient channel by a wide margin, Search Ads is the least efficient despite comparable conversion volume to other channels.

Star schema built:
dim_channel, dim_campaign — dimension tables
fact_interactions - 10,000-row fact table, FK-linked to both dimensions
channel_spend - channel-level cost table, linked via channel_id
attribution_weights - long-format table (one row per touchpoint per model) enabling the Power BI toggle
Week 4 - Power BI Dashboard

Visuals:
Conversion Funnel - touchpoints/conversions by channel
ROI Scatter Plot - CAC (x) vs ROAS (y) by channel, with trendline
Channel Comparison Bar Chart - total spend by channel
Attribution Model Toggle - slicer switching between First-Touch / Last-Touch / Linear, driving a live weighted bar chart

<img width="994" height="574" alt="Screenshot 2026-08-18 161505" src="https://github.com/user-attachments/assets/990e041a-70ae-4e1a-80ee-fe79b18165e2" />

Key Takeaways
Last-Touch attribution (the default most teams use) systematically undervalues top-of-funnel channels like Display Ads.
Search Ads is the highest-spend, lowest-efficiency channel in this dataset a clear budget reallocation candidate.
Email delivers disproportionate ROI relative to spend and deserves increased investment.

Multi-Touch-Attribution.ipynb - Week 1 Python/Pandas cleaning & EDA
Multi_Touch_Attribution_MySQL.sql - full SQL: table creation, attribution queries, CAC/ROAS, star schema
multi_touch_attribution_cleaned.csv - cleaned dataset
multi_touch_attribution_powerbi.pbix - final Power BI dashboard file

Sakina Sayed - Data Analytics Intern, Infotact Solutions

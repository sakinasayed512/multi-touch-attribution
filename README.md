Multi-Touch Marketing Attribution & ROI Dashboard
Overview

E-commerce and SaaS companies spend across multiple advertising channels (Search, Social, Display, Email, Referral, Direct). Traditional Last-Click attribution gives 100% conversion credit to the final touchpoint, which misrepresents the true contribution of upper-funnel channels and leads to misallocated ad budgets.

This project builds a Multi-Touch Attribution engine that models customer journeys across First-Touch, Last-Touch, and Linear attribution, ultimately supporting Return on Ad Spend (ROAS) and Customer Acquisition Cost (CAC) calculations for a Power BI dashboard.

Project Timeline

4-week internship project (Jul 10 – Aug 8, 2026) at Infotact Solutions.

Week	Focus	Status
1	Data ingestion & EDA (Python/Pandas)	✅ Complete
2	SQL attribution logic (MySQL, window functions)	✅ Complete
3	KPI calculation (CAC, ROAS) & star schema	⏳ In progress
4	Power BI dashboard & executive report	🔲 Not started
Team
Sakina — Team lead, sole PR reviewer/merger, working on branch sakina
Sanket, Beckley — Team members, each on their own branch
Dataset

Multi-Touch Attribution dataset by vivekparasharr (Kaggle) — 10,000 interaction rows, 2,847 unique users, 5 columns: User ID, Timestamp, Channel, Campaign, Conversion.

No ad spend data included; a companion spend table is being manually created in Week 3 to support CAC/ROAS calculations.

Tech Stack
Python (Pandas, NumPy) — data cleaning & EDA (Week 1)
MySQL (Workbench) — attribution logic via window functions (Week 2), star schema (Week 3)
Power BI — interactive dashboard (Week 4)
SQLAlchemy + PyMySQL — Python-to-MySQL data pipeline
Week 1: Data Cleaning & EDA
Verified no nulls or duplicates
Converted Timestamp from object → datetime
Replaced - placeholder in Campaign with "No Campaign" (~31.3% of rows)
Mapped Conversion from Yes/No → 1/0
Conversion rate: ~49.4%; touchpoints per user range 1–12 (median 3, mean ~3.5)
Cleaned data loaded into MySQL table interactions
Week 2: Attribution Models

Built three attribution models using MySQL window functions (ROW_NUMBER(), COUNT() OVER (PARTITION BY ...)):

First-Touch — 100% credit to each user's earliest touchpoint
Last-Touch — 100% credit to each user's most recent touchpoint
Linear — credit split evenly across all touchpoints in a converting user's journey
Key Finding

Attribution model choice materially changes which channels appear to "win":

Channel	First-Touch	Linear	Last-Touch
Direct Traffic	411	408	425
Display Ads	428	407	401
Referral	408	399	384
Social Media	389	398	383
Email	374	388	393
Search Ads	371	382	395

Display Ads drives the most first touches (top-of-funnel discovery) but ranks 3rd in last-touch credit. Direct Traffic is the opposite — weak at starting journeys, strongest at closing them. A Last-Click-only model would systematically under-credit Display Ads for its role in awareness — the exact budget misallocation problem this project addresses.

Repository Structure
multi-touch-attribution/
├── Multi-Touch-Attribution.ipynb      # Week 1: cleaning & EDA
├── Multi_Touch_Attribution_SQL.sql    # Week 2: attribution queries
├── README.md
└── .gitignore
Next Steps
Build companion ad spend table (Week 3)
Calculate CPC, CAC, ROAS per channel
Model data into a star schema (fact/dimension tables)
Build Power BI dashboard with model-toggle, funnel, and channel-comparison visuals

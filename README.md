Dataset
Multi-Touch Attribution dataset by vivekparasharr (Kaggle) - 10,000 interaction rows, 2,847 unique users, 5 columns: User ID, Timestamp, Channel, Campaign, Conversion.
No ad spend data included; a companion spend table is being manually created in Week 3 to support CAC/ROAS calculations.

Tech Stack
Python (Pandas, NumPy) — data cleaning & EDA (Week 1)
MySQL (Workbench) — attribution logic via window functions (Week 2), star schema (Week 3)
Power BI — interactive dashboard (Week 4)
SQLAlchemy + PyMySQL — Python to MySQL data pipeline
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

CREATE DATABASE multi_touch_attribution;
USE multi_touch_attribution;

CREATE TABLE interactions (
    user_id VARCHAR(50),
    timestamp DATETIME,
    channel VARCHAR(50),
    campaign VARCHAR(50),
    conversion TINYINT
)

SELECT COUNT(*) FROM interactions;
SELECT * FROM interactions LIMIT 5;

SELECT 
    user_id,
    channel,
    campaign,
    timestamp,
    conversion,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp ASC) AS touch_order
FROM interactions;

-- First-touch attribution
SELECT * FROM
( SELECT
user_id,
channel,
campaign,
timestamp,
conversion,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp ASC) AS touch_order
FROM interactions
) AS ranked 
WHERE touch_order = 1;

-- Last-touch attribution
SELECT * FROM
( SELECT
user_id,
channel,
campaign,
timestamp,
conversion,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) AS touch_order
FROM interactions
) AS ranked 
WHERE touch_order = 1;

-- Linear attribution
SELECT 
    user_id,
    channel,
    campaign,
    timestamp,
    conversion,
    COUNT(*) OVER (PARTITION BY user_id) AS total_touchpoints,
    1 / COUNT(*) OVER (PARTITION BY user_id) AS attribution_weight
FROM interactions;
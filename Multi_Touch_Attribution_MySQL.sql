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

-- Linear attribution, converted users only
SELECT 
    user_id,
    channel,
    campaign,
    timestamp,
    COUNT(*) OVER (PARTITION BY user_id) AS total_touchpoints,
    1 / COUNT(*) OVER (PARTITION BY user_id) AS attribution_weight
FROM interactions
WHERE user_id IN (
    SELECT user_id FROM interactions WHERE conversion = 1
);

-- Total linear-attributed conversions per channel
SELECT 
    channel,
    SUM(attribution_weight) AS total_attributed_conversions
FROM (
    SELECT 
        user_id,
        channel,
        1 / COUNT(*) OVER (PARTITION BY user_id) AS attribution_weight
    FROM interactions
    WHERE user_id IN (
        SELECT user_id FROM interactions WHERE conversion = 1
    )
) AS linear_weights
GROUP BY channel
ORDER BY total_attributed_conversions DESC;

-- Total first-touch conversions per channel
SELECT 
channel,
COUNT(*) AS first_touch_conversions
FROM (
SELECT
user_id,
channel,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp ASC) AS touch_order
FROM interactions
WHERE user_id IN (
SELECT user_id FROM interactions WHERE conversion = 1
)
) AS first_touch 
WHERE touch_order = 1
GROUP BY channel
ORDER BY first_touch_conversions DESC;

-- Total last-touch conversions per channel
SELECT 
channel,
COUNT(*) AS last_touch_conversions
FROM (
SELECT
user_id,
channel,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) AS touch_order
FROM interactions
WHERE user_id IN (
SELECT user_id FROM interactions WHERE conversion = 1
)
) AS last_touch
WHERE touch_order = 1
GROUP BY channel
ORDER BY last_touch_conversions DESC;

SELECT channel, COUNT(*) AS total_touchpoints
FROM interactions
GROUP BY channel
ORDER BY total_touchpoints DESC;

DROP TABLE channel_spend;

CREATE TABLE channel_spend (
    channel VARCHAR(50),
    cpc DECIMAL(6,2),
    total_touchpoints INT,
    total_spend DECIMAL(10,2)
);

INSERT INTO channel_spend (channel, cpc, total_touchpoints, total_spend) VALUES
('Search Ads', 25, 1609, 25*1609),
('Display Ads', 8, 1669, 8*1669),
('Social Media', 12, 1662, 12*1662),
('Email', 2, 1654, 2*1654),
('Referral', 5, 1685, 5*1685),
('Direct Traffic', 0, 1721, 0);

SELECT * FROM channel_spend;

-- CAC per channel = Total Spend ÷ Attributed Conversions
SELECT 
    cs.channel,
    cs.total_spend,
    lw.total_attributed_conversions,
    ROUND(cs.total_spend / lw.total_attributed_conversions, 2) AS CAC
FROM channel_spend cs
JOIN (
    SELECT 
        channel,
        SUM(attribution_weight) AS total_attributed_conversions
    FROM (
        SELECT 
            user_id,
            channel,
            1 / COUNT(*) OVER (PARTITION BY user_id) AS attribution_weight
        FROM interactions
        WHERE user_id IN (
            SELECT user_id FROM interactions WHERE conversion = 1
        )
    ) AS linear_weights
    GROUP BY channel
) AS lw ON cs.channel = lw.channel
ORDER BY CAC ASC;

-- ROAS = (Attributed Conversions × AOV) ÷ Total Spend
SELECT 
    cs.channel,
    cs.total_spend,
    lw.total_attributed_conversions,
    ROUND((lw.total_attributed_conversions * 500) / NULLIF(cs.total_spend, 0), 2) AS ROAS
FROM channel_spend cs
JOIN (
    SELECT 
        channel,
        SUM(attribution_weight) AS total_attributed_conversions
    FROM (
        SELECT 
            user_id,
            channel,
            1 / COUNT(*) OVER (PARTITION BY user_id) AS attribution_weight
        FROM interactions
        WHERE user_id IN (
            SELECT user_id FROM interactions WHERE conversion = 1
        )
    ) AS linear_weights
    GROUP BY channel
) AS lw ON cs.channel = lw.channel
ORDER BY ROAS DESC;
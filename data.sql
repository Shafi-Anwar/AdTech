USE meta_social_media;
SHOW TABLES;

-- every user total ads seena and total click

SELECT u.user_id,u.name, COUNT(ai.impression_id) AS total_ads_seen,
SUM(ai.clicked) AS total_clicks,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id),3) AS click_rate
FROM  users AS u
JOIN ad_impressions AS ai
	ON u.user_id = ai.user_id
GROUP BY u.user_id, u.name
ORDER BY total_clicks DESC LIMIT 10;

-- Get top 10 users with highest CTR
SELECT u.user_id, u.name, COUNT(ai.impression_id) AS total_ads_seen,
SUM(ai.clicked) as total_clicks,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id)*100,3) AS click_rate
FROM users AS u
JOIN ad_impressions AS ai
ON u.user_id = ai.user_id
GROUP BY u.user_id,u.name
ORDER BY click_rate DESC LIMIT 10;

SELECT
	CASE 
		WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
	END AS age_group,
    COUNT(ai.impression_id) AS total_ads_seen,
    SUM(ai.clicked) AS total_clicks,
    ROUND(SUM(ai.clicked)/COUNT(ai.impression_id) *100, 3) AS avg_ctr
FROM users u
JOIN ad_impressions ai ON u.user_id = ai.user_id
GROUP BY age_group
ORDER BY age_group;

-- difference in device CTRS of users- mobile is winner

SELECT ai.device, 
SUM(ai.clicked) as total_clicks,
COUNT(ai.impression_id) AS total_ads_seen,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id)*100,3) AS click_rate
FROM users AS u
JOIN ad_impressions AS ai
ON u.user_id = ai.user_id
GROUP BY ai.device
ORDER BY click_rate DESC;

-- Har ad category (Tech, Fashion, Food, Travel, Finance) ka CTR kya hai?-food won
SELECT a.category,
SUM(ai.clicked) as total_clicks,
COUNT(ai.impression_id) AS total_ads_seen,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id)*100,3) AS click_rate
FROM ads as a
JOIN ad_impressions ai ON a.ad_id = ai.ad_id
GROUP BY a.category
ORDER BY click_rate DESC;

-- which company have highest click rate of users -  Henderson Inc won with click rate of 15.79%
SELECT adv.advertiser_id, adv.company_name,
SUM(ai.clicked) as total_clicks,
COUNT(ai.impression_id) AS total_ads_generated,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id)*100,3) AS click_rate
FROM ad_impressions ai
JOIN ads a ON ai.ad_id = a.ad_id
JOIN advertisers adv ON a.advertiser_id = adv.advertiser_id
GROUP BY adv.advertiser_id, adv.company_name
order by click_rate DESC;

-- Har device (Mobile/Desktop/Tablet) ke liye har ad category ka CTR kya hai?
/* result : 'Tablet','Travel','735','7019','10.470'
'Mobile','Food','678','6494','10.440'
'Mobile','Tech','697','6846','10.180'
'Desktop','Food','652','6516','10.010'
'Desktop','Travel','705','7066','9.980'
'Mobile','Finance','662','6638','9.970'
'Tablet','Food','654','6587','9.930'
'Desktop','Finance','649','6720','9.660'
'Mobile','Fashion','608','6326','9.610'
'Tablet','Finance','657','6835','9.610'
'Mobile','Travel','667','6938','9.610'
'Tablet','Fashion','594','6227','9.540'
'Desktop','Fashion','581','6215','9.350'
'Desktop','Tech','623','6715','9.280'
'Tablet','Tech','630','6858','9.190'
*/

SELECT ai.device, a.category,
SUM(ai.clicked) AS total_clicks,
COUNT(ai.impression_id) AS total_ads_seen,
ROUND(SUM(ai.clicked)/COUNT(ai.impression_id )*100,3) AS total_click_rate
FROM ad_impressions ai
JOIN ads as a ON ai.ad_id = a.ad_id
GROUP BY ai.device, a.category
ORDER BY total_click_rate DESC;

-- Top 3 ads per user
WITH user_ad_stats AS (
    SELECT 
        ai.user_id,
        ai.ad_id,
        a.ad_text,
        SUM(ai.clicked) AS total_clicks,
        COUNT(ai.impression_id) AS total_ads_seen,
        ROUND(SUM(ai.clicked)/COUNT(ai.impression_id)*100,3) AS click_rate,
        ROW_NUMBER() OVER(PARTITION BY ai.user_id ORDER BY SUM(ai.clicked) DESC) AS rn
    FROM ad_impressions ai
    JOIN ads a ON ai.ad_id = a.ad_id
    GROUP BY ai.user_id, ai.ad_id, a.ad_text
)
SELECT *
FROM user_ad_stats
WHERE rn <= 3
ORDER BY user_id, click_rate DESC

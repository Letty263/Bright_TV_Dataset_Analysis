SELECT 
    t.UserID,
    t.Gender,
    t.Age,
    t.age_group,

    -- Time insights
    t.date_sast,
    t.time_of_day,
    DAYNAME(t.date_sast) AS day_of_week,

    -- Content
    t.content,
    t.session_category,

    -- Aggregations
    COUNT(*) AS total_sessions,
    SUM(t.duration_minutes) AS total_watch_time,
    AVG(t.duration_minutes) AS avg_session_duration,

  ---Engagement Level
CASE 
    WHEN COUNT(*) > 20 THEN 'Frequent User'
    WHEN COUNT(*) BETWEEN 10 AND 20 THEN 'Moderate User'
    ELSE 'Occasional User'
END AS engagement_level,

    -- Unique Channels per user
    COUNT(DISTINCT t.content) AS unique_channels_watched,

    -- User Segmentation
    CASE 
        WHEN SUM(t.duration_minutes) > 500 THEN 'High Value'
        WHEN SUM(t.duration_minutes) BETWEEN 200 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS user_segment



FROM (
    SELECT 
        V.UserID,
        U.Gender,
        U.Age,

        -- Age Group Buckets
        CASE 
            WHEN U.Age < 18 THEN 'Children'
            WHEN U.Age BETWEEN 18 AND 34 THEN 'Youth'
            WHEN U.Age BETWEEN 35 AND 54 THEN 'Adults'
            ELSE 'Seniors'
        END AS age_group,

        V.content,

        -- Use existing SA Time columns
        V.date_sast,
        V.hour_sast,

        -- Duration
        V.duration_minutes,

        -- Time Buckets (using existing hour_sast)
        CASE 
            WHEN V.hour_sast BETWEEN 6 AND 11 THEN 'Morning'
            WHEN V.hour_sast BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN V.hour_sast BETWEEN 18 AND 22 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day,

        -- Session Length Buckets
        CASE 
            WHEN V.duration_minutes < 5 THEN 'Very Short'
            WHEN V.duration_minutes BETWEEN 5 AND 15 THEN 'Short'
            WHEN V.duration_minutes BETWEEN 15 AND 30 THEN 'Medium'
            ELSE 'Long'
        END AS session_category

    FROM `workspace`.`default`.`viewership_final` V
    JOIN `workspace`.`default`.`userprofile_cleaned` U
        ON V.UserID = U.UserID
) t

GROUP BY 
    t.UserID,
    t.Gender,
    t.Age,
    t.age_group,
    t.date_sast,
    t.time_of_day,
    DAYNAME(t.date_sast),
    t.content,
    t.session_category;

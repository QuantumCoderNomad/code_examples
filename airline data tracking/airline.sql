SELECT 
    u.date,
    u.entity,
    u.orders,
    u.tickets,
    u.STR,
    u.tickets_total,
    u.profit,
    q.sales,
    q.click_share,
    e.productivity,
    e.minimum_productivity,
    e.is_filtered
FROM(
    SELECT
        toDate(created_at) AS date,
        entity,
        plating_carrier,
        uniqExactIf(token, status = 'finished') AS orders,
        sumIf(passengers_count, status = 'finished') AS tickets,
        uniqExactIf(token, status = 'finished') / uniqExact(token) * 100 AS STR,
        sumIf(tickets_amount, status = 'finished')/100 AS tickets_total, 
        sumIf(estim_profit, status = 'finished')/100 AS profit
    FROM airlines_data
    WHERE toDate(created_at) BETWEEN '{{ date.start }}' AND '{{ date.end }}'
    AND plating_carrier = ('{{ airline }}')
    AND (test_card = 0 OR test_card is NULL)
    GROUP BY date, entity, plating_carrier
    ORDER BY orders DESC
) AS u
INNER JOIN (
    SELECT
        date,
        market,
        airline,
        sales,
        click_share
    FROM airlines_metrics
    WHERE market = 'all'
) AS q ON u.plating_carrier = q.airline AND u.date = q.date
INNER JOIN (
    SELECT 
        date,
        airline,
        productivity,
        minimum_productivity,
        is_filtered
    FROM airlines_productivity
    WHERE date BETWEEN '{{ date.start }}' AND '{{ date.end }}'
) AS e ON e.date = u.date AND e.airline = u.plating_carrier
ORDER BY u.date, u.orders DESC

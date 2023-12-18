SELECT
    q.`Дата`,
    q.`Страна вылета`,
    q.`Страна прилета`,
    uniqExact(token) AS `Кол-во заказов`,
    SUM(q.`Полный оборот, руб`),
    SUM(q.`Билетный оборот, руб`),
    SUM(e.`Маркап, руб`),
    SUM(q.`Прибыль, руб`),
    (SUM(e.`Маркап, руб`)/SUM(q.`Билетный оборот, руб`) * 100) AS `%mp`,
    (SUM(q.`Прибыль, руб`)/SUM(q.`Полный оборот, руб`) * 100) AS `%об`

FROM (
    SELECT
        toDate(created_at) AS `Дата`,
        token,
        groupArray(departure_country)[1] AS `Страна вылета`,
        groupArray(arrival_country)[-1] AS `Страна прилета`,
        sum(total_amount)/100 AS `Полный оборот, руб`,
        sum(tickets_amount)/100 AS `Билетный оборот, руб`,
        sum(estim_profit)/100 AS `Прибыль, руб`
    FROM airlines_data
    WHERE toDate(created_at) BETWEEN '{{ Дата.start }}' AND '{{ Дата.end }}'
        AND agent = '{{ Агент }}'
        AND (test_card = 0 OR test_card is NULL)
        AND state = 'completed'
        AND smart_split = 1
    GROUP BY `Дата`, token
) AS q

INNER JOIN (
    SELECT
        token,
        count() AS `Билеты`,
        sum(markup) AS `Маркап, руб`
    FROM airlines_data_tickets
    WHERE toDate(issued_at) BETWEEN '{{ Дата.start }}' AND '{{ Дата.end }}'
    AND (test_card = 0 OR test_card is NULL)
    AND state = 'completed'
    AND smart_split = 1
    GROUP BY token
) AS e USING token
WHERE `Страна вылета` = '{{ Страна вылета }}'
AND `Страна прилета` = '{{ Страна прилета }}'
GROUP BY `Дата`, `Страна вылета`, `Страна прилета`
ORDER BY `Дата` ASC

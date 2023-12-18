SELECT
    q.bin,
    q.bank_name,
    q.country,
    q.bin_type,
    u.orders
FROM (
    SELECT
        attempts_card_bin,
        COUNT(DISTINCT booking_token) AS orders
    FROM orders
    ARRAY JOIN attempts_card_bin
    WHERE toDate(created_at) BETWEEN '{{ date.start }}' AND '{{ date.end }}'
    AND status = 'finished'
    GROUP BY attempts_card_bin
    ORDER BY orders DESC
) AS u
INNER JOIN (
    SELECT
        bin,
        bank_name,
        country,
        bin_type
    FROM cards_info
    WHERE bin != ''
) AS q ON u.attempts_card_bin = q.bin
ORDER BY u.orders DESC

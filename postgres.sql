create table company_profile
(
symbol varchar(6),
company_name varchar(100) NOT NULL,
sector varchar(20) NOT NULL,
market_cap bigint NOT NULL,
paidup_capital bigint NOT NULL,
primary key(symbol)
);

create table company_price
(
symbol varchar(6),
LTP float NOT NULL,
PC float NOT NULL,
primary key(symbol),
foreign key(symbol) references company_profile(symbol)
);

create table fundamental_report
(
symbol varchar(6),
report_as_of varchar(10),
EPS float NOT NULL,
ROE float NOT NULL,
book_value float NOT NULL,
primary key (symbol, report_as_of),
foreign key (symbol) references company_profile(symbol)
);

create table technical_signals
(
symbol varchar(6),
LTP float,
RSI float NOT NULL,
volume float NOT NULL,
ADX float NOT NULL,
MACD varchar(4) NOT NULL,
primary key (symbol),
foreign key (symbol) references company_profile(symbol)
);

create table dividend_history
(
symbol varchar(6),
fiscal_year varchar(6),
bonus_dividend float,
cash_dividend float,
primary key(symbol, fiscal_year),
foreign key(symbol) references company_profile(symbol)
);

create table news
(
news_id SERIAL,
title varchar(200) NOT NULL,
date_of_news date NOT NULL,
related_company varchar(6),
sources varchar(20),
primary key(news_id, sources),
foreign key(related_company) references company_profile(symbol)
);

create table user_profile
(
username varchar(30),
email varchar(60) UNIQUE NOT NULL,
phone bigint UNIQUE NOT NULL,
user_password varchar(224),
primary key(username)
);

create table  watchlist
(
username varchar(30),
symbol varchar(6),
primary key(username, symbol),
foreign key(username) references user_profile(username),
foreign key(symbol) references company_profile(symbol)
);

create table transaction_history
(
transaction_id SERIAL,
username varchar(30) NOT NULL,
symbol varchar(6) NOT NULL,
transaction_date timestamp NOT NULL,
quantity int NOT NULL,
rate float NOT NULL,
primary key(transaction_id),
foreign key(symbol) references company_profile(symbol),
foreign key(username) references user_profile(username)
);


select * from transaction_history;


create EXTENSION IF NOT EXISTS pgcrypto;


insert into user_profile values
('rewan', 'uni.rayone@gmail.com', 9800000001, encode(digest('rewan123', 'sha224'), 'hex')),
('ROEHAN', 'uni.rayone@gmail.com', 9800000111, encode(digest('roehan123', 'sha224'), 'hex')),
('mahesh', 'uni@gmail.com', 9800000002, encode(digest('arewan123', 'sha224'), 'hex')),
('suman', 'uni1.rayone@gmail.com', 9800000003, encode(digest('rewan12345', 'sha224'), 'hex')),
('madhu', 'uni2.rayone@gmail.com', 9800000004, encode(digest('arewan123', 'sha224'), 'hex')),
('sobit', 'uni3.rayone@gmail.com', 9800000005, encode(digest('brewan123', 'sha224'), 'hex')),
('ray', 'uni4.rayone@gmail.com', 9800000006, encode(digest('crewan123', 'sha224'), 'hex')),
('rayone', 'uni5.rayone@gmail.com', 9800000007, encode(digest('drewan123', 'sha224'), 'hex')),
('ravi', 'uni6.rayone@gmail.com', 9800000008, encode(digest('erewan123', 'sha224'), 'hex')),
('michael', 'uni7.rayone@gmail.com', 9800000009, encode(digest('frewan123', 'sha224'), 'hex')),
('hari', 'uni8.rayone@gmail.com', 9811111111, encode(digest('arewan123', 'sha224'), 'hex')),
('madan', 'uni10.rayone@gmail.com', 9800000010, encode(digest('rfewan123', 'sha224'), 'hex')),
('sandeep', 'uni11.rayone@gmail.com', 9800000011, encode(digest('frewan123', 'sha224'), 'hex')),
('surya', 'tha0751@gmail.com', 9860000014, encode(digest('arewan123', 'sha224'), 'hex')),
('vai', 'tha0752@gmail.com', 9860000013, encode(digest('wrewan123', 'sha224'), 'hex')),
('gtm', 'tha075@gmail.com', 9860000012, encode(digest('erewan123', 'sha224'), 'hex'));

insert into company_profile values
('KBL', 'Kumari Bank', 'Bank', 1000000000, 21212121221),
('NIL', 'Nepal Insurance Limited', 'Life Insurance', 123232332, 131321321),
('LEC', 'Libery Energy', 'Hydropower', 63233232, 61321321),
('ELEX', 'Nepal Electronics Bank', 'Bank', 32323233232, 323321321321),
('NEPP', 'Nepal Power', 'Hydropower', 102323233232, 10323321321321),
('LSL', 'Life Saver Limited', 'Life Insurance', 23233232, 21321321),
('NBL', 'Nepal Bank Limited', 'Bank', 532323233232, 5323321321321),
('HEX', 'Hotel Electronics', 'Hotels', 82323233232, 823321321321),
('HIH', 'Hotel Itahari', 'Hotels', 12323233232, 123321321321),
('BIH', 'Bank of Itahari', 'Bank', 62323233232, 623321321321);

insert into company_price (symbol, LTP, PC) values
('KBL', 500, 470),
('NIL', 5800, 6000),
('LEC', 400, 410),
('ELEX', 1010, 1000),
('NEPP', 500, 480),
('LSL', 1000, 1040),
('NBL', 600, 580.5),
('HEX', 1222.3, 1220),
('HIH', 1500.5, 1499.4),
('BIH', 788, 777);

insert into fundamental_report(symbol, report_as_of, EPS, ROE, book_value) values
('KBL', '77/78_q3', 20.5, 11.97, 120),
('KBL', '77/78_q2', 19.5, 10, 110),  
('NIL', '77/78_q3', 205, 50, 300),
('NIL', '77/78_q2', 211, 55, 310),
('LEC', '77/78_q3', 8, 4, 90),
('LEC', '77/78_q2', 7.5, 3.5, 88),
('ELEX', '77/78_q3', 34, 15, 180),
('ELEX', '77/78_q2', 31, 13, 178),
('NEPP', '77/78_q3', 21, 12, 119),
('NEPP', '77/78_q2', 20, 11, 118),
('LSL', '77/78_q3', 30, 12, 170),
('LSL', '77/78_q2', 35.4, 13, 180.5),
('NBL', '77/78_q3', 22, 13, 120),
('NBL', '77/78_q2', 21, 12, 117),
('HEX', '77/78_q3', 50, 15, 200),
('HEX', '77/78_q2', 48, 14, 199),
('HIH', '77/78_q3', 60, 20, 220),
('HIH', '77/78_q2', 55, 18, 200),
('BIH', '77/78_q3', 36, 20, 220),
('BIH', '77/78_q2', 35, 21, 200);


insert into technical_signals(symbol, RSI, volume, ADX, MACD) values 
('KBL', 65.1, 451000, 33.3, 'bull'), 
('NIL', 50.5, 100000, 40, 'bull'), 
('LEC', 20, 12344, 15, 'bear'),
('ELEX', 70, 1200000, 30, 'bull'),
('NEPP', 45, 212000, 16.5, 'bull'),
('LSL', 53.4, 15312, 25.29, 'bull'),
('NBL', 66.41, 406121, 34.66, 'bull'),
('HEX', 40.2, 34000, 40, 'side'),
('HIH', 35, 120000, 30, 'side'),
('BIH', 75, 335000, 44, 'bull');

UPDATE technical_signals
SET LTP = company_price.LTP
FROM company_price
WHERE technical_signals.symbol = company_price.symbol;

insert into dividend_history values
('KBL', '76/77', 5, 10),
('KBL', '75/76', 4, 11),
('NIL', '76/77', 10, 15),
('NIL', '75/76', 10, 13),
('LEC', '76/77', 0, 0), 
('LEC', '75/76', 0, 0),
('ELEX', '76/77', 20, 10), 
('ELEX', '75/76', 14, 10),
('NEPP', '76/77', 0, 0),
('NEPP', '75/76', 0, 0),
('LSL', '76/77', 5, 10),
('LSL', '75/76', 5, 10),
('NBL', '76/77', 11, 5),
('NBL', '75/76', 11, 0),
('HEX', '76/77', 0, 0),
('HEX', '75/76', 0, 0),
('HIH', '76/77', 0, 0),
('HIH', '75/76', 0, 0),
('BIH', '76/77', 20, 25),
('BIH', '75/76', 15, 20);

insert into watchlist values
('rewan', 'KBL'),
('rewan', 'HEX'),
('rewan', 'HIH'),
('rewan', 'BIH'),
('mahesh', 'HEX'),
('mahesh', 'ELEX'),
('mahesh', 'LEC'),
('suman', 'NEPP'),
('suman', 'LSL'),
('madhu', 'ELEX'),
('madhu', 'HEX'),
('madhu', 'NBL'),
('sobit', 'HEX'),
('sobit', 'LEC'),
('rayone','HIH');

insert into news(news_id, title, sources, date_of_news, related_company) values
(1, 'Kumari Bank announces right share of 1:1', 'myRepublica', '2021-07-01', 'KBL'),
(2, 'Liberty energy to test production soon', 'merokhabar', '2021-07-04', 'LEC'),
(3, 'Hotel itahari expands its area', 'itaharinews', '2021-07-05', 'HIH'),
(4, 'CEO of Nepal Insurance Limited resigns immediately', 'ekantipur', '2021-07-10', 'NIL'),
(4, 'CEO of Nepal Insurance Limited resigns immediately', 'myRepublica', '2021-07-10', 'NIL');

insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
('rewan', 'HEX', '2021-07-01', 100, 1200),
('rewan', 'HIH', '2021-07-02', 55, 1480),
('rewan', 'HIH', '2021-07-06', -20, 1500),
('suman', 'LEC', '2021-07-10', 10, 420),
('suman', 'LEC', '2021-07-15', 10, 410),
('rewan', 'BIH', '2021-07-20', 120, 785.5),
('rewan', 'LSL', '2021-07-20', 55, 1001);


Create view holdings_view as
select username, symbol, sum(quantity) as quantity  from transaction_history
group by username, symbol;

select A.symbol, A.quantity, B.LTP, ROUND(A.quantity*B.LTP::numeric, 2) as current_value from holdings_view A
inner join company_price B
on A.symbol = B.symbol
where username = 'rewan';

Create view fundamental_averaged as
SELECT F.symbol, LTP, round(avg(EPS)::numeric, 2) as EPS, round(avg(ROE)::numeric, 2) as ROE, 
round(avg(book_value)::numeric, 2) AS book_value, round(avg(LTP/EPS)::numeric, 2) AS pe_ratio 
FROM fundamental_report F
INNER JOIN company_price C
on F.symbol = C.symbol
group BY F.symbol, C.LTP;

select F.symbol, report_as_of, LTP, eps, roe, book_value, round(LTP/eps)::numeric, 2) as pe_ratio
from fundamental_report F
inner join company_price C
on F.symbol = C.symbol
where F.symbol = 'BIH';

select A.symbol, sector, LTP, volume, RSI, ADX, MACD from technical_signals A 
left join company_profile B
on A.symbol = B.symbol
order by (A.symbol);

select * from company_profile
order by(symbol);

SELECT symbol, LTP, PC, round((LTP-PC)::numeric, 2) as CH, round(((LTP-PC)/PC)::numeric*100, 2) AS CH_percent FROM company_price
order by symbol;

select *
from holdings_view A
left outer join company_price B on A.symbol = B.symbol
left outer join fundamental_averaged F on A.symbol = F.symbol
left outer join technical_signals T on A.symbol = T.symbol
where username = 'rewan'
order by (A.symbol);

select A.symbol from holdings_view A 
left outer join fundamental_report F on A.symbol = F.symbol
where username = 'rewan'
group by(A.symbol);

select * from company_price
natural join fundamental_averaged
natural join technical_signals
natural join company_profile 
where 
EPS>25 and roe>13 and 
book_value > 100 and
rsi>50 and adx >23 and
pe_ratio < 35 and
macd = 'bull'
order by symbol;

select * from fundamental_averaged
where eps > 30;

select * from fundamental_averaged
where pe_ratio <30;

select * from technical_signals
where ADX > 23 and rsi>50 and rsi<70 and MACD = 'bull';

select * from transaction_history;
select * from holdings_view;

SELECT 
    A.username, 
    A.symbol, 
    SUM(A.quantity) AS quantity, 
    SUM(A.quantity * A.rate) AS total, 
    ROUND((SUM(A.quantity * A.rate) / SUM(A.quantity))::numeric, 2) AS updated_rate,
    B.LTP, 
    ROUND(((B.LTP * SUM(A.quantity) - SUM(A.quantity * A.rate)))::numeric, 2) AS profit_loss
FROM transaction_history A
LEFT JOIN company_price B
ON A.symbol = B.symbol
GROUP BY A.username, A.symbol, B.LTP;

select symbol, LTP, PC, round((LTP-PC)::numeric, 2) AS CH, round((((LTP-PC)/PC)*100)::numeric, 2) AS CH_percent from watchlist
natural join company_price
where username = 'suman'
order by (symbol);


SELECT symbol from company_profile
where symbol not in
(select symbol from watchlist
where username = 'rewan');

SELECT 
    N.date_of_news, 
    title, 
    related_company, 
    C.sector, 
    STRING_AGG(sources, ', ') AS sources
FROM news N
INNER JOIN company_profile C
ON N.related_company = C.symbol
GROUP BY date_of_news, title, related_company, C.sector;

select C.sector, sum(A.quantity*B.LTP) as current_value 
from holdings_view A
inner join company_price B
on A.symbol = B.symbol
inner join company_profile C
on A.symbol = C.symbol
where username = 'rewan'
group by C.sector;

CREATE OR REPLACE FUNCTION get_total(total FLOAT)
RETURNS FLOAT AS $$
DECLARE
    total_converted FLOAT;
    comm FLOAT;
    ptotal FLOAT;
BEGIN
    -- If sell, make the total positive to calculate commission later
    IF total < 0 THEN
        ptotal := -total;
    ELSE
        ptotal := total;
    END IF;

    -- Commission is the same for both buy and sell
    IF ptotal > 500000 THEN
        comm := (0.34 / 100) * ptotal;
    ELSIF ptotal > 50000 THEN
        comm := (0.37 / 100) * ptotal;
    ELSIF ptotal > 2500 THEN
        comm := (0.4 / 100) * ptotal;
    ELSIF ptotal > 100 THEN
        comm := 10;
    ELSE
        comm := 0;
    END IF;

    -- If sell conditions
    IF total < 0 THEN
        total := -total;
        total_converted := total - (comm + total * (0.015 / 100) + 25);
        RETURN total_converted;
    END IF;

    total_converted := total + comm + 25 + (0.015 / 100) * total;
    RETURN total_converted;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cap_gain(total FLOAT, trans_date DATE)
RETURNS FLOAT AS $$
BEGIN
    IF total < 0 THEN
        RETURN total;
    ELSIF CURRENT_DATE - trans_date < 365 THEN
        total := total - 0.075 * total;
    ELSE
        total := total - 0.05 * total;
    END IF;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS portfolio;

CREATE OR REPLACE FUNCTION portfolio(username_input VARCHAR)
RETURNS TABLE (
    symbol VARCHAR,
    quantity INT,
    LTP FLOAT,
    current_value NUMERIC,
    profit_loss NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        T.symbol, 
        CAST(SUM(T.quantity) AS INT) AS quantity, -- Explicitly cast SUM to INT
        C.LTP,
        ROUND(CAST(get_total(SUM(T.quantity) * C.LTP) AS NUMERIC), 2) AS current_value,
        ROUND(
            CAST(
                cap_gain(
                    (SUM(T.quantity) * C.LTP) - (SUM(T.quantity * T.rate)), 
                    CAST(MIN(T.transaction_date) AS DATE)
                ) AS NUMERIC
            ), 
            2
        ) AS profit_loss
    FROM transaction_history T
    INNER JOIN company_price C
    ON T.symbol = C.symbol
    WHERE T.username = username_input
    GROUP BY T.symbol, C.LTP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM portfolio('rewan');

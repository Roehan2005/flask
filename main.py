from flask import Flask, render_template, request, session
from datetime import timedelta
import hashlib
import yaml
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

# Load database configuration from YAML
with open(r'/Users/roehit/Documents/GitHub/flask/db.yaml', 'r') as file:
    db = yaml.load(file, Loader=yaml.FullLoader)

app.secret_key = db['secret_key']
app.permanent_session_lifetime = timedelta(minutes=10)  # Session lasts for 10 minutes

# PostgreSQL database connection
def get_db_connection():
    return psycopg2.connect(
        dbname=db['postgres_db'],
        user=db['postgres_user'],
        password=db['postgres_password'],
        host=db['postgres_host'],
        cursor_factory=RealDictCursor
    )

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        session.permanent = True
        user_details = request.form
        try:
            username = user_details['username']
            password = user_details['password']
            password_hashed = hashlib.sha224(password.encode()).hexdigest()
        except:
            if request.form['logout'] == '':
                session.pop('user')
            return render_template('/index.html', session=session)

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT username, user_password FROM user_profile')
        all_users = cur.fetchall()
        conn.close()

        for user in all_users:
            if user['username'] == username and user['user_password'] == password_hashed:
                session['user'] = username
                return portfolio()
        return render_template('alert2.html')
    else:
        return render_template('index.html', session=session)


@app.route('/portfolio.html')
def portfolio():
    if "user" not in session:
        return render_template('alert1.html')

    conn = get_db_connection()
    cur = conn.cursor()
    user = [session['user']]

    # Query for holdings
    cur.execute('CALL portfolio(%s)', user)
    holdings = cur.fetchall()

    # Query for watchlist
    query_watchlist = '''
    select symbol, LTP, PC, round((LTP-PC)::numeric, 2) AS CH, round((((LTP-PC)/PC)*100)::numeric, 2) AS CH_percent from watchlist
    natural join company_price
    where username = 'suman'
    order by (symbol);
    '''
    cur.execute(query_watchlist, user)
    watchlist = cur.fetchall()

    # Query for stock suggestion
    query_suggestions = '''
    SELECT symbol, EPS, ROE, book_value, rsi, adx, pe_ratio, macd 
    FROM company_price
    INNER JOIN fundamental_averaged USING (symbol)
    INNER JOIN technical_signals USING (symbol)
    INNER JOIN company_profile USING (symbol)
    WHERE EPS > 25 AND ROE > 13 AND book_value > 100 AND rsi > 50 AND adx > 23 AND pe_ratio < 35 AND macd = 'bull'
    ORDER BY symbol
    '''
    cur.execute(query_suggestions)
    suggestions = cur.fetchall()

    # Query on EPS
    query_eps = '''
    SELECT symbol, ltp, eps 
    FROM fundamental_averaged
    WHERE eps > 30
    ORDER BY eps
    '''
    cur.execute(query_eps)
    eps = cur.fetchall()

    # Query on PE Ratio
    query_pe = '''
    SELECT symbol, ltp, pe_ratio 
    FROM fundamental_averaged
    WHERE pe_ratio < 30
    '''
    cur.execute(query_pe)
    pe = cur.fetchall()

    # Query on technical signals
    query_technical = '''
    SELECT * 
    FROM technical_signals
    WHERE ADX > 23 AND rsi > 50 AND rsi < 70 AND MACD = 'bull'
    '''
    cur.execute(query_technical)
    technical = cur.fetchall()

    # Query for pie chart
    query_sectors = '''
    SELECT C.sector, SUM(A.quantity * B.LTP) AS current_value 
    FROM holdings_view A
    INNER JOIN company_price B ON A.symbol = B.symbol
    INNER JOIN company_profile C ON A.symbol = C.symbol
    WHERE username = %s
    GROUP BY C.sector
    '''
    cur.execute(query_sectors, user)
    sectors_total = cur.fetchall()
    conn.close()

    # Convert list to JSON type having percentage and label keys
    piechart_dict = toPercentage(sectors_total)
    piechart_dict[0]['type'] = 'pie'
    piechart_dict[0]['hole'] = 0.4

    return render_template('portfolio.html', holdings=holdings, user=user[0], suggestions=suggestions, eps=eps, pe=pe, technical=technical, watchlist=watchlist, piechart=piechart_dict)


@app.route('/add_transaction.html', methods=['GET', 'POST'])
def add_transaction():
    conn = get_db_connection()
    cur = conn.cursor()

    # Query for all companies (for dropdown menu)
    query_companies = '''SELECT symbol FROM company_profile'''
    cur.execute(query_companies)
    companies = cur.fetchall()

    if request.method == 'POST':
        transaction_details = request.form
        symbol = transaction_details['symbol']
        date = transaction_details['transaction_date']
        transaction_type = transaction_details['transaction_type']
        quantity = float(transaction_details['quantity'])
        rate = float(transaction_details['rate'])
        if transaction_type == 'Sell':
            quantity = -quantity

        query = '''INSERT INTO transaction_history(username, symbol, transaction_date, quantity, rate) 
                   VALUES (%s, %s, %s, %s, %s)'''
        values = [session['user'], symbol, date, quantity, rate]
        cur.execute(query, values)
        conn.commit()

    conn.close()
    return render_template('add_transaction.html', companies=companies)


@app.route('/add_watchlist.html', methods=['GET', 'POST'])
def add_watchlist():
    conn = get_db_connection()
    cur = conn.cursor()

    # Query for companies (for dropdown menu) excluding those already in watchlist
    query_companies = '''
    SELECT symbol FROM company_profile
    WHERE symbol NOT IN (
        SELECT symbol FROM watchlist WHERE username = %s
    )
    '''
    user = [session['user']]
    cur.execute(query_companies, user)
    companies = cur.fetchall()

    if request.method == 'POST':
        watchlist_details = request.form
        symbol = watchlist_details['symbol']
        query = '''INSERT INTO watchlist(username, symbol) VALUES (%s, %s)'''
        values = [session['user'], symbol]
        cur.execute(query, values)
        conn.commit()

    conn.close()
    return render_template('add_watchlist.html', companies=companies)


@app.route('/stockprice.html')
def current_price(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''
        SELECT symbol, LTP, PC, ROUND((LTP-PC), 2) AS CH, ROUND(((LTP-PC)/PC)*100, 2) AS CH_percent 
        FROM company_price
        ORDER BY symbol
        '''
        cur.execute(query)
    else:
        query = '''
        SELECT symbol, LTP, PC, ROUND((LTP-PC), 2) AS CH, ROUND(((LTP-PC)/PC)*100, 2) AS CH_percent 
        FROM company_price
        WHERE symbol = %s
        '''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('stockprice.html', values=rv)


@app.route('/fundamental.html', methods=['GET'])
def fundamental_report(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''SELECT * FROM fundamental_averaged'''
        cur.execute(query)
    else:
        query = '''
        SELECT F.symbol, report_as_of, LTP, eps, roe, book_value, ROUND(LTP/eps, 2) AS pe_ratio
        FROM fundamental_report F
        INNER JOIN company_price C ON F.symbol = C.symbol
        WHERE F.symbol = %s
        '''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('fundamental.html', values=rv)


@app.route('/technical.html')
def technical_analysis(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''
        SELECT A.symbol, sector, LTP, volume, RSI, ADX, MACD 
        FROM technical_signals A 
        LEFT JOIN company_profile B ON A.symbol = B.symbol
        ORDER BY A.symbol
        '''
        cur.execute(query)
    else:
        query = '''SELECT * FROM technical_signals WHERE symbol = %s'''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('technical.html', values=rv)


@app.route('/companyprofile.html')
def company_profile(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''SELECT * FROM company_profile ORDER BY symbol'''
        cur.execute(query)
    else:
        query = '''SELECT * FROM company_profile WHERE symbol = %s'''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('companyprofile.html', values=rv)


@app.route('/dividend.html')
def dividend_history(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''SELECT * FROM dividend_history ORDER BY symbol'''
        cur.execute(query)
    else:
        query = '''SELECT * FROM dividend_history WHERE symbol = %s'''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('dividend.html', values=rv)


@app.route('/watchlist.html')
def watchlist():
    if 'user' not in session:
        return render_template('alert1.html')

    conn = get_db_connection()
    cur = conn.cursor()

    query_watchlist = '''
    SELECT symbol, LTP, PC, ROUND((LTP-PC), 2) AS CH, ROUND(((LTP-PC)/PC)*100, 2) AS CH_percent 
    FROM watchlist
    NATURAL JOIN company_price
    WHERE username = %s
    ORDER BY symbol
    '''
    cur.execute(query_watchlist, [session['user']])
    watchlist = cur.fetchall()
    conn.close()

    return render_template('watchlist.html', user=session['user'], watchlist=watchlist)


@app.route('/holdings.html')
def holdings():
    if "user" not in session:
        return render_template('alert1.html')

    conn = get_db_connection()
    cur = conn.cursor()

    query_holdings = '''
    SELECT A.symbol, A.quantity, B.LTP, ROUND(A.quantity * B.LTP, 2) AS current_value 
    FROM holdings_view A
    INNER JOIN company_price B ON A.symbol = B.symbol
    WHERE username = %s
    '''
    cur.execute(query_holdings, [session['user']])
    holdings = cur.fetchall()
    conn.close()

    return render_template('holdings.html', user=session['user'], holdings=holdings)


@app.route('/news.html')
def news(company='all'):
    conn = get_db_connection()
    cur = conn.cursor()

    if company == 'all':
        query = '''
        SELECT date_of_news, title, related_company, C.sector, STRING_AGG(sources, ', ') AS sources 
        FROM news N
        INNER JOIN company_profile C ON N.related_company = C.symbol
        GROUP BY title, date_of_news, related_company, C.sector
        '''
        cur.execute(query)
    else:
        query = '''
        SELECT date_of_news, title, related_company, related_sector, sources 
        FROM news 
        WHERE related_company = %s
        '''
        cur.execute(query, [company])

    rv = cur.fetchall()
    conn.close()
    return render_template('news.html', values=rv)


def toPercentage(sectors_total):
    json_format = {}
    total = 0

    for row in sectors_total:
        total += row['current_value']

    json_format['values'] = [round((row['current_value'] / total) * 100, 2) for row in sectors_total]
    json_format['labels'] = [row['sector'] for row in sectors_total]
    return [json_format]


if __name__ == '__main__':
    app.run(debug=True)
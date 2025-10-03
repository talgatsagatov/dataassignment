import os
import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor

def get_conn():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
        dbname=os.getenv("PGDATABASE", "olistdb"),
        connect_timeout=10
    )

QUERIES = {
    "monthly_revenue": """
        WITH items AS (
          SELECT oi.order_id,
                 DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
                 SUM(oi.price + oi.freight_value) AS gross
          FROM olist.order_items oi
          JOIN olist.orders o USING (order_id)
          WHERE o.order_status IN ('delivered','shipped','invoiced','approved')
          GROUP BY oi.order_id, month
        )
        SELECT month::date AS month, SUM(gross) AS revenue
        FROM items
        GROUP BY month
        ORDER BY month;
    """,
    "payment_mix": """
        WITH counts AS (
          SELECT payment_type, COUNT(*) AS cnt
          FROM olist.order_payments
          GROUP BY payment_type
        )
        SELECT payment_type,
               cnt,
               ROUND(cnt * 100.0 / SUM(cnt) OVER (), 2) AS pct
        FROM counts
        ORDER BY pct DESC;
    """,
    "top_categories": """
        SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
               ROUND(SUM(oi.price + oi.freight_value),2) AS revenue
        FROM olist.order_items oi
        JOIN olist.products p USING (product_id)
        LEFT JOIN olist.product_category_name_translation t
               ON t.product_category_name = p.product_category_name
        GROUP BY category
        ORDER BY revenue DESC
        LIMIT 10;
    """
}

def run_query(conn, sql):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql)
        rows = cur.fetchall()
        return pd.DataFrame(rows)

def main():
    conn = get_conn()
    out_dir = os.path.join(os.getcwd(), "exports")
    os.makedirs(out_dir, exist_ok=True)

    for name, sql in QUERIES.items():
        print(f"\n--- Running: {name} ---")
        df = run_query(conn, sql)
        if not df.empty:
            print(df.head(10).to_string(index=False))
        else:
            print("(no rows)")
        csv_path = os.path.join(out_dir, f"{name}.csv")
        df.to_csv(csv_path, index=False, encoding="utf-8")
        print(f"Saved: {csv_path} ({len(df)} rows)")

    conn.close()

if __name__ == "__main__":
    main()

import sqlite3
import os
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "expenses.db")


def _connect():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    conn = _connect()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            description TEXT DEFAULT '',
            expense_date TEXT NOT NULL,
            payer TEXT NOT NULL,
            is_shared INTEGER DEFAULT 1,
            settlement_id INTEGER,
            created_at TEXT DEFAULT (datetime('now', 'localtime')),
            FOREIGN KEY (settlement_id) REFERENCES settlements(id)
        );

        CREATE TABLE IF NOT EXISTS settlements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            settlement_date TEXT DEFAULT (datetime('now', 'localtime')),
            note TEXT DEFAULT '',
            total_amount REAL NOT NULL,
            me_paid REAL NOT NULL,
            wife_paid REAL NOT NULL,
            net_transfer REAL NOT NULL
        );
    """)
    conn.commit()
    conn.close()


# ---------- Expenses ----------

def add_expense(amount, category, description, expense_date, payer, is_shared):
    conn = _connect()
    conn.execute(
        "INSERT INTO expenses (amount, category, description, expense_date, payer, is_shared) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        (amount, category, description, expense_date, payer, 1 if is_shared else 0),
    )
    conn.commit()
    conn.close()


def get_expenses(*, settled_only=False, unsettled_only=False):
    conn = _connect()
    conditions = []
    if settled_only:
        conditions.append("settlement_id IS NOT NULL")
    elif unsettled_only:
        conditions.append("settlement_id IS NULL")

    where = ("WHERE " + " AND ".join(conditions)) if conditions else ""
    rows = conn.execute(
        f"SELECT * FROM expenses {where} ORDER BY expense_date DESC, id DESC"
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_unsettled_shared_expenses():
    conn = _connect()
    rows = conn.execute(
        "SELECT * FROM expenses WHERE is_shared = 1 AND settlement_id IS NULL "
        "ORDER BY expense_date, id"
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def delete_expense(expense_id):
    conn = _connect()
    conn.execute("DELETE FROM expenses WHERE id = ?", (expense_id,))
    conn.commit()
    conn.close()


# ---------- Settlements ----------

def create_settlement(expense_ids, note):
    conn = _connect()
    placeholders = ",".join("?" * len(expense_ids))
    rows = conn.execute(
        f"SELECT * FROM expenses WHERE id IN ({placeholders}) AND is_shared = 1 AND settlement_id IS NULL",
        expense_ids,
    ).fetchall()

    if not rows:
        conn.close()
        raise ValueError("没有可结清的 AA 支出")

    total = sum(r["amount"] for r in rows)
    me_paid = sum(r["amount"] for r in rows if r["payer"] == "我")
    wife_paid = sum(r["amount"] for r in rows if r["payer"] == "老婆")
    net = round((me_paid - wife_paid) / 2, 2)

    cur = conn.execute(
        "INSERT INTO settlements (note, total_amount, me_paid, wife_paid, net_transfer) "
        "VALUES (?, ?, ?, ?, ?)",
        (note, round(total, 2), round(me_paid, 2), round(wife_paid, 2), net),
    )
    settlement_id = cur.lastrowid

    conn.executemany(
        "UPDATE expenses SET settlement_id = ? WHERE id = ?",
        [(settlement_id, eid) for eid in expense_ids],
    )
    conn.commit()
    conn.close()
    return settlement_id


def get_settlements():
    conn = _connect()
    rows = conn.execute(
        "SELECT * FROM settlements ORDER BY settlement_date DESC"
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_settlement_expenses(settlement_id):
    conn = _connect()
    rows = conn.execute(
        "SELECT * FROM expenses WHERE settlement_id = ? ORDER BY expense_date, id",
        (settlement_id,),
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]

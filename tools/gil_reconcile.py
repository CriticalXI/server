"""
Reconcile the `audit_gil` ledger against actual character gil balances.

Every character is created with 0 gil (sql/triggers.sql), so the gil the module
saw move (`SUM(delta)`) should equal the live char_inventory balance. Whatever is
left over is gil that moved unobserved: a disabled category, the server running
with the module off, or an out-of-band DB edit. Rows with a NULL delta are
movements whose size the module could not know and are counted separately.

Usage:
    python tools/gil_reconcile.py                 # summary and any mismatches
    python tools/gil_reconcile.py --limit 50      # cap the mismatch list
    python tools/gil_reconcile.py --charid 12345  # drill into one character
    python tools/gil_reconcile.py --sources       # mint/burn breakdown by source

Requires the `mariadb` package (already a dbtool dependency).
"""

import argparse
import os
import re
import sys

try:
    import mariadb
except ImportError:
    print("ERROR: the 'mariadb' package is required.")
    print("Install it with: python -m pip install -r tools/requirements.txt")
    sys.exit(1)


server_dir_path = os.path.normpath(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
)

GIL_ITEM_ID = 65535


def read_network_setting(name, default):
    """Read one SQL_* value from settings/network.lua, honouring quotes so passwords survive."""
    pattern = re.compile(
        rf"^\s*{name}\s*=\s*(?:'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\"|([^,\s]+))",
        re.M,
    )

    for candidate in ("settings/network.lua", "settings/default/network.lua"):
        path = os.path.join(server_dir_path, candidate)
        if not os.path.exists(path):
            continue

        with open(path, "r", errors="ignore") as handle:
            match = pattern.search(handle.read())
            if match:
                return next(group for group in match.groups() if group is not None)

    return default


def connect():
    host = os.getenv("XI_NETWORK_SQL_HOST") or read_network_setting(
        "SQL_HOST", "127.0.0.1"
    )
    port = int(
        os.getenv("XI_NETWORK_SQL_PORT") or read_network_setting("SQL_PORT", 3306)
    )
    login = os.getenv("XI_NETWORK_SQL_LOGIN") or read_network_setting(
        "SQL_LOGIN", "root"
    )
    password = os.getenv("XI_NETWORK_SQL_PASSWORD") or read_network_setting(
        "SQL_PASSWORD", "root"
    )
    database = os.getenv("XI_NETWORK_SQL_DATABASE") or read_network_setting(
        "SQL_DATABASE", "xidb"
    )

    try:
        return mariadb.connect(
            host=host, user=login, passwd=password, db=database, port=port
        )
    except mariadb.Error as err:
        print(f"ERROR: could not connect to {database} at {host}:{port}: {err}")
        sys.exit(1)


def check_table_exists(cur):
    cur.execute("SHOW TABLES LIKE 'audit_gil'")
    if cur.fetchone() is None:
        print("ERROR: table `audit_gil` does not exist.")
        print("Import it with: modules/phoenix/sql/audit_gil.sql")
        sys.exit(1)


def reconcile(cur, limit):
    """Compare each live character's balance against what the ledger saw move."""
    cur.execute(
        f"""
        SELECT
            c.charid,
            inv.quantity                     AS live,
            last.balance_after               AS last_recorded,
            COALESCE(led.observed, 0)        AS observed,
            COALESCE(led.unknown_rows, 0)    AS unknown_rows,
            COALESCE(led.rows_seen, 0)       AS rows_seen
        FROM chars c
        JOIN char_inventory inv
          ON inv.charid = c.charid AND inv.itemId = {GIL_ITEM_ID} AND inv.location = 0 AND inv.slot = 0
        LEFT JOIN (
            SELECT charid,
                   COUNT(*)                AS rows_seen,
                   SUM(COALESCE(delta, 0)) AS observed,
                   SUM(delta IS NULL)      AS unknown_rows,
                   MAX(id)                 AS last_id
            FROM audit_gil
            GROUP BY charid
        ) AS led ON led.charid = c.charid
        LEFT JOIN audit_gil last ON last.id = led.last_id
        ORDER BY c.charid
        """
    )

    rows = cur.fetchall()
    audited = [row for row in rows if row[5] > 0]
    unaudited_with_gil = [row for row in rows if row[5] == 0 and row[1] > 0]

    mismatches = []
    for charid, live, last_recorded, observed, unknown_rows, rows_seen in audited:
        since_last = live - last_recorded
        unexplained = live - observed
        if since_last != 0 or unexplained != 0:
            mismatches.append(
                (charid, live, since_last, unexplained, unknown_rows, rows_seen)
            )

    print(f"Characters with ledger rows      : {len(audited)}")
    print(f"Reconciled exactly               : {len(audited) - len(mismatches)}")
    print(f"Mismatched                       : {len(mismatches)}")
    print(f"Characters with gil, never audited: {len(unaudited_with_gil)}")

    if not audited:
        print("\nNo ledger rows yet. Is map.AUDIT_GIL enabled?")
        return 0

    if not mismatches:
        print(
            "\nOK: every audited character's balance is fully explained by the ledger."
        )
        return 0

    print(
        f"\n{'charid':>10} {'live':>14} {'since last':>14} {'unexplained':>14} {'null rows':>10} {'rows':>8}"
    )
    print("-" * 76)
    for charid, live, since_last, unexplained, unknown_rows, rows_seen in mismatches[
        :limit
    ]:
        print(
            f"{charid:>10} {live:>14} {since_last:>+14} {unexplained:>+14} {unknown_rows:>10} {rows_seen:>8}"
        )

    if len(mismatches) > limit:
        print(f"... and {len(mismatches) - limit} more (raise --limit to see them)")

    total_unexplained = sum(row[3] for row in mismatches)
    print(f"\nNet unexplained gil: {total_unexplained:+}")
    print(
        "\n'since last' is gil that moved after the character's newest ledger row.\n"
        "'unexplained' is live balance minus every delta the module saw; it includes the\n"
        "balance a character already had before the ledger was enabled, disabled categories\n"
        "such as mob drops, and rows with a NULL delta. None of it means a ledger row is wrong."
    )

    return 1


def show_sources(cur):
    """Break the ledger down by source, so mint and burn are visible per category."""
    cur.execute(
        """
        SELECT
            source,
            COUNT(*)                                       AS rows_seen,
            SUM(CASE WHEN delta > 0 THEN delta ELSE 0 END) AS minted,
            SUM(CASE WHEN delta < 0 THEN delta ELSE 0 END) AS burned,
            SUM(COALESCE(delta, 0))                        AS net,
            SUM(delta IS NULL)                             AS unknown_rows
        FROM audit_gil
        GROUP BY source
        ORDER BY ABS(SUM(COALESCE(delta, 0))) DESC
        """
    )

    rows = cur.fetchall()
    if not rows:
        print("No ledger rows yet.")
        return

    print(
        f"{'source':>18} {'rows':>10} {'in':>16} {'out':>16} {'net':>16} {'null rows':>10}"
    )
    print("-" * 92)
    for source, rows_seen, minted, burned, net, unknown_rows in rows:
        print(
            f"{source:>18} {rows_seen:>10} {minted or 0:>+16} {burned or 0:>+16} {net:>+16} {unknown_rows:>10}"
        )

    print(
        "\nNote: PlayerTrade and AuctionBid net to zero across the server. BazaarBuy debits the\n"
        "taxed price while BazaarSell credits the base price, so their combined net is the\n"
        "bazaar tax burned. Only mint and burn categories change total supply."
    )


def show_character(cur, charid, limit):
    """Show one character's most recent movements, newest first."""
    cur.execute(
        """
        SELECT id, date, source, balance_after, delta, counterparty, itemid, source_detail, txn_id
        FROM audit_gil
        WHERE charid = ?
        ORDER BY id DESC
        LIMIT ?
        """,
        (charid, limit),
    )

    rows = cur.fetchall()
    if not rows:
        print(f"No ledger rows for charid {charid}.")
        return

    print(
        f"{'id':>10} {'date':>12} {'source':>18} {'delta':>13} {'balance':>13} {'txn':>8}  detail"
    )
    print("-" * 100)
    for (
        row_id,
        date,
        source,
        balance_after,
        delta,
        counterparty,
        itemid,
        detail,
        txn_id,
    ) in rows:
        delta_text = "?" if delta is None else f"{delta:+}"
        extra = detail or ""
        if itemid:
            extra = f"item {itemid} {extra}".strip()
        if counterparty:
            extra = f"{extra} (with {counterparty})".strip()

        print(
            f"{row_id:>10} {date:>12} {source:>18} {delta_text:>13} {balance_after:>13} {txn_id:>8}  {extra}"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Reconcile the audit_gil ledger against char_inventory."
    )
    parser.add_argument(
        "--limit", type=int, default=25, help="max rows to list (default 25)"
    )

    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--charid", type=int, help="show one character's movements")
    mode.add_argument(
        "--sources", action="store_true", help="show mint/burn breakdown by source"
    )
    args = parser.parse_args()

    conn = connect()
    cur = conn.cursor()
    check_table_exists(cur)

    try:
        if args.charid is not None:
            show_character(cur, args.charid, args.limit)
            return 0

        if args.sources:
            show_sources(cur)
            return 0

        return reconcile(cur, args.limit)
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    sys.exit(main())

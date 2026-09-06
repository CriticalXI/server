import mariadb

DROPPED_TABLES = [
    "fishing_area",
    "fishing_bait",
    "fishing_bait_affinity",
    "fishing_catch",
    "fishing_fish",
    "fishing_group",
    "fishing_mob",
    "fishing_rod",
    "fishing_zone",
]


def migration_name():
    return "Drop the fishing tables the YAML files replaced"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    for table in DROPPED_TABLES:
        cur.execute(f"SHOW TABLES LIKE '{table}';")
        if cur.fetchone():
            return True

    return False


def migrate(cur, db):
    try:
        for table in DROPPED_TABLES:
            cur.execute(f"DROP TABLE IF EXISTS `{table}`;")

        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))

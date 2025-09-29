from lib.sql_validator import is_safe_sql

def test_rejects_dml():
    ok, msg = is_safe_sql("DELETE FROM users;")
    assert not ok

def test_requires_select():
    ok, _ = is_safe_sql("INSERT INTO x (a) VALUES (1);")
    assert not ok

def test_requires_limit():
    ok, msg = is_safe_sql("SELECT * FROM big_table")
    assert not ok
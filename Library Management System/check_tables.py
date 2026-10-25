from db import get_db_connection


try:
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SHOW TABLES")

    tables = cursor.fetchall()

    print("\nDatabase Tables:")
    print("----------------")

    for table in tables:
        print(table[0])

    cursor.close()
    connection.close()

except Exception as e:
    print("Error:", e)
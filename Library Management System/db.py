import mysql.connector
from config import Config


def get_db_connection():
    connection = mysql.connector.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        database=Config.DB_NAME,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD
    )
    return connection


def execute_query(query, params=None, fetch=False):
    connection = None
    cursor = None

    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        if fetch:
            result = cursor.fetchall()
            return result
        else:
            connection.commit()
            result = True
            return result

    except Exception as e:
        print("Database Error:", e)
        return None

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()
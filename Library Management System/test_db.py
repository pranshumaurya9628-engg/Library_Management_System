from db import get_db_connection


try:
    connection = get_db_connection()

    if connection.is_connected():
        print("MySQL Database Connected Successfully!")

    connection.close()

except Exception as e:
    print("Connection Failed!")
    print(e)
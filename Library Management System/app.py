from flask import Flask, render_template, request, redirect, url_for, session, flash
from db import get_db_connection
from datetime import date, timedelta
import re


app = Flask(__name__)

app.secret_key = "library-management-secret-key"


# =========================================================
# HOME
# =========================================================

@app.route("/")
def index():

    if "admin_id" in session:
        return redirect(url_for("dashboard"))

    return redirect(url_for("login"))


# =========================================================
# LOGIN
# =========================================================

@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form.get("username", "").strip()
        password = request.form.get("password", "").strip()

        # -------------------------
        # INPUT VALIDATION
        # -------------------------

        if not username and not password:
            flash("Username and password are required!", "danger")
            return render_template("login.html")

        if not username:
            flash("Username is required!", "danger")
            return render_template("login.html")

        if not password:
            flash("Password is required!", "danger")
            return render_template("login.html")

        connection = None
        cursor = None

        try:

            connection = get_db_connection()
            cursor = connection.cursor(dictionary=True)

            cursor.execute("""
                SELECT
                    admin_id,
                    username,
                    passward
                FROM admin
                WHERE username = %s
            """, (username,))

            admin = cursor.fetchone()

            if not admin:

                flash("Invalid username or password!", "danger")
                return render_template("login.html")

            if admin["passward"] != password:

                flash("Invalid username or password!", "danger")
                return render_template("login.html")

            # -------------------------
            # LOGIN SUCCESS
            # -------------------------

            session["admin_id"] = admin["admin_id"]
            session["username"] = admin["username"]

            flash("Login successful!", "success")

            return redirect(url_for("dashboard"))

        except Exception as e:

            print("LOGIN ERROR:", repr(e))

            if connection:
                connection.rollback()

            flash(
                "Unable to login. Please try again!",
                "danger"
            )

            return render_template("login.html")

        finally:

            if cursor:
                cursor.close()

            if connection:
                connection.close()

    return render_template("login.html")

# =========================================================
# LOGOUT
# =========================================================

@app.route("/logout")
def logout():

    session.clear()

    flash("Logged out successfully!", "success")

    return redirect(url_for("login"))


# =========================================================
# DASHBOARD
# =========================================================

@app.route("/dashboard")
def dashboard():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor()

        # -------------------------
        # TOTAL BOOKS
        # -------------------------

        cursor.execute("SELECT COUNT(*) FROM books")
        total_books = cursor.fetchone()[0]

        # -------------------------
        # TOTAL STUDENTS
        # -------------------------

        cursor.execute("SELECT COUNT(*) FROM students")
        total_students = cursor.fetchone()[0]

        # -------------------------
        # TOTAL CATEGORIES
        # -------------------------

        cursor.execute("SELECT COUNT(*) FROM categories")
        total_categories = cursor.fetchone()[0]

        # -------------------------
        # TOTAL ISSUED BOOKS
        # -------------------------

        cursor.execute("""
            SELECT COUNT(*)
            FROM book_issues
            WHERE status = 'Issued'
        """)

        total_issues = cursor.fetchone()[0]

        # -------------------------
        # TOTAL UNPAID FINES
        # -------------------------

        cursor.execute("""
            SELECT COALESCE(SUM(amount), 0)
            FROM fines
            WHERE paid_status = 'Unpaid'
        """)

        total_fines = cursor.fetchone()[0]

        return render_template(
            "dashboard.html",
            username=session["username"],
            total_books=total_books,
            total_students=total_students,
            total_categories=total_categories,
            total_issues=total_issues,
            total_fines=total_fines
        )

    except Exception as e:

        print("DASHBOARD ERROR:", repr(e))

        return render_template(
            "dashboard.html",
            username=session["username"],
            total_books=0,
            total_students=0,
            total_categories=0,
            total_issues=0,
            total_fines=0
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# =========================================================
# MANAGE FINE
# =========================================================

@app.route("/manage-fine")
def manage_fine():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                f.fine_id,
                f.issue_id,
                f.amount,
                f.paid_status,

                s.student_id,
                s.name,
                s.roll_no,
                s.phone_no,

                b.book_id,
                b.title,

                bi.issue_date,
                bi.due_date,
                bi.return_date,
                bi.status

            FROM fines f

            INNER JOIN book_issues bi
                ON f.issue_id = bi.issue_id

            INNER JOIN students s
                ON bi.student_id = s.student_id

            INNER JOIN books b
                ON bi.book_id = b.book_id

            ORDER BY f.fine_id DESC
        """)

        fines = cursor.fetchall()

        return render_template(
            "manage_fine.html",
            fines=fines
        )

    except Exception as e:

        print("MANAGE FINE ERROR:", repr(e))

        flash(
            "Unable to load fine records!",
            "danger"
        )

        return redirect(url_for("dashboard"))

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# =========================================================
# PAY FINE
# =========================================================

@app.route("/fine/pay/<int:fine_id>", methods=["POST"])
def pay_fine(fine_id):

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE fines
            SET paid_status = 'Paid'
            WHERE fine_id = %s
        """, (fine_id,))

        connection.commit()

        flash(
            "Fine marked as Paid successfully!",
            "success"
        )

    except Exception as e:

        print("PAY FINE ERROR:", repr(e))

        if connection:
            connection.rollback()

        flash(
            "Unable to update fine!",
            "danger"
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

    return redirect(url_for("manage_fine"))


# =========================================================
# BOOKS
# =========================================================

@app.route("/books")
def books():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                b.book_id,
                b.title,
                b.author,
                b.category_id,
                c.category_name,
                b.quantity,
                b.available_quantity

            FROM books b

            LEFT JOIN categories c
                ON b.category_id = c.category_id

            ORDER BY b.book_id DESC
        """)

        books_list = cursor.fetchall()

        cursor.execute("""
            SELECT
                category_id,
                category_name

            FROM categories

            ORDER BY category_name
        """)

        categories = cursor.fetchall()

        return render_template(
            "books.html",
            books=books_list,
            categories=categories
        )

    except Exception as e:

        print("BOOKS ERROR:", repr(e))

        flash(
            "Database error! Check terminal.",
            "danger"
        )

        return redirect(url_for("dashboard"))

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# =========================================================
# ADD BOOK
# =========================================================

@app.route("/books/add", methods=["POST"])
def add_book():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    title = request.form.get("title", "").strip()
    author = request.form.get("author", "").strip()
    category_id = request.form.get("category_id", "").strip()
    quantity = request.form.get("quantity", "").strip()

    # -------------------------
    # VALIDATION
    # -------------------------

    if not title or not author or not category_id or not quantity:

        flash(
            "All fields are required!",
            "danger"
        )

        return redirect(url_for("books"))

    connection = None
    cursor = None

    try:

        quantity = int(quantity)

        if quantity <= 0:

            flash(
                "Quantity must be greater than 0!",
                "danger"
            )

            return redirect(url_for("books"))

        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("""
            INSERT INTO books
            (
                title,
                author,
                category_id,
                quantity,
                available_quantity
            )

            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                %s
            )
        """, (
            title,
            author,
            category_id,
            quantity,
            quantity
        ))

        connection.commit()

        flash(
            "Book added successfully!",
            "success"
        )

    except ValueError:

        flash(
            "Quantity must be a valid number!",
            "danger"
        )

    except Exception as e:

        print("ADD BOOK ERROR:", repr(e))

        if connection:
            connection.rollback()

        flash(
            "Unable to add book!",
            "danger"
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

    return redirect(url_for("books"))


# =========================================================
# DELETE BOOK
# =========================================================

@app.route("/books/delete/<int:book_id>", methods=["POST"])
def delete_book(book_id):

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("""
            DELETE FROM books
            WHERE book_id = %s
        """, (book_id,))

        connection.commit()

        flash(
            "Book deleted successfully!",
            "success"
        )

    except Exception as e:

        print("DELETE BOOK ERROR:", repr(e))

        if connection:
            connection.rollback()

        flash(
            "Book cannot be deleted. It may be linked with issued books.",
            "danger"
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

    return redirect(url_for("books"))




# =========================================================
# ISSUE BOOK
# =========================================================

@app.route("/issue-book", methods=["GET", "POST"])
def issue_book():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        # =================================================
        # POST - ISSUE BOOK
        # =================================================

        if request.method == "POST":

            print("===== ISSUE BOOK POST =====")
            print("FORM DATA:", request.form)

            student_id = request.form.get("student_id", "").strip()
            book_id = request.form.get("book_id", "").strip()

            # -------------------------
            # BASIC VALIDATION
            # -------------------------

            if not student_id or not book_id:

                flash(
                    "Please select student and book!",
                    "danger"
                )

                return redirect(url_for("issue_book"))

            # =================================================
            # CHECK BOOK
            # =================================================

            cursor.execute("""
                SELECT
                    book_id,
                    title,
                    available_quantity

                FROM books

                WHERE book_id = %s
            """, (book_id,))

            book = cursor.fetchone()

            if not book:

                flash(
                    "Book not found!",
                    "danger"
                )

                return redirect(url_for("issue_book"))

            # -------------------------
            # CHECK AVAILABILITY
            # -------------------------

            if book["available_quantity"] <= 0:

                flash(
                    "Book is not available!",
                    "danger"
                )

                return redirect(url_for("issue_book"))

            # =================================================
            # CHECK STUDENT
            # =================================================

            cursor.execute("""
                SELECT
                    student_id,
                    name,
                    is_active

                FROM students

                WHERE student_id = %s
            """, (student_id,))

            student = cursor.fetchone()

            if not student:

                flash(
                    "Student not found!",
                    "danger"
                )

                return redirect(url_for("issue_book"))

            # -------------------------
            # CHECK ACTIVE STUDENT
            # -------------------------

            if student["is_active"] != 1:

                flash(
                    "Inactive student cannot issue a book!",
                    "danger"
                )

                return redirect(url_for("issue_book"))

            # =================================================
            # CHECK IF SAME BOOK ALREADY ISSUED
            # =================================================

            cursor.execute("""
                SELECT issue_id

                FROM book_issues

                WHERE student_id = %s
                  AND book_id = %s
                  AND status = 'Issued'
            """, (
                student_id,
                book_id
            ))

            already_issued = cursor.fetchone()

            if already_issued:

                flash(
                    "This student already has this book issued!",
                    "warning"
                )

                return redirect(url_for("issue_book"))

            # =================================================
            # ISSUE DATE / DUE DATE
            # =================================================

            issue_date = date.today()

            # 14 days borrowing period
            due_date = issue_date + timedelta(days=14)

            # =================================================
            # INSERT BOOK ISSUE
            # =================================================

            cursor.execute("""
                INSERT INTO book_issues
                (
                    student_id,
                    book_id,
                    issue_date,
                    due_date,
                    status
                )

                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    'Issued'
                )
            """, (
                student_id,
                book_id,
                issue_date,
                due_date
            ))

            # =================================================
            # DECREASE AVAILABLE QUANTITY
            # =================================================

            cursor.execute("""
                UPDATE books

                SET available_quantity =
                    available_quantity - 1

                WHERE book_id = %s
                  AND available_quantity > 0
            """, (book_id,))

            connection.commit()

            print("===== BOOK ISSUE SUCCESS =====")
            print("Student ID:", student_id)
            print("Book ID:", book_id)
            print("Issue Date:", issue_date)
            print("Due Date:", due_date)

            flash(
                "Book issued successfully!",
                "success"
            )

            return redirect(url_for("issue_book"))

        # =================================================
        # GET - ACTIVE STUDENTS
        # =================================================

        cursor.execute("""
            SELECT
                student_id,
                name,
                roll_no

            FROM students

            WHERE is_active = 1

            ORDER BY name
        """)

        students = cursor.fetchall()
        print("ACTIVE STUDENTS:",students)

        print("STUDENTS:", students)

        # =================================================
        # GET - AVAILABLE BOOKS
        # =================================================

        cursor.execute("""
            SELECT
                book_id,
                title,
                author,
                available_quantity

            FROM books

            WHERE available_quantity > 0

            ORDER BY title
        """)

        books_list = cursor.fetchall()
        print("AVAILABLE BOOKS:",books_list)

        print("BOOKS:", books_list)

       # =================================================
        # CURRENTLY ISSUED BOOKS
        # =================================================

        cursor.execute("""
            SELECT
                bi.issue_id,
                s.name AS student_name,
                s.roll_no,
                b.title AS book_title,
                bi.issue_date,
                bi.due_date,
                bi.status

            FROM book_issues bi

            JOIN students s
                ON bi.student_id = s.student_id

            JOIN books b
                ON bi.book_id = b.book_id

            WHERE bi.status = 'Issued'

            ORDER BY bi.issue_id DESC
        """)

        issued_books = cursor.fetchall()

        return render_template("issue_book.html",students=students,books=books_list,issued_books=issued_books)

    except Exception as e:

        print(
            "ISSUE BOOK ERROR:",
            repr(e)
        )

        if connection:
            connection.rollback()

        flash(
            "Unable to  book! Check terminal.",
            "danger"
        )

        return redirect(url_for("dashboard"))

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

# =========================================================
# RETURN BOOK
# =========================================================

@app.route("/return-book", methods=["GET", "POST"])
def return_book():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        # =================================================
        # POST - RETURN BOOK
        # =================================================

        if request.method == "POST":

            issue_id = request.form.get("issue_id", "").strip()

            if not issue_id:
                flash(
                    "Invalid issue record!",
                    "danger"
                )
                return redirect(url_for("return_book"))

            # =================================================
            # GET ISSUE RECORD
            # =================================================

            cursor.execute("""
                SELECT
                    issue_id,
                    book_id,
                    due_date,
                    status
                FROM book_issues
                WHERE issue_id = %s
                  AND status = 'Issued'
            """, (issue_id,))

            issue = cursor.fetchone()

            if not issue:
                flash(
                    "Book already returned or record not found!",
                    "danger"
                )
                return redirect(url_for("return_book"))

            # =================================================
            # RETURN DATE
            # =================================================

            return_date = date.today()

            # =================================================
            # CALCULATE FINE
            # ₹5 PER LATE DAY
            # =================================================

            fine_amount = 0
            late_days = 0

            if issue["due_date"]:

                if return_date > issue["due_date"]:

                    late_days = (
                        return_date - issue["due_date"]
                    ).days

                    fine_amount = late_days * 5

            # =================================================
            # UPDATE BOOK ISSUE
            # =================================================

            cursor.execute("""
                UPDATE book_issues
                SET
                    status = 'Returned',
                    return_date = %s
                WHERE issue_id = %s
            """, (
                return_date,
                issue_id
            ))

            # =================================================
            # INCREASE AVAILABLE QUANTITY
            # =================================================

            cursor.execute("""
                UPDATE books
                SET available_quantity =
                    available_quantity + 1
                WHERE book_id = %s
            """, (
                issue["book_id"],
            ))

            # =================================================
            # INSERT FINE
            # =================================================

            if fine_amount > 0:

                cursor.execute("""
                    INSERT INTO fines
                    (
                        issue_id,
                        amount,
                        paid_status
                    )
                    VALUES
                    (
                        %s,
                        %s,
                        'Unpaid'
                    )
                """, (
                    issue_id,
                    fine_amount
                ))

            # =================================================
            # COMMIT
            # =================================================

            connection.commit()

            if fine_amount > 0:

                flash(
                    f"Book returned successfully! "
                    f"Late by {late_days} day(s). "
                    f"Fine: ₹{fine_amount}",
                    "warning"
                )

            else:

                flash(
                    "Book returned successfully! No fine.",
                    "success"
                )

            return redirect(url_for("return_book"))

        # =================================================
        # GET - CURRENTLY ISSUED BOOKS
        # =================================================

        cursor.execute("""
            SELECT
                bi.issue_id,
                s.name AS student_name,
                s.roll_no,
                b.title AS book_title,
                bi.issue_date,
                bi.due_date,
                bi.status
            FROM book_issues bi
            JOIN students s
                ON bi.student_id = s.student_id
            JOIN books b
                ON bi.book_id = b.book_id
            WHERE bi.status = 'Issued'
            ORDER BY bi.issue_id DESC
        """)

        issued_books = cursor.fetchall()

        # =================================================
        # GET - RETURNED BOOKS HISTORY
        # =================================================

        cursor.execute("""
            SELECT
                bi.issue_id,
                s.name AS student_name,
                s.roll_no,
                b.title AS book_title,
                bi.issue_date,
                bi.due_date,
                bi.return_date,
                bi.status,
                COALESCE(f.amount, 0) AS fine_amount
            FROM book_issues bi
            JOIN students s
                ON bi.student_id = s.student_id
            JOIN books b
                ON bi.book_id = b.book_id
            LEFT JOIN fines f
                ON bi.issue_id = f.issue_id
            WHERE bi.status = 'Returned'
            ORDER BY bi.issue_id DESC
        """)

        returned_books = cursor.fetchall()

        # =================================================
        # RENDER RETURN BOOK PAGE
        # =================================================

        return render_template(
            "return_book.html",
            issued_books=issued_books,
            returned_books=returned_books
        )

    except Exception as e:

        print(
            "RETURN BOOK ERROR:",
            repr(e)
        )

        if connection:
            connection.rollback()

        flash(
            "Unable to return book! Check terminal.",
            "danger"
        )

        return redirect(url_for("dashboard"))

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()
# =========================================================
# STUDENTS
# =========================================================

@app.route("/students")
def students():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                student_id,
                name,
                roll_no,
                course,
                branch,
                library_id,
                email,
                phone_no

            FROM students

            WHERE is_active = 1

            ORDER BY student_id DESC
        """)

        students_list = cursor.fetchall()

        return render_template(
            "students.html",
            students=students_list
        )

    except Exception as e:

        print(
            "STUDENTS ERROR:",
            repr(e)
        )

        flash(
            "Database error! Check terminal.",
            "danger"
        )

        return redirect(url_for("dashboard"))

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# =========================================================
# ADD STUDENT
# =========================================================

@app.route("/students/add", methods=["POST"])
def add_student():

    if "admin_id" not in session:
        return redirect(url_for("login"))

    name = request.form.get("name", "").strip()
    roll_no = request.form.get("roll_no", "").strip()
    course = request.form.get("course", "").strip()
    branch = request.form.get("branch", "").strip()
    library_id = request.form.get("library_id", "").strip()
    email = request.form.get("email", "").strip()
    phone_no = request.form.get("phone_no", "").strip()

    # =================================================
    # REQUIRED FIELD VALIDATION
    # =================================================

    if not all([
        name,
        roll_no,
        course,
        branch,
        library_id,
        email,
        phone_no
    ]):

        flash(
            "All student fields are required!",
            "danger"
        )

        return redirect(url_for("students"))

    # =================================================
    # EMAIL VALIDATION
    # =================================================

    email_pattern = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"

    if not re.match(email_pattern, email):

        flash(
            "Please enter a valid email address like example@gmail.com",
            "danger"
        )

        return redirect(url_for("students"))

    # =================================================
    # PHONE VALIDATION
    # =================================================

    if not phone_no.isdigit():

        flash(
            "Phone number must contain only digits!",
            "danger"
        )

        return redirect(url_for("students"))

    if len(phone_no) != 10:

        flash(
            "Phone number must be exactly 10 digits!",
            "danger"
        )

        return redirect(url_for("students"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        # =================================================
        # CHECK DUPLICATE ROLL NO
        # =================================================

        cursor.execute("""
            SELECT student_id
            FROM students
            WHERE roll_no = %s
        """, (roll_no,))

        if cursor.fetchone():

            flash(
                "Roll number already exists!",
                "danger"
            )

            return redirect(url_for("students"))

        # =================================================
        # CHECK DUPLICATE LIBRARY ID
        # =================================================

        cursor.execute("""
            SELECT student_id
            FROM students
            WHERE library_id = %s
        """, (library_id,))

        if cursor.fetchone():

            flash(
                "Library ID already exists!",
                "danger"
            )

            return redirect(url_for("students"))

        # =================================================
        # CHECK DUPLICATE EMAIL
        # =================================================

        cursor.execute("""
            SELECT student_id
            FROM students
            WHERE email = %s
        """, (email,))

        if cursor.fetchone():

            flash(
                "Email already exists!",
                "danger"
            )

            return redirect(url_for("students"))

        # =================================================
        # INSERT STUDENT
        # =================================================

        cursor.execute("""
            INSERT INTO students
            (
                name,
                roll_no,
                course,
                branch,
                library_id,
                email,
                phone_no,
                is_active
            )

            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                1
            )
        """, (
            name,
            roll_no,
            course,
            branch,
            library_id,
            email,
            phone_no
        ))

        connection.commit()

        flash(
            "Student added successfully!",
            "success"
        )

    except Exception as e:

        print(
            "ADD STUDENT ERROR:",
            repr(e)
        )

        if connection:
            connection.rollback()

        flash(
            "Unable to add student!",
            "danger"
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

    return redirect(url_for("students"))


# =========================================================
# DELETE STUDENT
# =========================================================

@app.route("/students/delete/<int:student_id>", methods=["POST"])
def delete_student(student_id):

    if "admin_id" not in session:
        return redirect(url_for("login"))

    connection = None
    cursor = None

    try:

        connection = get_db_connection()
        cursor = connection.cursor()

        # -------------------------------------------------
        # SOFT DELETE
        # -------------------------------------------------
        # Student record remains in database,
        # but becomes inactive.

        cursor.execute("""
            UPDATE students

            SET is_active = 0

            WHERE student_id = %s
        """, (student_id,))

        connection.commit()

        flash(
            "Student deleted successfully!",
            "success"
        )

    except Exception as e:

        print(
            "DELETE STUDENT ERROR:",
            repr(e)
        )

        if connection:
            connection.rollback()

        flash(
            "Unable to delete student!",
            "danger"
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

    return redirect(url_for("students"))


# =========================================================
# RUN APPLICATION
# =========================================================

if __name__ == "__main__":

    app.run(debug=True)
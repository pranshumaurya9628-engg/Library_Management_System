
# Library Management System

A Python Flask and MySQL-based Library Management System for managing books, students, book issuing, returns, and fines.

## Features

- Admin login
- Dashboard
- Manage books
- Manage students
- Issue books
- Return books
- Manage fines
- MySQL database integration

## Technologies Used

- Python
- Flask
- MySQL
- HTML
- CSS

## Project Structure

```text
Library Management System/
├── app.py
├── config.py
├── db.py
├── create_admin.py
├── check_tables.py
├── test_db.py
├── requirements.txt
├── .gitignore
├── base.html
└── templates/
    ├── books.html
    ├── dashboard.html
    ├── issue_book.html
    ├── login.html
    ├── manage_fine.html
    ├── return_book.html
    └── students.html
```

## Requirements

- Python 3
- MySQL Server
- pip

## Setup Instructions

1. Clone or download this repository.
2. Open the project folder in VS Code.
3. Create a Python virtual environment:

   ```bash
   python -m venv .venv
   ```

4. Activate it on Windows PowerShell:

   ```powershell
   .\.venv\Scripts\Activate.ps1
   ```

5. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

6. Create the MySQL database and required tables using your project's database setup.
7. Configure database credentials locally. Do not commit passwords or `.env` files.
8. Run the application using the command appropriate to your Flask app, for example:

   ```bash
   python app.py
   ```

9. Open the local URL shown in the terminal.

## Database and Privacy

The MySQL database is stored separately from this repository. Real student records and database backups should not be uploaded to a public repository.

## Author

Pranshu Maurya


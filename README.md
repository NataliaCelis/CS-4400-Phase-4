# ✈️ Airline Management System (CS 4400 Phase 4) ✈️

This is a Flask-based GUI application built for managing an airline database. It allows users to run stored procedures, view flight and personnel data, and simulate real-world airline operations with a user-friendly web interface.

---

## 🔧 Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/your-repo/airline-system.git
cd airline-system
```

### 2. Install dependencies
Make sure you’re using Python 3.8+ and have `pip` installed.
```bash
pip install flask mysql-connector-python
```

### 3. Set up your MySQL database
- Create a MySQL database named `flight_tracking`.
- Import all provided SQL files (tables, views, stored procedures) using:
```bash
mysql -u root -p flight_tracking < schema.sql
```

### 4. Configure database credentials
In `app.py`, update the connection config:
```python
connection = mysql.connector.connect(
    host="localhost",
    user="your_mysql_username",
    password="your_mysql_password",
    database="flight_tracking"
)
```

---

## ▶️ How to Run the App

Run the Flask application using:
```bash
python app.py
```

Once it's running, navigate to:
```
http://localhost:5000
```

Use the homepage to access all stored procedures and views

---

## 💻 Technologies Used

| Tech | Purpose |
|------|---------|
| **Python 3** | Backend logic and control |
| **Flask** | Web framework for the app |
| **MySQL** | Database backend for flights and users |
| **HTML/CSS** | Frontend pages rendered via Flask templates |

---

## Team Contribution Breakdown

| Member | Contributions |
|--------|---------------|
| **Natalia Celis** | Built and tested stored procedures, created Flask routes, handled error validation, UI logic |
| **Rachna Rajesh** | Implemented stored procedures, supported backend integrations |
| **Srihitha Jagarlamudi** | Designed and built views, helped with Flask/HTML integration and templating |
| **Daniel Arias** | Focused on views and data presentation, query optimization, table rendering logic |
| **Everyone** | Participated in debugging, app testing, UI/UX polishing, and integration of components |
from flask import Flask, render_template, request
import mysql.connector

app = Flask(__name__)
app.secret_key = 'secret_key'
app.config["TEMPLATES_AUTO_RELOAD"] = True


connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="INSERT HERE!!!!!!!!",
    database="flight_tracking"
)

# Reusable procedure runner
def run_procedure(proc_name, proc_inputs):
    error = None
    try:
        cursor = connection.cursor()
        cursor.callproc(proc_name, proc_inputs)
        connection.commit()
        cursor.close()
    except Exception as e:
        error = str(e)
    return error

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/add_airplane', methods=['GET', 'POST'])
def add_airplane():
    error_msg = ""
    success_msg = ""

    if request.method == "POST":
        try:
            airlineID = request.form.get("airlineID")
            tail_num = request.form.get("tail_num")
            seat_capacity = int(request.form.get("seat_capacity", 0))
            speed = int(request.form.get("speed", 0))
            locationID = request.form.get("locationID")
            plane_type = request.form.get("plane_type") or None
            maintenanced = 1 if request.form.get("maintenanced") else 0
            model = request.form.get("model") or None
            neo = 1 if request.form.get("neo") else 0

            if not airlineID or not tail_num or seat_capacity <= 0 or speed <= 0 or not locationID:
                error_msg = "Please fill out all required fields properly."
            else:
                result = run_procedure("add_airplane", (
                    airlineID,
                    tail_num,
                    seat_capacity,
                    speed,
                    locationID,
                    plane_type,
                    maintenanced if plane_type == "Boeing" else None,
                    model if plane_type == "Boeing" else None,
                    neo if plane_type == "Airbus" else None
                ))
                if result:
                    error_msg = "Error: " + result
                else:
                    success_msg = f"Airplane {tail_num} added!"
        except Exception as e:
            error_msg = "Form error: " + str(e)

    cursor = connection.cursor()
    cursor.execute("SELECT * FROM airplane")
    airplane_data = cursor.fetchall()
    cursor.execute("SHOW COLUMNS FROM airplane")
    airplane_columns = [col[0] for col in cursor.fetchall()]
    cursor.close()

    return render_template("add_airplane.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           airplane_columns=airplane_columns,
                           airplane_data=airplane_data)

if __name__ == '__main__':
    app.run(debug=True)

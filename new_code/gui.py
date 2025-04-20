from flask import Flask, render_template, request
import mysql.connector

app = Flask(__name__)
app.secret_key = 'secret_key'
app.config["TEMPLATES_AUTO_RELOAD"] = True

try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="PUT PASSWORD HERE",
        database="flight_tracking"
    )
except mysql.connector.Error as err:
    print(f"Error connecting to MySQL: {err}")
    exit(1)

def run_procedure(proc_name, proc_inputs):
    error = None
    try:
        cursor = connection.cursor()
        cursor.callproc(proc_name, proc_inputs)
        connection.commit()
    except Exception as e:
        error = str(e)
    finally:
        cursor.close()
    return error

def fetch_table_data(table_name):
    try:
        cursor = connection.cursor()
        cursor.execute(f"SELECT * FROM {table_name}")
        data = cursor.fetchall()
        cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        columns = [col[0] for col in cursor.fetchall()]
    except Exception as e:
        data = []
        columns = []
        print(f"Error fetching table '{table_name}': {e}")
    finally:
        cursor.close()
    return columns, data


@app.route('/')
def home():
    return render_template('index.html')

# Add Airplane
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
        except ValueError:
            error_msg = "Seat capacity and speed must be valid numbers."
        except Exception as e:
            error_msg = "Unexpected error: " + str(e)

    airplane_columns, airplane_data = fetch_table_data("airplane")

    return render_template("add_airplane.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           airplane_columns=airplane_columns,
                           airplane_data=airplane_data)

@app.route('/add_airport', methods=['GET', 'POST'])
def add_airport():
    error_msg = ""
    success_msg = ""

    if request.method == "POST":
        try:
            airportID = request.form.get("airportID")
            airport_name = request.form.get("airport_name") or None
            city = request.form.get("city")
            state = request.form.get("state")
            country = request.form.get("country")
            locationID = request.form.get("locationID")

            if not airportID or not city or not state or not country or not locationID:
                error_msg = "Please fill out all required fields."
            else:
                result = run_procedure("add_airport", (
                    airportID, airport_name, city, state, country, locationID
                ))
                if result:
                    error_msg = "Error: " + result
                else:
                    success_msg = f"Airport {airportID} added!"
        except Exception as e:
            error_msg = "Unexpected error: " + str(e)

    airport_columns, airport_data = fetch_table_data("airport")

    return render_template("add_airport.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           airport_columns=airport_columns,
                           airport_data=airport_data)


@app.route('/add_person', methods=['GET', 'POST'])
def add_person():
    error_msg = ""
    success_msg = ""

    if request.method == "POST":
        try:
            personID = request.form.get("personID")
            first_name = request.form.get("first_name")
            last_name = request.form.get("last_name") or None
            locationID = request.form.get("locationID")
            taxID = request.form.get("taxID") or None
            experience = request.form.get("experience")
            miles = request.form.get("miles")
            funds = request.form.get("funds")

            experience = int(experience) if experience else None
            miles = int(miles) if miles else None
            funds = int(funds) if funds else None

            if not personID or not first_name or not locationID:
                error_msg = "Please fill out all required base fields."
            elif (taxID and experience is None) or (experience and taxID is None):
                error_msg = "Pilot fields must both be filled or both empty."
            elif (miles is not None and funds is None) or (miles is None and funds is not None):
                error_msg = "Passenger fields must both be filled or both empty."
            else:
                result = run_procedure("add_person", (
                    personID, first_name, last_name, locationID,
                    taxID, experience, miles, funds
                ))

                person_columns, person_data = fetch_table_data("person")

                if result:
                    error_msg = "Error: " + result
                elif not any(p[0] == personID for p in person_data):
                    error_msg = (
                        "Insert failed — you must fill out either the Pilot or Passenger fields (but not both), "
                        "and ensure Location ID exists."
                    )

                else:
                    success_msg = f"Person {personID} added!"

        except ValueError:
            error_msg = "Miles, Funds, and Experience must be valid numbers."
        except Exception as e:
            error_msg = "Unexpected error: " + str(e)

    # ✅ Always refresh after POST (whether success or fail)
    person_columns, person_data = fetch_table_data("person")

    # Also fetch dropdown options again
    cursor = connection.cursor()
    cursor.execute("SELECT LocationID FROM Location")
    valid_locations = [row[0] for row in cursor.fetchall()]
    cursor.close()

    return render_template("add_person.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           person_columns=person_columns,
                           person_data=person_data,
                           valid_locations=valid_locations)


@app.route('/pilot_license', methods=['GET', 'POST'])
def pilot_license():
    error_msg = ""
    success_msg = ""

    if request.method == "POST":
        try:
            personID = request.form.get("personID")
            license = request.form.get("license")

            if not personID or not license:
                error_msg = "Please fill out both fields."
            else:
                result = run_procedure("grant_or_revoke_pilot_license", (personID, license))
                if result:
                    error_msg = "Error: " + result
                else:
                    success_msg = f"License '{license}' toggled for person {personID}."
        except Exception as e:
            error_msg = "Unexpected error: " + str(e)

    license_columns, license_data = fetch_table_data("pilot_licenses")

    return render_template("pilot_license.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           license_columns=license_columns,
                           license_data=license_data)

@app.route('/offer_flight', methods=['GET', 'POST'])
def offer_flight():
    error_msg = ""
    success_msg = ""

    if request.method == "POST":
        try:
            flightID = request.form.get("flightID")
            routeID = request.form.get("routeID")
            support_airline = request.form.get("support_airline") or None
            support_tail = request.form.get("support_tail") or None
            progress = int(request.form.get("progress", 0))
            next_time = request.form.get("next_time")
            cost = int(request.form.get("cost", 0))

            if not flightID or not routeID or not next_time:
                error_msg = "Please fill out all required fields."
            else:
                # Get count before
                _, prev_data = fetch_table_data("flight")
                prev_count = len(prev_data)

                result = run_procedure("offer_flight", (
                    flightID, routeID, support_airline, support_tail, progress, next_time, cost
                ))

                # Re-fetch after insert
                flight_columns, flight_data = fetch_table_data("flight")
                new_count = len(flight_data)

                if result:
                    error_msg = "Error: " + result
                elif new_count == prev_count:
                    error_msg = "No flight was added — check constraints or existing flight ID."
                else:
                    success_msg = f"Flight {flightID} offered!"

        except ValueError:
            error_msg = "Progress and cost must be valid numbers."
            flight_columns, flight_data = fetch_table_data("flight")
        except Exception as e:
            error_msg = "Unexpected error: " + str(e)
            flight_columns, flight_data = fetch_table_data("flight")
    else:
        flight_columns, flight_data = fetch_table_data("flight")

    return render_template("offer_flight.html",
                           error_msg=error_msg,
                           success_msg=success_msg,
                           flight_columns=flight_columns,
                           flight_data=flight_data)



#Flight Landing
@app.route('/flight_landing', methods=['GET', 'POST'])
def flight_landing():
    message = ""
    success = False

    if request.method == "POST":
        flight_id = request.form.get("flightID")
        if not flight_id:
            message = "Please select a flight."
        else:
            result = run_procedure("flight_landing", (flight_id,))
            if result:
                message = "Error: " + result
            else:
                message = f"Flight {flight_id} successfully landed!"
                success = True

    # Re-fetch dropdown AFTER form handling to reflect status updates
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT flightID FROM flight WHERE airplane_status = 'in_flight'")
        flight_ids = [row[0] for row in cursor.fetchall()]
    except Exception as e:
        message = "Error fetching flight IDs: " + str(e)
        flight_ids = []
    finally:
        cursor.close()

    flight_columns, flight_data = fetch_table_data("flight")

    return render_template("flight_landing.html",
                           flight_ids=flight_ids,
                           message=message,
                           success=success,
                           flight_columns=flight_columns,
                           flight_data=flight_data)


# Flight Takeoff
@app.route('/flight_takeoff', methods=['GET', 'POST'])
def flight_takeoff():
    message = ""
    success = False

    if request.method == "POST":
        flight_id = request.form.get("flightID")
        if not flight_id:
            message = "Please select a flight."
        else:
            result = run_procedure("flight_takeoff", (flight_id,))
            if result:
                message = "Error: " + result
            else:
                message = f"Flight {flight_id} successfully took off!"
                success = True

    # Re-fetch list of eligible flights AFTER takeoff logic
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT flightID FROM flight WHERE airplane_status = 'on_ground'")
        flight_ids = [row[0] for row in cursor.fetchall()]
    except Exception as e:
        message = "Error fetching flight IDs: " + str(e)
        flight_ids = []
    finally:
        cursor.close()

    flight_columns, flight_data = fetch_table_data("flight")

    return render_template("flight_takeoff.html",
                           flight_ids=flight_ids,
                           message=message,
                           success=success,
                           flight_columns=flight_columns,
                           flight_data=flight_data)

# Start app
if __name__ == '__main__':
    app.run(debug=True)

from flask import Flask, render_template, request
import mysql.connector

app = Flask(__name__)
app.secret_key = 'secret_key'
app.config["TEMPLATES_AUTO_RELOAD"] = True

try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="add-password-here",
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

#Passengers board
@app.route('/passengers_board', methods=['GET', 'POST'])
def passengers_board():
    message = ""
    success = False
    updated_ids = []
    boarded_person_rows = []
    boarded_passenger_rows = []
    zipped_boarded_rows = []
    zipped_before_after = []

    if request.method == "POST":
        flight_id = request.form.get("flightID")

        if not flight_id:
            message = "Please enter a flight ID."
        else:
            try:
                cursor = connection.cursor()

                # Get flight info
                cursor.execute("SELECT airplane_status, routeID, progress, cost FROM flight WHERE flightID = %s", (flight_id,))
                flight_row = cursor.fetchone()

                if not flight_row:
                    message = f"Flight {flight_id} does not exist."
                elif flight_row[0] != 'on_ground':
                    message = f"Flight {flight_id} is currently '{flight_row[0]}'. Passengers can only board when it's on the ground."
                else:
                    route_id, progress, cost = flight_row[1], flight_row[2], flight_row[3]

                    # Get next leg
                    cursor.execute("""
                        SELECT l.departure, l.arrival
                        FROM route_path rp
                        JOIN leg l ON rp.legID = l.legID
                        WHERE rp.routeID = %s AND rp.sequence = %s
                    """, (route_id, progress + 1))
                    leg = cursor.fetchone()

                    if not leg:
                        message = "No remaining legs in the route. This flight cannot board more passengers."
                    else:
                        departure_airport, arrival_airport = leg
                        cursor.execute("SELECT locationID FROM airport WHERE airportID = %s", (departure_airport,))
                        departure_loc_row = cursor.fetchone()

                        if not departure_loc_row:
                            message = "Departure airport is missing or invalid."
                        else:
                            departure_loc = departure_loc_row[0]

                            # Get seat capacity
                            cursor.execute("""
                                SELECT a.seat_capacity 
                                FROM airplane a
                                JOIN flight f ON a.airlineID = f.support_airline AND a.tail_num = f.support_tail
                                WHERE f.flightID = %s
                            """, (flight_id,))
                            seat_row = cursor.fetchone()

                            if not seat_row:
                                message = "Airplane seat capacity missing."
                            else:
                                seat_capacity = seat_row[0]

                                # Get eligible personIDs
                                cursor.execute("""
                                    SELECT pe.personID
                                    FROM passenger p
                                    JOIN person pe ON p.personID = pe.personID
                                    JOIN (
                                        SELECT pv.personID, MIN(pv.sequence) AS min_sequence 
                                        FROM passenger_vacations pv 
                                        GROUP BY pv.personID
                                    ) pv2 ON p.personID = pv2.personID
                                    JOIN passenger_vacations pv3 ON p.personID = pv3.personID AND pv3.sequence = pv2.min_sequence
                                    WHERE pe.locationID = %s 
                                        AND pv3.airportID = %s 
                                        AND p.funds >= %s
                                """, (departure_loc, arrival_airport, cost))
                                updated_ids = [row[0] for row in cursor.fetchall()]

                                if not updated_ids:
                                    message = "No eligible passengers found (wrong location, destination, or funds)."
                                elif len(updated_ids) > seat_capacity:
                                    message = f"Only {seat_capacity} seats available, but {len(updated_ids)} passengers are eligible."
                                else:
                                    # Fetch BEFORE values
                                    format_strings = ','.join(['%s'] * len(updated_ids))
                                    cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(updated_ids))
                                    before_person_rows = cursor.fetchall()
                                    cursor.execute(f"SELECT * FROM passenger WHERE personID IN ({format_strings})", tuple(updated_ids))
                                    before_passenger_rows = cursor.fetchall()

                                    # Call the procedure
                                    result = run_procedure("passengers_board", (flight_id,))
                                    if result:
                                        message = "Error: " + result
                                    else:
                                        message = f"{len(updated_ids)} passenger(s) boarded flight {flight_id}."
                                        success = True

                                        # Fetch AFTER values
                                        cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(updated_ids))
                                        after_person_rows = cursor.fetchall()
                                        cursor.execute(f"SELECT * FROM passenger WHERE personID IN ({format_strings})", tuple(updated_ids))
                                        after_passenger_rows = cursor.fetchall()

                                        boarded_person_rows = after_person_rows
                                        boarded_passenger_rows = after_passenger_rows
                                        zipped_boarded_rows = list(zip(after_person_rows, after_passenger_rows))
                                        zipped_before_after = list(zip(before_person_rows, after_person_rows, before_passenger_rows, after_passenger_rows))

                cursor.close()

            except Exception as e:
                message = f"Exception: {e}"

    # Full table views
    person_columns, person_data = fetch_table_data("person")
    passenger_columns, passenger_data = fetch_table_data("passenger")

    return render_template("passengers_board.html",
                           message=message,
                           success=success,
                           person_columns=person_columns,
                           person_data=person_data,
                           passenger_columns=passenger_columns,
                           passenger_data=passenger_data,
                           updated_ids=updated_ids,
                           boarded_person_rows=boarded_person_rows,
                           boarded_passenger_rows=boarded_passenger_rows,
                           person_colnames=person_columns,
                           passenger_colnames=passenger_columns,
                           zipped_boarded_rows=zipped_boarded_rows,
                           zipped_before_after=zipped_before_after
                           )

#Passengers disembark
@app.route('/passengers_disembark', methods=['GET', 'POST'])
def passengers_disembark():
    message = ""
    success = False
    updated_ids = []
    before_rows = []
    after_rows = []

    if request.method == "POST":
        flight_id = request.form.get("flightID")

        if not flight_id:
            message = "Please enter a flight ID."
        else:
            try:
                cursor = connection.cursor()

                # Get eligible passengers BEFORE the update
                cursor.execute("""
                    SELECT pv.personID
                    FROM passenger_vacations pv
                    JOIN person p ON pv.personID = p.personID
                    JOIN flight f ON f.flightID = %s
                    JOIN route_path rp ON f.routeID = rp.routeID AND rp.sequence = f.progress
                    JOIN leg l ON rp.legID = l.legID
                    WHERE pv.airportID = l.arrival AND pv.sequence = 1
                      AND p.locationID = (
                          SELECT ap.locationID
                          FROM airplane ap
                          WHERE ap.airlineID = f.support_airline AND ap.tail_num = f.support_tail
                      )
                """, (flight_id,))
                updated_ids = [row[0] for row in cursor.fetchall()]

                if not updated_ids:
                    message = "No eligible passengers to disembark."
                else:
                    # Capture BEFORE state
                    format_strings = ','.join(['%s'] * len(updated_ids))
                    cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(updated_ids))
                    before_rows = cursor.fetchall()

                    # Run the procedure
                    result = run_procedure("passengers_disembark", (flight_id,))
                    if result:
                        message = "Error: " + result
                    else:
                        success = True
                        message = f"{len(updated_ids)} passenger(s) disembarked from flight {flight_id}."

                        # Capture AFTER state
                        cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(updated_ids))
                        after_rows = cursor.fetchall()

                cursor.close()
            except Exception as e:
                message = f"Exception: {e}"

    # Full person & passenger tables
    person_columns, person_data = fetch_table_data("person")
    passenger_columns, passenger_data = fetch_table_data("passenger")
    zipped_rows = list(zip(before_rows, after_rows))

    return render_template("passengers_disembark.html",
                           message=message,
                           success=success,
                           person_columns=person_columns,
                           person_data=person_data,
                           passenger_columns=passenger_columns,
                           passenger_data=passenger_data,
                           updated_ids=updated_ids,
                           zipped_rows=zipped_rows,
                           person_colnames=person_columns)

#Assign Pilot
@app.route('/assign_pilot', methods=['GET', 'POST'])
def assign_pilot():
    message = ""
    success = False
    updated_pilot = None
    updated_person = None

    if request.method == "POST":
        flight_id = request.form.get("ip_flightID")
        person_id = request.form.get("ip_personID")

        if not flight_id or not person_id:
            message = "Please enter both Flight ID and Person ID."
        else:
            try:
                cursor = connection.cursor()

                # Grab BEFORE row (optional but for comparison)
                cursor.execute("SELECT * FROM pilot WHERE personID = %s", (person_id,))
                pilot_before = cursor.fetchone()

                cursor.execute("SELECT * FROM person WHERE personID = %s", (person_id,))
                person_before = cursor.fetchone()

                # Call the stored procedure
                result = run_procedure("assign_pilot", (flight_id, person_id))

                if result:
                    message = "Error: " + result
                else:
                    success = True
                    message = f"Pilot {person_id} successfully assigned to flight {flight_id}."

                    # Fetch updated rows
                    cursor.execute("SELECT * FROM pilot WHERE personID = %s", (person_id,))
                    updated_pilot = cursor.fetchone()

                    cursor.execute("SELECT * FROM person WHERE personID = %s", (person_id,))
                    updated_person = cursor.fetchone()

                cursor.close()
            except Exception as e:
                message = f"Exception: {e}"

    # Fetch full tables
    pilot_columns, pilot_data = fetch_table_data("pilot")
    person_columns, person_data = fetch_table_data("person")

    return render_template("assign_pilot.html",
                           message=message,
                           success=success,
                           updated_pilot=updated_pilot,
                           updated_person=updated_person,
                           pilot_columns=pilot_columns,
                           pilot_data=pilot_data,
                           person_columns=person_columns,
                           person_data=person_data)

#Recycle crew
@app.route('/recycle_crew', methods=['GET', 'POST'])
def recycle_crew():
    message = ""
    success = False
    updated_ids = []
    updated_pilots = []
    updated_people = []

    if request.method == "POST":
        flight_id = request.form.get("ip_flightID")

        if not flight_id:
            message = "Please enter a Flight ID."
        else:
            try:
                cursor = connection.cursor()

                # Who are the pilots currently assigned?
                cursor.execute("SELECT personID FROM pilot WHERE commanding_flight = %s", (flight_id,))
                pilot_ids = [row[0] for row in cursor.fetchall()]

                if not pilot_ids:
                    message = f"No active pilots assigned to {flight_id}, or flight not eligible for recycling."
                else:
                    format_strings = ','.join(['%s'] * len(pilot_ids))

                    # BEFORE state (optional)
                    cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(pilot_ids))
                    before_people = cursor.fetchall()

                    cursor.execute(f"SELECT * FROM pilot WHERE personID IN ({format_strings})", tuple(pilot_ids))
                    before_pilots = cursor.fetchall()

                    # Run procedure
                    result = run_procedure("recycle_crew", (flight_id,))
                    if result:
                        message = "Error: " + result
                    else:
                        success = True
                        message = f"Successfully recycled crew for flight {flight_id}."
                        updated_ids = pilot_ids

                        # Fetch updated data
                        cursor.execute(f"SELECT * FROM person WHERE personID IN ({format_strings})", tuple(pilot_ids))
                        updated_people = cursor.fetchall()

                        cursor.execute(f"SELECT * FROM pilot WHERE personID IN ({format_strings})", tuple(pilot_ids))
                        updated_pilots = cursor.fetchall()

                cursor.close()
            except Exception as e:
                message = f"Exception: {e}"

    pilot_columns, pilot_data = fetch_table_data("pilot")
    person_columns, person_data = fetch_table_data("person")
    zipped_rows = list(zip(updated_people, updated_pilots))

    return render_template("recycle_crew.html",
                           message=message,
                           success=success,
                           zipped_rows=zipped_rows,
                           pilot_columns=pilot_columns,
                           pilot_data=pilot_data,
                           person_columns=person_columns,
                           person_data=person_data,
                           person_colnames=person_columns,
                           pilot_colnames=pilot_columns)

#Retire flight
@app.route('/retire_flight', methods=['GET', 'POST'])
def retire_flight():
    message = ""
    success = False
    removed_flight_id = None

    if request.method == "POST":
        flight_id = request.form.get("flightID", "").strip()

        if not flight_id:
            message = "Please enter a flight ID."
        else:
            try:
                cursor = connection.cursor()

                # Check if the flight exists
                cursor.execute("SELECT COUNT(*) FROM flight WHERE flightID = %s", (flight_id,))
                exists = cursor.fetchone()[0]

                if exists == 0:
                    message = f"Flight '{flight_id}' does not exist."
                else:
                    # Run the procedure
                    result = run_procedure("retire_flight", (flight_id,))

                    # Check if the flight was actually removed
                    cursor.execute("SELECT COUNT(*) FROM flight WHERE flightID = %s", (flight_id,))
                    still_exists = cursor.fetchone()[0]

                    if still_exists == 0:
                        message = f"Flight '{flight_id}' successfully retired."
                        success = True
                        removed_flight_id = flight_id
                    else:
                        message = f"Flight '{flight_id}' was not retired. It may not meet all the constraints."

                cursor.close()

            except Exception as e:
                message = f"Error: {e}"

    # Display updated flight table
    flight_columns, flight_data = fetch_table_data("flight")

    return render_template("retire_flight.html",
                           message=message,
                           success=success,
                           flight_columns=flight_columns,
                           flight_data=flight_data,
                           removed_flight_id=removed_flight_id)


#simulation cycle
@app.route('/simulation_cycle', methods=['GET', 'POST'])
def simulation_cycle():
    message = ""
    success = False

    if request.method == "POST":
        try:
            result = run_procedure("simulation_cycle", ())
            if result:
                message = "Error: " + result
            else:
                success = True
                message = "Simulation cycle successfully executed."
        except Exception as e:
            message = f"Exception occurred: {e}"

    # Refresh relevant tables
    flight_columns, flight_data = fetch_table_data("flight")
    person_columns, person_data = fetch_table_data("person")
    passenger_columns, passenger_data = fetch_table_data("passenger")
    pilot_columns, pilot_data = fetch_table_data("pilot")
    airplane_columns, airplane_data = fetch_table_data("airplane")

    return render_template("simulation_cycle.html",
                           message=message,
                           success=success,
                           flight_columns=flight_columns,
                           flight_data=flight_data,
                           person_columns=person_columns,
                           person_data=person_data,
                           passenger_columns=passenger_columns,
                           passenger_data=passenger_data,
                           pilot_columns=pilot_columns,
                           pilot_data=pilot_data,
                           airplane_columns=airplane_columns,
                           airplane_data=airplane_data)

# Start app
if __name__ == '__main__':
    app.run(debug=True)

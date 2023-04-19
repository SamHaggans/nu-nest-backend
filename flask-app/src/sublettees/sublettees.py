from flask import Blueprint, request, jsonify, make_response
import json
from src import db

# Those looking for housing
sublettees = Blueprint('sublettees', __name__)

# Get all available sublet listings from the DB
@sublettees.route('/sublet_listings', methods=['GET'])
def get_sublet_listings():
    cursor = db.get_db().cursor()
    cursor.execute('select listing_id, availability, bathroom_count, city, start_date, end_date, furnished_status, post_time, rent, roommate_count, zipcode, bedroom_count from Sublet_Listing \
        WHERE availability = 1')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get all housing account users of the program
@sublettees.route('/housing_account', methods=['GET'])
def get_accounts():
    cursor = db.get_db().cursor()
    cursor.execute('select first_name, last_name, housing_account_id \
        FROM Users where housing_account_id is not null')
    row_headers = ["label", "value"]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, [f'{row[0]} {row[1]}', row[2]])))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get housing account details for a housing account with particular ID
@sublettees.route('/housing_account/<id>', methods=['GET'])
def get_housing_account(id):
    cursor = db.get_db().cursor()
    cursor.execute('select * \
                    from (Users as U join Housing_Account as H on U.housing_account_id = H.housing_account_id)\
                    where H.housing_account_id = {0}'.format(id)+';')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Update a particular housing account user
@sublettees.route('/housing_account/edit/<id>', methods=['PUT'])
def put_housing_account(id):
    req_data = request.get_json()
    new_birthdate = req_data['birthdate']
    new_gender = req_data["gender"]
    new_first_name = req_data['first_name']
    new_last_name = req_data['last_name']
    new_email_address = req_data['email_address']
    cursor = db.get_db().cursor()
    cursor.execute(f'UPDATE Users\
                    SET birthdate = "{new_birthdate}",\
                        gender = "{new_gender}",\
                        first_name = "{new_first_name}",\
                        last_name = "{new_last_name}",\
                        email_address = "{new_email_address}"\
                    WHERE housing_account_id = {id}')
    db.get_db().commit()
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get sublet listing detail for a specific listing from an ID
@sublettees.route('/sublet_listing/<id>', methods=['GET'])
def get_sublet_listing(id):
    cursor = db.get_db().cursor()
    cursor.execute('select * from Sublet_Listing where listing_id = {0}'.format(id))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post sublet offer on specific listing
@sublettees.route('/sublet_listing/<id>/offer', methods=['POST'])
def post_offer(id):
    req_data = request.get_json()
    new_start_date = req_data['start_date']
    new_end_date = req_data['end_date']
    new_rent = req_data['rent']
    new_offering_user = req_data['offering_user']
    cursor = db.get_db().cursor()
    cursor.execute(f'INSERT INTO Sublet_Offer (start_date, end_date, rent, status, offering_user, listing_id)\
                   VALUES ("{new_start_date.split("T")[0]}", "{new_end_date.split("T")[0]}", \
                    {new_rent}, 0, "{int(new_offering_user)}", {id})')      
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Delete specific offer on sublet listing with specific id
@sublettees.route('/sublet_listing/offer/<offerid>', methods=['DELETE'])
def delete_offer(offerid):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM Sublet_Offer WHERE offer_id={0}'.format(offerid))
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Edit a specific offer on specific listing
@sublettees.route('/sublet_listing/offer/edit/<offerid>', methods=['PUT'])
def put_offer(offerid):
    req_data = request.get_json()
    new_start_date = req_data['start_date']
    new_end_date = req_data['end_date']
    new_rent = req_data['rent']
    cursor = db.get_db().cursor()
    cursor.execute('UPDATE Sublet_Offer \
                   SET start_date =  {0}'.format(new_start_date)+',\
                        end_date = {0}'.format(new_end_date)+',\
                        rent = {0}'.format(new_rent)+'\
                    WHERE offering_user = {0}'.format(offerid)+';')  
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response
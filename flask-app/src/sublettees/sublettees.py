from flask import Blueprint, request, jsonify, make_response
import json
from src import db

# Those looking for housing
sublettees = Blueprint('sublettees', __name__)

# Get all sublet listings from the DB
@sublettees.route('/sublet_listings', methods=['GET'])
def get_sublet_listings():
    cursor = db.get_db().cursor()
    cursor.execute('select listing_id, availability, bathroom_count, city, start_date, end_date, furnished_status, post_time, rent, roommate_count, zipcode from Sublet_Listing \
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

# Get all users of the program
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

# Get housing account detail for a housing account with particular ID
@sublettees.route('/housing_account/<id>', methods=['GET'])
def get_housing_account(id):
    cursor = db.get_db().cursor()
    cursor.execute('select * from Housing_Account where housing_account_id = {0}'.format(id))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Update a housing account 
# how do you do this lol???
@sublettees.route('/housing_account/<id>', methods=['PUT'])
def put_housing_account(id):
    new_student_status = request.json['student_status']
    new_group_id = request.json['group_id']
    cursor = db.get_db().cursor()
    cursor.execute('UPDATE Housing_Account\
                    SET student_status =  {0}'.format(new_student_status)+'\
                        group_id = {0}'.format(new_group_id)+'\
                    WHERE housing_account_id = {0}'.format(id))
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

# Post message
@sublettees.route('/message', methods=['POST'])
def post_message():
    new_subject = request.json['subject']
    new_contents = request.json['contents']
    new_sender = request.json['sender']
    new_receiver = request.json['receiver']
    cursor = db.get_db().cursor()
    cursor.execute('INSERT INTO Message(subject, contents, sender, receiver)\
                   VALUES ({0}'.format(new_subject)+', {0}'.format(new_contents)+', {0}'.format(new_sender)+', {0}'.format(new_receiver)+'')      
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post messages to specific user 
@sublettees.route('/message/<id>', methods=['POST'])
def post_user_message(id):
    new_subject = request.json['subject']
    new_contents = request.json['contents']
    new_sender = request.json['sender']
    cursor = db.get_db().cursor()
    cursor.execute('INSERT INTO Message(subject, contents, sender, receiver)\
                   VALUES ({0}'.format(new_subject)+', {0}'.format(new_contents)+', {0}'.format(new_sender)+', {0}'.format(id)+'')      
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post sublet offer on specific listing
@sublettees.route('/sublet_listing/<id>/offer', methods=['POST'])
def post_offer(id):
    new_start_date = request.json['start_date']
    new_end_date = request.json['end_date']
    new_rent = request.json['rent']
    new_offering_user = request.json['offering_user']
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
@sublettees.route('/sublet_listing/<id>/offer/<offerid>', methods=['DELETE'])
def delete_offer(id, offerid):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM Sublet_Offer WHERE listing_id= {0}'.format(id)+' AND offer_id= {0}'.format(offerid)+'')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Delete specific message from specific user
@sublettees.route('/message/<userid>/<messageid>', methods=['DELETE'])
def delete_user_message(userid, messageid):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM Message WHERE sender= {0}'.format(userid)+' AND message_id= {0}'.format(messageid)+'')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response
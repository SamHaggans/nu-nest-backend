from flask import Blueprint, request, jsonify, make_response
import json
from src import db


subletters = Blueprint('subletters', __name__)

# Post a sublet listing
@subletters.route('/sublet_listing', methods=['POST'])
def post_sublet_listing():
    new_availability = request.json['availability']
    new_roommate_count = request.json['roommate_count']
    new_bathroom_count = request.json['bathroom_count']
    new_bedroom_count = request.json['bedroom_count']
    new_start_date = request.json['start_date']
    new_end_date = request.json['end_date']
    new_furnished_status = request.json['furnished_status']
    new_description = request.json['description']
    new_rent = request.json['rent']
    new_zipcode = request.json['zipcode']
    new_street = request.json['street']
    new_city = request.json['city']
    new_subletter = request.json['subletter']
    cursor = db.get_bd().cursor()
    cursor.execute('INSERT INTO Sublet_Listing(availability, roommate_count, bedroom_count, bathroom_count, \
                   start_date, end_date, furnished_status, description, rent, zipcode, street, city, subletter)\
                   VALUES ({0}'.format(new_availability)+', {0}'.format(new_roommate_count)+',\
                     {0}'.format(new_bathroom_count)+', {0}'.format(new_bedroom_count)+', \
                     {0}'.format(new_start_date)+', {0}'.format(new_end_date)+', \
                     {0}'.format(new_furnished_status)+', {0}'.format(new_description)+', \
                     {0}'.format(new_rent)+', {0}'.format(new_zipcode)+', \
                     {0}'.format(new_street)+', {0}'.format(new_city)+', {0}'.format(new_subletter)+')')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Edit a specific sublet listing 
@subletters.route('/sublet_listing/<id>', methods=['PUT'])
def put_sublet_listing():
    new_availability = request.json['availability']
    new_roommate_count = request.json['roommate_count']
    new_bathroom_count = request.json['bathroom_count']
    new_bedroom_count = request.json['bedroom_count']
    new_start_date = request.json['start_date']
    new_end_date = request.json['end_date']
    new_furnished_status = request.json['furnished_status']
    new_description = request.json['description']
    new_rent = request.json['rent']
    new_zipcode = request.json['zipcode']
    new_street = request.json['street']
    new_city = request.json['city']
    new_subletter = request.json['subletter']
    cursor = db.get_bd().cursor()
    cursor.execute('UPDATE Sublet_Listing \
                    SET availability = {0}'.format(new_availability)+', \
                        roommate_count = {0}'.format(new_roommate_count)+',\
                        bathroom_count = {0}'.format(new_bathroom_count)+',\
                        bedroom_count = {0}'.format(new_bedroom_count)+',\
                        start_date = {0}'.format(new_start_date)+',\
                        end_date = {0}'.format(new_end_date)+',\
                        furnished_status = {0}'.format(new_furnished_status)+',\
                        description = {0}'.format(new_description)+',\
                        rent = {0}'.format(new_rent)+',\
                        zipcode = {0}'.format(new_zipcode)+', \
                        street = {0}'.format(new_street)+',\
                        city = {0}'.format(new_city)+', \
                        subletter = {0}'.format(new_subletter)+'\
                    WHERE listing_id = {0}'.format(id)+'')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Delete specific sublet listing
@subletters.route('/sublet_listing/<id>', methods=['DELETE'])
def delete_offer(id, offerid):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM Sublet_Listing WHERE listing_id= {0}'.format(id)+';')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post a new user report on a specific user
@subletters.route('/user/<id>/report', methods=['POST'])
def post_user_report():
    new_issue = request.json['issue']
    new_resolved = request.json['resolved']
    new_comment = request.json['comment']
    new_reporter = request.json['reporter']
    cursor = db.get_bd().cursor()
    cursor.execute('INSERT INTO User_Report(issue, resolved, comment, reporter, reported_user)\
                   VALUES ({0}'.format(new_issue)+', {0}'.format(new_resolved)+',\
                     {0}'.format(new_comment)+', {0}'.format(new_reporter)+', \
                     {0}'.format(id)+')')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# delete a specific user report
@subletters.route('/report/<id>', methods=['DELETE'])
def delete_report(id):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM User_Report WHERE report_id= {0}'.format(id)+';')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post a new user rating on a specific user 
@subletters.route('/user/<id>/rating', methods=['POST'])
def post_user_rating():
    new_value = request.json['value']
    new_description = request.json['description']
    new_rater = request.json['rater']
    cursor = db.get_bd().cursor()
    cursor.execute('INSERT INTO Rating(value, description, rater, rated_user)\
                   VALUES ({0}'.format(new_value)+', {0}'.format(new_description)+',\
                     {0}'.format(new_rater)+', {0}'.format(id)+')')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get all offers for a specific sublet 
@subletters.route('/sublet_listing/<id>/offers', methods=['GET'])
def get_offers(id):    
    cursor = db.get_db().cursor()
    cursor.execute(f'select * from Sublet_Offer where listing_id = {id}')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get information on a specfic offer 
@subletters.route('/sublet_listing/<id>/offers/<offerid>', methods=['GET'])
def get_specific_offer(id, offerid):    
    cursor = db.get_db().cursor()
    cursor.execute(f'select * from Sublet_Offer where listing_id = {id} AND offer_id = {offerid}')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response


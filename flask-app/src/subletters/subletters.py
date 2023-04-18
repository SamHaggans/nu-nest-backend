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

# Delete specific sublet listing
@subletters.route('/sublet_listing/<id>', methods=['DELETE'])
def delete_offer(id, offerid):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM Sublet_Offer WHERE listing_id= {0}'.format(id)+';')
    db.get_db().commit()      
    the_response = make_response()
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Post a new user report on a specific user
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

# Post a new user rating on a specific user 

# Edit sublet listing offer 

# Get all offers on a sublet listing

# Get informations on a specfic offer 


# Get all the products from the database
@subletters.route('/subletters', methods=['GET'])
def get_products():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of products
    cursor.execute('SELECT id, product_code, product_name, list_price FROM products')

    # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in 
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers. 
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# get the top 5 products from the database
@subletters.route('/mostExpensive')
def get_most_pop_products():
    cursor = db.get_db().cursor()
    query = '''
        SELECT product_code, product_name, list_price, reorder_level
        FROM products
        ORDER BY list_price DESC
        LIMIT 5
    '''
    cursor.execute(query)
       # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in 
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers. 
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)
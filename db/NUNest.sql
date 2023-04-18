-- Project Phase 3

-- Create database
DROP DATABASE IF EXISTS NU_Nest;
CREATE DATABASE IF NOT EXISTS NU_Nest;

-- Grant Privileges
grant all privileges on NU_Nest.* to 'webapp'@'%';
flush privileges;

-- Use database
USE NU_Nest;

-- Create Moderator Account
CREATE TABLE Moderator_Account
(
    weekly_hours int NOT NULL,
    moderator_id INTEGER PRIMARY KEY Auto_Increment 
);

-- Create Housing Group
CREATE TABLE Housing_Group
(
    group_name varchar(50) UNIQUE NOT NULL,
    group_id   INTEGER PRIMARY KEY Auto_Increment 
);

-- Create Housing Account
CREATE TABLE Housing_Account
(
    student_status     boolean NOT NULL,
    housing_account_id INTEGER PRIMARY KEY Auto_Increment,
    group_id           int,
    CONSTRAINT fk_1
        FOREIGN KEY (group_id) REFERENCES Housing_Group (group_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create users
CREATE TABLE Users
(
    birthdate            date                NOT NULL,
    gender               varchar(50),
    first_name           varchar(50)         NOT NULL,
    last_name            varchar(50)         NOT NULL,
    email_address        varchar(100) UNIQUE NOT NULL, -- unique to user and must exist
    user_id              INTEGER PRIMARY KEY Auto_Increment,              -- primary key
    housing_account_id   int,
    moderator_account_id int,
    CONSTRAINT fk_2
        FOREIGN KEY (housing_account_id) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_3
        FOREIGN KEY (moderator_account_id) REFERENCES Moderator_Account (moderator_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Rating (dependent)
CREATE TABLE Rating
(
    value       int NOT NULL,
    description varchar(500),
    rater       int,
    rated_user  int,
    PRIMARY KEY (rater, rated_user),
    CONSTRAINT fk_4
        FOREIGN KEY (rater) REFERENCES Users (user_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_5
        FOREIGN KEY (rated_user) REFERENCES Users (user_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Login (dependent)
CREATE TABLE Login
(
    password varchar(50) NOT NULL,
    user_id  int,
    username varchar(50),
    PRIMARY KEY (user_id, username),
    CONSTRAINT fk_6
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Roommate Preference (dependent)
CREATE TABLE Roommate_Preference
(
    importance      int NOT NULL,
    description     varchar(200),
    preference_name varchar(50),
    user            int,
    PRIMARY KEY (user, preference_name),
    CONSTRAINT fk_7
        FOREIGN KEY (user) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create User Report
CREATE TABLE User_Report
(
    issue         varchar(200) NOT NULL,
    resolved      boolean      NOT NULL,
    comment       varchar(500),
    report_id     INTEGER PRIMARY KEY Auto_Increment,
    reporter      int,
    reported_user int,
    CONSTRAINT fk_8
        FOREIGN KEY (reported_user) REFERENCES Users (user_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_9
        FOREIGN KEY (reporter) REFERENCES Users (user_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Message
CREATE TABLE Message
(
    timestamp  datetime DEFAULT CURRENT_TIMESTAMP,
    subject    varchar(50),
    contents   varchar(500) NOT NULL,
    message_id INTEGER PRIMARY KEY Auto_Increment,
    sender     int,
    receiver   int,
    CONSTRAINT fk_10
        FOREIGN KEY (sender) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_11
        FOREIGN KEY (receiver) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Sublet_Listing
CREATE TABLE Sublet_Listing
(
    post_time        datetime DEFAULT CURRENT_TIMESTAMP,
    availability     boolean     NOT NULL,
    roommate_count   int,
    bedroom_count    int,
    bathroom_count   int,
    start_date       date        NOT NULL,
    end_date         date        NOT NULL,
    furnished_status boolean,
    description      varchar(500),
    rent             double      NOT NULL,
    zipcode          int,
    street           varchar(50),
    city             varchar(50) NOT NULL,
    subletter        int,
    listing_id       INTEGER PRIMARY KEY Auto_Increment,
    CONSTRAINT fk_14
        FOREIGN KEY (subletter) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Sublet Offer
CREATE TABLE Sublet_Offer
(
    start_date    date    NOT NULL,
    end_date      date    NOT NULL,
    rent          double  NOT NULL,
    time_sent     datetime DEFAULT CURRENT_TIMESTAMP,
    status        boolean NOT NULL,
    offer_id      INTEGER PRIMARY KEY Auto_Increment,
    offering_user int,
    listing_id    int,
    CONSTRAINT fk_12
        FOREIGN KEY (offering_user) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_13
        FOREIGN KEY (listing_id) REFERENCES Sublet_Listing (listing_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Create Comment (dependent)
CREATE TABLE Comment
(
    timestamp          datetime DEFAULT CURRENT_TIMESTAMP,
    text               varchar(500),
    comment_id         INTEGER Auto_Increment,
    reply_id           int,
    listing_id         int,
    housing_account_id int,
    PRIMARY KEY (comment_id, listing_id, housing_account_id),
    CONSTRAINT fk_15
        FOREIGN KEY (housing_account_id) REFERENCES Housing_Account (housing_account_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_16
        FOREIGN KEY (listing_id) REFERENCES Sublet_Listing (listing_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_17
        FOREIGN KEY (reply_id) REFERENCES Comment (comment_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Bridge between Moderator Account and User Report
CREATE TABLE Moderator_Review
(
    action       varchar(500) NOT NULL,
    moderator_id int,
    report_id    int,
    PRIMARY KEY (moderator_id, report_id),
    CONSTRAINT fk_18
        FOREIGN KEY (moderator_id) REFERENCES Moderator_Account (moderator_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_19
        FOREIGN KEY (report_id) REFERENCES User_Report (report_id)
            ON UPDATE cascade ON DELETE cascade

);

-- Bridge between Moderator Account and Sublet Listing
CREATE TABLE Moderator_Edit
(
    change_description varchar(500) NOT NULL,
    timestamp          datetime DEFAULT CURRENT_TIMESTAMP,
    moderator_id       int,
    listing_id         int,
    PRIMARY KEY (moderator_id, listing_id),
    CONSTRAINT fk_20
        FOREIGN KEY (moderator_id) REFERENCES Moderator_Account (moderator_id)
            ON UPDATE cascade ON DELETE cascade,
    CONSTRAINT fk_21
        FOREIGN KEY (listing_id) REFERENCES Sublet_Listing (listing_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Images (multivalued)
CREATE TABLE Images
(
    image_file_name varchar(50),
    listing_id      int,
    PRIMARY KEY (listing_id, image_file_name),
    CONSTRAINT fk_22
        FOREIGN KEY (listing_id) REFERENCES Sublet_Listing (listing_id)
            ON UPDATE cascade ON DELETE cascade
);

-- Sample Data

-- Moderator Account Samples
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (1,8.8);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (2,19.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (3,34.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (4,3.6);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (5,35.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (6,23.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (7,2.5);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (8,39.5);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (9,32.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (10,32.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (11,6.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (12,15.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (13,3.8);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (14,39.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (15,37.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (16,6.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (17,38.1);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (18,37.9);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (19,18.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (20,3.0);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (21,10.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (22,7.9);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (23,21.5);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (24,25.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (25,15.0);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (26,1.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (27,21.0);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (28,19.6);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (29,4.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (30,14.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (31,23.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (32,15.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (33,24.6);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (34,16.8);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (35,14.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (36,3.8);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (37,20.4);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (38,8.9);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (39,4.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (40,8.5);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (41,16.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (42,26.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (43,9.7);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (44,6.2);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (45,16.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (46,27.5);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (47,12.1);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (48,10.3);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (49,27.8);
INSERT INTO Moderator_Account(moderator_id,weekly_hours) VALUES (50,3.5);

-- Housing Group Samples
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Schaden, Auer and Bernier',1);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Koss Inc',2);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Grant, Hauck and Veum',3);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Hahn, Lind and Morar',4);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Shields, Schoen and Heathcote',5);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Barton, Hilll and Shields',6);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Dickinson, Hoppe and Fay',7);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Rohan-Auer',8);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Stanton, Walter and Hickle',9);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Renner-Little',10);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Hoppe, Osinski and Ebert',11);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Beahan-Rosenbaum',12);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Bosco, Gutkowski and Upton',13);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Turcotte-West',14);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Keebler, Tillman and Goldner',15);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Padberg LLC',16);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Feest Inc',17);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('O''Conner, Kuphal and Lindgren',18);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('McLaughlin-Ratke',19);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Bartell and Sons',20);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Satterfield and Sons',21);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Casper Inc',22);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Muller-Schulist',23);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('McDermott-Weissnat',24);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Hermiston-Harvey',25);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Quigley, Herman and Von',26);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Trantow and Sons',27);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Abbott-Sawayn',28);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Stokes LLC',29);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Osinski-Emard',30);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Blanda-Skiles',31);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Romaguera, Stanton and Pfeffer',32);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Witting, Hane and Kirlin',33);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Collins-Bauch',34);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Altenwerth, Corkery and Wuckert',35);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Kuhn Group',36);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('O''Conner-Hilpert',37);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Barrows, Jakubowski and Fritsch',38);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Schaden-Metz',39);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Heaney-Stracke',40);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Toy-Stark',41);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Harvey, Labadie and Trantow',42);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Aufderhar-Green',43);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Walker, Jacobs and Huels',44);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Brekke, Brown and Moen',45);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Rolfson-Heidenreich',46);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Abshire, Tromp and McKenzie',47);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Beatty Group',48);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Gottlieb Inc',49);
INSERT INTO Housing_Group(group_name,group_id) VALUES ('Mitchell-Bradtke',50);

-- Housing Account Samples
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,1,34);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,2,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,3,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,4,18);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,5,25);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,6,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,7,20);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,8,40);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,9,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,10,22);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,11,42);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,12,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,13,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,14,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,15,44);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,16,44);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,17,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,18,28);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,19,48);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,20,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,21,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,22,12);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,23,47);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,24,48);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,25,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,26,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,27,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,28,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,29,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,30,44);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,31,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,32,38);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,33,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,34,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,35,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,36,17);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,37,15);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,38,27);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,39,43);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,40,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,41,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,42,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,43,47);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,44,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,45,1);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,46,30);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,47,NULL);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,48,47);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (true,49,36);
INSERT INTO Housing_Account(student_status,housing_account_id,group_id) VALUES (false,50,NULL);

-- Users Samples
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-04-12 00:59:15','Male','Padriac','Kleinstern','pkleinstern0@hao123.com',1,1,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-08-12 09:04:51','Male','Ad','O''Dougherty','aodougherty1@jiathis.com',2,2,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-09-23 23:31:32','Female','Clary','Longmuir','clongmuir2@ustream.tv',3,3,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-10-11 07:04:30','Female','Pammi','Pedycan','ppedycan3@ustream.tv',4,4,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-01-30 12:02:04','Female','Bryna','Haswell','bhaswell4@google.cn',5,5,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2002-10-30 11:32:20','Male','Chauncey','Labitt','clabitt5@seattletimes.com',6,6,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-07-11 16:47:52','Male','Alain','Else','aelse6@cocolog-nifty.com',7,7,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-03-09 09:52:27','Male','Westbrook','Happer','whapper7@go.com',8,8,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-04-21 10:39:12','Female','Monique','Heibl','mheibl8@cnet.com',9,9,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-01-11 19:32:12','Male','Jessie','Meehan','jmeehan9@amazonaws.com',10,10,10);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1999-12-23 05:35:04','Male','Brennan','Birchner','bbirchnera@sitemeter.com',11,11,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-01-15 01:19:05','Female','Bethany','Langton','blangtonb@addthis.com',12,12,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2002-12-23 00:37:07','Female','Ivie','Sim','isimc@homestead.com',13,13,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-02-17 02:50:20','Female','Romonda','Huthart','rhuthartd@hostgator.com',14,14,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-04-17 23:30:30','Female','Eryn','Andrew','eandrewe@webmd.com',15,15,15);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-07-24 19:05:42','Female','Uta','Bradder','ubradderf@nsw.gov.au',16,16,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2000-09-14 09:10:04','Female','Jacintha','Ribou','jriboug@usatoday.com',17,17,17);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1997-05-30 04:18:45','Male','Donavon','Bedell','dbedellh@plala.or.jp',18,18,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2004-10-04 00:42:36','Female','Misha','Keaysell','mkeayselli@opera.com',19,19,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-06-01 03:12:36','Male','Mohandis','McClaughlin','mmcclaughlinj@nba.com',20,20,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2004-12-19 08:10:07','Female','Valery','Copnar','vcopnark@wufoo.com',21,21,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-11-06 21:00:56','Male','Sayre','Johnys','sjohnysl@hatena.ne.jp',22,22,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-12-24 14:22:09','Female','Jorrie','Iston','jistonm@php.net',23,23,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-04-16 17:34:28','Female','Margit','Palfrey','mpalfreyn@webmd.com',24,24,24);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-05-17 07:23:58','Female','Aigneis','Senussi','asenussio@skype.com',25,25,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2000-12-22 08:09:43','Female','Deborah','Telezhkin','dtelezhkinp@nyu.edu',26,26,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1998-05-25 00:32:46','Male','Normand','Sankey','nsankeyq@ning.com',27,27,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-11-23 00:17:06','Male','Derk','Reitenbach','dreitenbachr@cisco.com',28,28,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-05-20 06:19:41','Male','Emelen','Ellwood','eellwoods@google.fr',29,29,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2002-03-03 02:00:45','Female','Meg','Skains','mskainst@lycos.com',30,30,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-06-24 17:34:58','Male','Brook','Gurdon','bgurdonu@tumblr.com',31,31,31);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1997-12-15 07:55:51','Female','Edythe','Penberthy','epenberthyv@globo.com',32,32,32);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-02-04 10:22:05','Agender','Ofelia','Paxforde','opaxfordew@google.pl',33,33,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-07-08 14:51:32','Male','Trever','Juza','tjuzax@nytimes.com',34,34,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-01-26 16:43:15','Male','Nevin','Filipczak','nfilipczaky@howstuffworks.com',35,35,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2000-12-10 10:53:52','Female','Betsy','Nisius','bnisiusz@blog.com',36,36,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1999-12-10 13:41:52','Bigender','Herrick','Fippe','hfippe10@msu.edu',37,37,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1998-07-24 13:50:49','Male','Fleming','Seeks','fseeks11@sciencedaily.com',38,38,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-03-16 21:28:06','Male','Hervey','Garci','hgarci12@examiner.com',39,39,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2003-01-18 14:23:16','Female','Daveen','Newis','dnewis13@ning.com',40,40,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2004-01-25 04:18:09','Female','Nichol','Brandes','nbrandes14@bloglines.com',41,41,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2002-12-31 21:45:42','Male','Alvy','Marval','amarval15@joomla.org',42,42,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-09-20 17:27:52','Female','Maye','Vallantine','mvallantine16@japanpost.jp',43,43,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-12-17 23:29:06','Male','Skipp','Glenton','sglenton17@moonfruit.com',44,44,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1998-09-09 13:47:38','Male','Gordon','Peat','gpeat18@dion.ne.jp',45,45,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1995-11-20 15:41:09','Male','Enoch','Horick','ehorick19@naver.com',46,46,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1998-02-18 10:33:14','Female','Domeniga','McKague','dmckague1a@dmoz.org',47,47,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1997-07-22 17:48:32','Male','Delmer','Smalecombe','dsmalecombe1b@51.la',48,48,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('1996-01-30 10:16:43','Male','Evin','Tregonna','etregonna1c@forbes.com',49,49,NULL);
INSERT INTO Users(birthdate,gender,first_name,last_name,email_address,user_id,housing_account_id,moderator_account_id) VALUES ('2001-02-01 18:16:23','Male','Eldridge','Gregg','egregg1d@gizmodo.com',50,50,50);

-- Rating Samples
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut',3,1);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum',6,38);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (2,'faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis',43,29);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (1,'neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris',27,39);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (6,'blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et',15,9);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus',28,33);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede',8,33);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus',9,18);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (8,'rutrum ac lobortis vel dapibus at diam nam tristique tortor',33,9);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (6,'justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate',49,28);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices',21,8);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'morbi non lectus aliquam sit amet diam in magna bibendum imperdiet',26,2);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia',29,19);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'ut blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere',39,38);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (8,'turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci',33,43);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (7,'mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor',13,36);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum',35,18);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (8,'et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit',49,7);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (8,'massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id',47,33);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (2,'viverra diam vitae quam suspendisse potenti nullam porttitor lacus at',40,26);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor',42,12);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem',10,6);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (6,'elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur',50,15);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse',36,35);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum',11,45);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu',46,20);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis',13,21);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (8,'curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec',24,25);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc',35,40);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo maecenas',19,32);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque',20,41);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (1,'in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis',5,9);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi',7,38);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio',23,47);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (6,'etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras',3,18);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam',29,37);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (1,'nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet',45,6);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean',31,47);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'et magnis dis parturient montes nascetur ridiculus mus etiam vel',7,46);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (9,'viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec',42,42);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (1,'primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus',46,39);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus',31,18);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (2,'eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc',46,40);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo',26,49);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec',34,33);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (10,'curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros',37,22);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (6,'donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit',17,27);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (7,'mi in porttitor pede justo eu massa donec dapibus duis at',11,26);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (4,'felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus',4,4);
INSERT INTO Rating(value,description,rater,rated_user) VALUES (3,'leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel',25,11);

-- Login Samples
INSERT INTO Login(password,user_id,username) VALUES ('fs9Wib',1,'dellsom0');
INSERT INTO Login(password,user_id,username) VALUES ('k7GFlC3vxWSN',2,'cjoselovitch1');
INSERT INTO Login(password,user_id,username) VALUES ('TaQciOk8',3,'rbudik2');
INSERT INTO Login(password,user_id,username) VALUES ('r0WSXnQya',4,'rkentish3');
INSERT INTO Login(password,user_id,username) VALUES ('P2PsrY8QcdjX',5,'jroslen4');
INSERT INTO Login(password,user_id,username) VALUES ('2HDsvFUC4lqd',6,'ipiddle5');
INSERT INTO Login(password,user_id,username) VALUES ('UKzYoHN3',7,'bpandey6');
INSERT INTO Login(password,user_id,username) VALUES ('SorhyNaeB',8,'rcollyear7');
INSERT INTO Login(password,user_id,username) VALUES ('mtiKiqfyqJ',9,'sbrownsworth8');
INSERT INTO Login(password,user_id,username) VALUES ('ofHztgW3ORo',10,'eduhamel9');
INSERT INTO Login(password,user_id,username) VALUES ('w63DS23e1gN',11,'hglasa');
INSERT INTO Login(password,user_id,username) VALUES ('1AlOOLdN',12,'kfaichnieb');
INSERT INTO Login(password,user_id,username) VALUES ('FuCpV70GDXw',13,'dgreenstockc');
INSERT INTO Login(password,user_id,username) VALUES ('l18cspHoO',14,'afowled');
INSERT INTO Login(password,user_id,username) VALUES ('0wwjPt',15,'wcaplane');
INSERT INTO Login(password,user_id,username) VALUES ('s3hKjd2',16,'fantrimf');
INSERT INTO Login(password,user_id,username) VALUES ('FRRaR7',17,'gsongestg');
INSERT INTO Login(password,user_id,username) VALUES ('rPxUi7G',18,'acotterillh');
INSERT INTO Login(password,user_id,username) VALUES ('4fz1I3Ikhd',19,'jdreweti');
INSERT INTO Login(password,user_id,username) VALUES ('ynabMqC',20,'gjossumj');
INSERT INTO Login(password,user_id,username) VALUES ('g5PQPo',21,'rtolemank');
INSERT INTO Login(password,user_id,username) VALUES ('UI8O8SQTuw2O',22,'aricioppol');
INSERT INTO Login(password,user_id,username) VALUES ('K2Wn5wQYQsF',23,'dyearnesm');
INSERT INTO Login(password,user_id,username) VALUES ('EhEuzak',24,'mumneyn');
INSERT INTO Login(password,user_id,username) VALUES ('SiZcAYMQT',25,'ssarfatio');
INSERT INTO Login(password,user_id,username) VALUES ('tckYwRq5ztj',26,'kdulingp');
INSERT INTO Login(password,user_id,username) VALUES ('52cDXcJ',27,'mchasmoorq');
INSERT INTO Login(password,user_id,username) VALUES ('u3ltKkem',28,'cizakofr');
INSERT INTO Login(password,user_id,username) VALUES ('O0GinLl3wM',29,'erykerts');
INSERT INTO Login(password,user_id,username) VALUES ('NB7Ig2kTDRC',30,'rhickst');
INSERT INTO Login(password,user_id,username) VALUES ('9fzdtgwx4n',31,'gortegau');
INSERT INTO Login(password,user_id,username) VALUES ('L7tIqsfhj2',32,'hfitzsimmonsv');
INSERT INTO Login(password,user_id,username) VALUES ('ZAjHeJ9fIMO',33,'whailyw');
INSERT INTO Login(password,user_id,username) VALUES ('ByCMw9rmT0P',34,'bmccallx');
INSERT INTO Login(password,user_id,username) VALUES ('jTlBeQlWK3J',35,'teyey');
INSERT INTO Login(password,user_id,username) VALUES ('QuxJPMtkQlR',36,'kwapplingtonz');
INSERT INTO Login(password,user_id,username) VALUES ('QbdezCBeP5y3',37,'dbrevitt10');
INSERT INTO Login(password,user_id,username) VALUES ('qxQswHvzen',38,'czuanelli11');
INSERT INTO Login(password,user_id,username) VALUES ('kmKiPxnau',39,'dwasselin12');
INSERT INTO Login(password,user_id,username) VALUES ('aH6DVMv',40,'hselesnick13');
INSERT INTO Login(password,user_id,username) VALUES ('OmW7GNB85w',41,'eminci14');
INSERT INTO Login(password,user_id,username) VALUES ('AuwBikN0hW',42,'gperford15');
INSERT INTO Login(password,user_id,username) VALUES ('uppbfN',43,'ecurragh16');
INSERT INTO Login(password,user_id,username) VALUES ('3k3eAyG',44,'lferrey17');
INSERT INTO Login(password,user_id,username) VALUES ('7HO8EHnB',45,'rchasmar18');
INSERT INTO Login(password,user_id,username) VALUES ('LR84wxsmcHh',46,'mmaior19');
INSERT INTO Login(password,user_id,username) VALUES ('XUJGveQN',47,'ovain1a');
INSERT INTO Login(password,user_id,username) VALUES ('ZCOt5CX1l0',48,'ajestico1b');
INSERT INTO Login(password,user_id,username) VALUES ('2eeJnE9',49,'hcolthurst1c');
INSERT INTO Login(password,user_id,username) VALUES ('L9M75cj',50,'train1d');

-- Roommate Preference Samples
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (8,'nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in','tristique est et',11);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (9,'non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in','massa',33);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'ut suscipit a','eu mi nulla',45);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'curae duis faucibus accumsan','duis bibendum felis',13);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (9,'luctus et ultrices posuere cubilia','erat fermentum justo',32);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor','ligula suspendisse ornare',38);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa','tempus vivamus',24);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (8,'in porttitor','ligula',39);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'dapibus at diam','nunc',6);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'rutrum nulla nunc purus phasellus in felis donec semper sapien','non',4);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'pellentesque at nulla suspendisse potenti cras in purus eu magna','leo pellentesque',9);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (4,'vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat','duis bibendum',28);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (3,'proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis','quis libero nullam',50);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (6,'elit','augue',16);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse','tellus',5);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'cras mi pede malesuada in imperdiet et commodo vulputate justo in','at',2);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'elit ac nulla sed vel enim sit','tortor sollicitudin mi',14);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus','tincidunt',42);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (1,'consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer','nulla',35);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (4,'luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus','lacus purus',36);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'vulputate elementum','luctus et ultrices',19);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (6,'morbi ut','turpis sed',35);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (8,'ultrices posuere cubilia curae donec','proin leo',36);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (3,'nisl duis ac nibh fusce lacus purus aliquet','eget congue',47);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'justo etiam pretium iaculis justo in hac habitasse platea','volutpat in',7);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis','curae',33);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (3,'nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum','aliquam erat',12);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam','ut',28);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (9,'quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris','nunc rhoncus dui',16);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam','lobortis',27);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (9,'consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut','iaculis',34);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (6,'orci luctus et ultrices posuere cubilia curae duis faucibus accumsan','blandit mi in',37);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (6,'donec ut mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu','nulla tempus vivamus',46);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'nec condimentum neque sapien placerat ante nulla justo','sapien sapien non',46);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (6,'amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis','rhoncus',41);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet','turpis eget',7);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (4,'accumsan tellus nisi eu orci mauris lacinia sapien quis libero','vestibulum',44);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (3,'donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit','pede lobortis',32);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat','vel',11);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (2,'aliquet pulvinar sed nisl','turpis',25);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing','sociis',34);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio','vitae nisi nam',17);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (7,'quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo','in purus',49);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (1,'donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum','ligula pellentesque ultrices',33);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare','pretium',26);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (9,'dui vel sem sed sagittis nam congue risus semper porta','ligula suspendisse',31);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'risus dapibus augue vel accumsan tellus','ante',50);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'in leo maecenas pulvinar','nisl duis',26);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (10,'convallis morbi odio odio','montes',31);
INSERT INTO Roommate_Preference(importance,description,preference_name,user) VALUES (5,'eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa','natoque',11);

-- User Report Samples
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('mi nulla ac enim',false,'quisque erat eros viverra eget congue eget semper rutrum nulla',1,44,34);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('varius integer ac leo pellentesque ultrices mattis odio donec vitae',true,'luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui',2,9,5);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis',false,'ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est',3,50,14);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('dui proin leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis',false,'mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices',4,15,36);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci',true,'nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in',5,23,21);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('fusce',true,'nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede',6,35,23);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('mattis',false,'feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea',7,43,35);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea',false,'ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris',8,30,24);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas',true,'lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit',9,21,22);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue',true,'praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante',10,6,36);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer',true,'nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at',11,8,3);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('vivamus metus arcu adipiscing molestie',false,'faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non',12,39,5);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('parturient montes nascetur ridiculus',false,'sapien arcu sed augue aliquam erat volutpat in congue etiam justo',13,9,27);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('molestie nibh in lectus',true,'tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in',14,44,28);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('a libero nam dui proin leo odio porttitor id consequat in consequat ut',false,'platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut',15,15,31);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('congue risus',true,'justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec',16,19,20);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nunc purus phasellus in felis donec semper sapien a libero nam dui',false,'mi pede malesuada in imperdiet et commodo vulputate justo in',17,41,49);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('sapien cum sociis natoque penatibus et magnis dis parturient',false,'viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec',18,13,28);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('in faucibus orci luctus et ultrices posuere',true,'semper porta volutpat quam pede lobortis ligula sit amet eleifend pede',19,19,30);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('dictumst etiam faucibus',true,'magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem',20,30,37);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('tortor duis mattis egestas metus aenean fermentum donec',true,'diam vitae quam suspendisse potenti nullam porttitor lacus at turpis',21,39,36);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu',false,'turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor',22,17,13);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in',true,'turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit',23,33,27);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('in purus',false,'habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla',24,41,22);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('ultrices posuere cubilia',false,'sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus',25,12,5);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta',false,'id massa id nisl venenatis lacinia aenean sit amet justo morbi ut',26,18,4);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque',false,'duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non',27,35,50);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('non pretium quis lectus suspendisse',true,'nisi volutpat eleifend donec ut dolor morbi vel lectus in',28,12,37);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae',false,'congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis',29,16,41);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien',true,'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus',30,33,27);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas',true,'morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in',31,32,42);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('quis lectus',false,'erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis',32,14,34);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('ante',false,'ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum',33,36,46);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('leo maecenas pulvinar lobortis est phasellus sit',false,'lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam',34,32,49);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus',false,'ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in',35,31,20);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('integer ac neque duis bibendum morbi non quam nec',false,'erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec',36,20,15);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('donec vitae nisi nam ultrices',false,'ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl',37,13,16);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('elementum',true,'et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit',38,22,31);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst',false,'gravida sem praesent id massa id nisl venenatis lacinia aenean sit',39,5,14);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('ut odio cras mi pede malesuada in',false,'dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum',40,39,34);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi',false,'ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis nulla neque',41,17,33);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum',true,'quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat',42,21,25);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse',true,'dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat',43,37,15);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('dolor sit amet consectetuer adipiscing elit proin interdum mauris non',true,'tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer',44,44,6);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et',true,'in consequat ut nulla sed accumsan felis ut at dolor quis odio',45,42,27);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('quam pharetra magna ac consequat metus sapien',false,'cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae',46,31,3);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('sed tincidunt eu felis',false,'orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec',47,42,26);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras',true,'eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a libero nam dui proin leo',48,19,25);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis',true,'placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget',49,13,2);
INSERT INTO User_Report(issue,resolved,comment,report_id,reporter,reported_user) VALUES ('sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet',true,'ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor',50,15,2);

-- Message Samples
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-27 08:10:27','amet sapien','tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum',1,43,38);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-01-17 18:44:11','amet sapien dignissim vestibulum vestibulum','sapien urna pretium nisl ut volutpat sapien arcu',2,36,43);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-08-04 18:39:09','pulvinar nulla pede ullamcorper augue','accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia',3,9,20);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-08-30 18:08:00','interdum mauris non','risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue',4,10,42);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-01-30 21:07:54','mauris','non sodales sed tincidunt eu felis fusce posuere felis sed lacus',5,27,33);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-06-26 23:10:41','habitasse platea dictumst','vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in',6,24,27);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-10-01 01:21:52','sem duis aliquam convallis','orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem',7,2,18);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-10-23 22:52:29','augue','hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula',8,19,32);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-07 03:49:51','justo sollicitudin','proin leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo',9,20,30);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-06-30 05:31:02','in libero ut','suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat',10,40,45);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-23 02:19:13','consectetuer adipiscing elit proin','libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla',11,25,15);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-10 03:12:47','quis turpis sed ante vivamus','lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum',12,1,48);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-11-14 11:36:56','elit proin risus praesent','augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat',13,26,28);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-01-10 23:50:06','justo nec','consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus',14,17,31);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-30 05:38:45','amet turpis elementum ligula vehicula','et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit',15,48,25);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-29 15:17:33','platea dictumst etiam faucibus','consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris',16,39,46);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-02-11 10:45:19','sapien cursus vestibulum proin','luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit',17,6,42);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-10-24 23:09:52','eu nibh','venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in',18,13,30);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-02-03 20:34:59','porttitor','non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce',19,16,31);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-11-11 16:59:31','lorem ipsum dolor','ultrices',20,2,35);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-04-17 04:06:29','pede justo eu massa donec','eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit',21,1,34);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-05-10 15:26:31','odio justo sollicitudin','orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem',22,21,44);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-05-28 11:46:16','et ultrices posuere cubilia curae','luctus et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam',23,24,2);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-02-26 06:25:51','elit','erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt',24,40,43);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-10-28 02:25:04','ultrices posuere cubilia curae','blandit ultrices enim lorem ipsum dolor sit',25,16,37);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-10-23 03:24:25','ornare imperdiet sapien urna','ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non',26,4,37);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-31 02:08:10','molestie hendrerit at vulputate','aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis nulla neque libero convallis eget',27,49,19);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-03-04 03:55:20','ac diam','quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a',28,20,2);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-14 12:48:34','convallis nulla neque','consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat',29,13,6);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-02-02 12:54:12','id ornare imperdiet','ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero',30,26,29);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-01-29 14:30:47','ullamcorper augue a suscipit nulla','ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio',31,21,24);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-22 15:02:18','nec dui luctus rutrum','eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia',32,35,46);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-09-18 04:38:34','maecenas tristique est et tempus','lectus vestibulum quam sapien varius ut blandit',33,18,32);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-02-03 19:35:54','blandit lacinia erat vestibulum','nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc',34,1,15);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-06-08 13:20:40','iaculis justo in hac habitasse','hac habitasse platea dictumst',35,34,12);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-08-27 01:26:17','ornare consequat lectus in est','ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor',36,31,37);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-03 05:18:42','tincidunt in','et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis',37,5,31);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-04-03 16:58:49','suspendisse ornare','porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue',38,31,43);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-12-10 11:05:30','a odio in hac habitasse','proin at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec dui',39,12,37);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-07 22:14:34','pede ullamcorper augue a','nulla integer pede justo lacinia eget tincidunt eget tempus vel',40,13,16);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-15 01:10:22','cras non velit','pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales',41,12,3);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-06-04 13:35:27','scelerisque mauris sit amet','penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum',42,43,2);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-11 23:38:30','odio curabitur','morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper',43,4,1);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-07-02 15:31:34','dui proin leo odio','ligula sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus',44,3,39);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2023-03-29 06:21:03','lectus pellentesque eget','aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis',45,20,24);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-08-03 08:23:15','porta volutpat erat quisque','morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor',46,36,6);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-05-17 01:59:46','odio','magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst',47,39,45);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-08-14 17:07:47','tincidunt nulla','pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et',48,27,39);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-05-13 20:00:44','luctus cum sociis natoque penatibus','potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam',49,5,3);
INSERT INTO Message(timestamp,subject,contents,message_id,sender,receiver) VALUES ('2022-04-30 23:34:21','pellentesque ultrices phasellus id','vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet',50,36,43);

-- Sublet Listing Samples
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-26 08:45:54',false,7,3,'2023-08-15 14:31:48','2024-01-23 02:42:58',false,'orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus',1256,16550,'Troy','Erie',39,1);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-11-02 00:57:50',true,9,4,'2023-07-01 05:23:53','2024-01-29 11:28:47',false,'id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien',3669,NULL,'Harbort','Calibishie',27,2);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-08-14 22:12:03',true,8,4,'2023-08-17 20:25:26','2024-01-11 10:19:35',true,'consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales',3751,45149,'Schiller','Essen',32,3);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-11-28 11:05:28',false,8,3,'2023-04-26 05:14:28','2023-10-14 01:19:29',true,'vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec',2456,NULL,'Welch','Jiangpan',18,4);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-07-23 06:09:54',true,7,1,'2023-06-10 22:17:53','2023-10-16 00:47:53',false,'tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl',1390,87200-000,'Oneill','Cianorte',2,5);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-08-08 23:05:02',false,7,5,'2023-07-21 19:21:38','2024-03-06 02:39:57',false,'at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper',4175,352364,'Lukken','Tbilisskaya',11,6);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-01 18:31:39',true,9,4,'2023-05-12 23:25:32','2023-12-31 18:21:08',false,'in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis',1214,188422,'Esker','Seredka',1,7);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-17 03:33:06',true,9,1,'2023-08-21 14:27:16','2023-10-05 04:31:47',true,'erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat',576,NULL,'Buell','Thạnh Phú',12,8);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-09-25 02:42:30',true,2,4,'2023-08-10 03:36:19','2024-04-25 16:40:40',true,'id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien',3570,60681,'Lindbergh','Chicago',43,9);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-31 18:04:47',false,4,2,'2023-06-23 02:52:47','2024-02-28 06:00:44',false,'phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci',4036,59301,'Forest Dale','Domanín',44,10);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-05-19 23:31:27',false,5,4,'2023-04-08 03:15:38','2023-12-24 21:51:36',false,'id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla',3624,44-196,'Del Sol','Knurów',38,11);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-05-01 12:24:56',true,10,4,'2023-07-30 14:25:24','2023-12-12 04:27:46',true,'nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque',1698,NULL,'Melvin','Chengmagang',23,12);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-12-05 03:07:48',false,7,5,'2023-08-05 10:47:58','2023-12-25 06:59:05',true,'sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam',2896,NULL,'Thierer','Amerta',9,13);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-03-22 18:03:45',false,10,5,'2023-05-25 09:01:30','2024-01-05 19:42:40',false,'curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus',1820,NULL,'Ruskin','Tenggina Daya',47,14);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-08-24 12:22:23',false,2,5,'2023-04-16 05:54:19','2023-09-22 04:14:16',false,'quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia',3038,NULL,'Surrey','Hetang',11,15);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-12 01:41:53',false,6,3,'2023-04-06 16:08:50','2024-01-19 23:36:44',false,'elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien',1016,NULL,'Lawn','Bellavista',38,16);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-22 13:45:06',false,7,2,'2023-08-02 09:03:04','2024-02-17 09:39:05',false,'fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum',1304,NULL,'Hermina','Fezna',14,17);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-11-06 02:53:04',true,6,5,'2023-08-14 14:00:05','2023-12-07 07:56:08',true,'cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui',1755,NULL,'Harper','Dongmazar',38,18);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-27 12:11:49',true,6,1,'2023-04-17 19:51:57','2024-02-09 01:07:03',false,'faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam',4302,NULL,'Burrows','Zea',2,19);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-12-05 01:44:23',true,6,3,'2023-07-01 00:57:11','2023-12-13 08:52:50',false,'donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio',639,NULL,'Bashford','Huilelot',24,20);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-12-21 22:13:15',true,9,5,'2023-06-16 20:17:46','2023-09-24 12:58:59',true,'lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor',2403,57-343,'Judy','Lewin Kłodzki',34,21);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-12 00:16:47',true,10,4,'2023-05-16 13:12:21','2024-04-28 06:09:13',true,'quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst',3825,93300-000,'Warrior','Novo Hamburgo',8,22);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-05-15 07:40:32',false,8,4,'2023-06-26 23:43:58','2024-03-15 08:03:50',true,'in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum',4884,NULL,'Forest','Muararupit',21,23);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-25 12:42:34',false,10,3,'2023-05-04 12:46:10','2024-02-22 08:19:53',true,'erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem',1765,53120,'Golf View','Changhan',33,24);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-05-22 17:04:16',true,3,4,'2023-08-03 15:15:26','2023-12-17 21:23:55',false,'sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus',4826,NULL,'Laurel','Rukunlima Bawah',17,25);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-12-10 03:13:30',true,7,4,'2023-05-31 06:35:18','2023-11-25 01:04:45',false,'pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin',2671,21260,'Judy','Imotski',32,26);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-03-13 03:09:02',true,7,1,'2023-08-10 07:20:07','2023-11-04 18:42:55',false,'ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor',1539,74164,'Northridge','Saint-Julien-en-Genevois',47,27);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-11 03:01:21',false,6,5,'2023-04-09 20:14:13','2023-10-29 16:11:37',false,'suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse platea',1518,NULL,'Springs','Bassa',50,28);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-03-06 00:15:37',true,3,2,'2023-06-21 22:48:10','2023-10-30 09:34:25',false,'ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis',4816,32300,'Kedzie','Kalmunai',14,29);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-03-09 07:39:29',true,4,4,'2023-05-22 21:15:15','2023-12-20 02:05:17',false,'in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus',3911,NULL,'3rd','Dayuan',35,30);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-18 16:14:05',true,6,2,'2023-08-03 07:17:11','2024-01-20 06:47:50',false,'in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris',1892,NULL,'Clove','Puzi',2,31);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-06-11 10:25:59',false,8,4,'2023-08-18 03:39:09','2023-09-30 16:23:10',true,'quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat',3640,NULL,'Johnson','Anshun',5,32);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-03 00:35:48',true,9,3,'2023-05-25 10:28:25','2023-12-25 01:58:27',true,'aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci',2731,NULL,'Burrows','Yangcun',10,33);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-14 08:53:20',true,9,1,'2023-08-03 13:40:22','2024-01-21 05:54:53',false,'pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit',4921,37924,'Stang','Knoxville',11,34);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-27 20:58:31',true,2,2,'2023-05-23 14:51:59','2024-01-15 05:30:43',false,'in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor',1747,72016,'Westend','Västerås',17,35);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-04-21 04:55:53',true,1,2,'2023-04-01 19:25:21','2023-09-23 17:41:28',true,'elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget',4850,NULL,'Bluejay','Bāniyās',27,36);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-10-24 02:12:39',false,4,2,'2023-05-12 13:59:48','2023-09-21 16:54:26',true,'in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur',2933,NULL,'Morrow','Lurut',14,37);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-04-19 23:41:53',true,5,2,'2023-07-25 23:01:17','2024-04-02 21:33:58',false,'adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis',1172,NULL,'3rd','Krasne',34,38);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-04-25 11:15:38',false,7,1,'2023-06-24 22:20:50','2024-02-09 15:51:53',true,'amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis',3598,NULL,'Burrows','Dzüünkharaa',23,39);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-11-20 02:31:20',true,10,2,'2023-04-29 22:31:45','2024-04-20 12:59:56',false,'at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo',1221,57232,'Debs','Oskarshamn',4,40);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-02-02 13:30:48',false,1,5,'2023-05-14 18:02:43','2024-02-29 08:59:59',false,'id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam',5000,NULL,'Forest Run','Sharga',10,41);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-07-05 23:49:10',false,3,5,'2023-04-07 06:39:15','2024-03-12 18:53:30',true,'libero nullam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus',1346,442680,'Kennedy','Nikol’sk',14,42);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2023-01-02 08:16:09',false,7,3,'2023-06-19 04:23:01','2023-11-18 22:41:24',true,'in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque',3595,NULL,'Menomonie','Novi Sad',41,43);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-06-20 02:01:14',true,10,1,'2023-08-28 13:14:18','2023-09-21 07:37:52',true,'consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus',726,NULL,'Thierer','Manadhoo',2,44);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-06-27 12:04:42',true,7,1,'2023-05-02 01:41:00','2023-12-14 16:02:23',true,'eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce',3843,NULL,'Old Shore','Veguitas',32,45);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-06-26 15:12:14',false,10,5,'2023-08-21 13:52:50','2024-01-25 18:42:34',false,'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat',4143,92165,'Donald','San Diego',7,46);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-05-12 17:37:08',false,10,4,'2023-06-12 18:39:13','2024-03-31 23:19:48',true,'eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo',4014,NULL,'Mayfield','Nakajah',49,47);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-11-14 20:34:11',true,6,5,'2023-04-01 03:59:26','2024-02-03 18:10:34',false,'curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis',4298,140514,'Park Meadow','Krasnaya Poyma',50,48);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-09-09 07:01:00',false,8,4,'2023-06-05 07:24:34','2024-03-17 10:24:54',false,'viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a libero nam dui',1475,NULL,'Bashford','Vĩnh Thuận',17,49);
INSERT INTO Sublet_Listing(post_time,availability,roommate_count,bathroom_count,start_date,end_date,furnished_status,description,rent,zipcode,street,city,subletter,listing_id) VALUES ('2022-12-19 10:13:23',false,9,1,'2023-07-18 14:17:44','2023-10-09 21:26:01',true,'ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut',808,7604,'Myrtle','Péruwelz',8,50);

-- Sublet Offer Samples
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-06 18:42:53','2024-01-03 12:24:03',1075,'2023-04-13 06:05:13',false,1,42,2);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-14 16:07:20','2024-02-03 17:49:35',514,'2023-04-02 17:30:28',false,2,35,35);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-10 07:51:25','2023-09-24 00:14:08',2203,'2023-04-03 16:21:27',false,3,4,47);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-24 16:46:53','2023-09-22 03:11:41',4443,'2023-04-10 04:00:10',true,4,18,39);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-14 01:01:37','2024-02-01 00:17:40',2023,'2023-04-11 14:38:40',false,5,33,10);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-04 22:02:38','2024-03-02 12:46:47',2355,'2023-04-11 20:18:31',false,6,36,38);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-31 12:46:26','2023-09-08 01:38:37',1079,'2023-04-13 00:38:41',true,7,13,8);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-17 02:15:04','2023-12-13 06:37:44',3960,'2023-04-09 06:08:11',false,8,42,19);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-30 07:13:32','2024-03-28 17:58:27',3293,'2023-04-01 18:27:34',true,9,10,44);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-14 21:58:19','2023-12-07 10:38:01',3795,'2023-04-03 12:56:13',false,10,46,13);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-06 11:12:29','2024-03-10 15:47:25',4219,'2023-04-13 09:47:56',true,11,16,7);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-11 16:06:01','2024-03-27 14:55:07',2254,'2023-04-13 03:07:57',true,12,26,30);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-17 22:47:46','2024-02-10 03:57:26',3327,'2023-04-09 21:20:42',true,13,37,19);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-10 13:07:47','2024-01-10 17:10:53',1538,'2023-04-15 22:18:23',true,14,16,8);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-08 09:33:39','2023-10-28 18:31:44',1071,'2023-04-05 12:37:12',false,15,43,21);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-15 13:14:48','2023-11-06 17:32:16',1936,'2023-04-14 09:30:26',true,16,24,26);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-09 17:36:13','2023-09-30 15:12:32',3796,'2023-04-08 22:40:59',false,17,36,46);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-23 16:53:31','2024-02-17 07:58:09',2146,'2023-04-13 13:11:59',false,18,28,22);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-27 02:28:07','2023-12-25 16:54:17',1435,'2023-04-07 15:05:27',true,19,41,40);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-28 04:37:59','2023-09-11 10:51:58',2193,'2023-04-03 11:20:29',true,20,49,3);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-18 04:09:01','2024-03-17 13:55:33',2889,'2023-04-13 00:59:59',false,21,32,43);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-23 14:07:25','2024-02-22 05:42:42',4393,'2023-04-06 21:47:09',false,22,6,2);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-06 10:05:09','2023-11-16 09:15:55',2516,'2023-04-12 23:22:51',false,23,13,4);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-08 00:37:24','2023-12-10 02:20:13',916,'2023-04-02 21:11:45',false,24,26,14);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-15 02:48:53','2024-01-30 06:04:57',919,'2023-04-14 00:09:22',false,25,45,35);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-11 21:50:02','2024-04-08 13:01:16',1849,'2023-04-08 02:34:45',false,26,22,29);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-04 03:39:34','2023-12-30 14:35:59',3023,'2023-04-03 06:34:54',false,27,13,7);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-08 04:51:24','2023-10-20 02:30:29',3021,'2023-04-06 15:20:08',true,28,23,47);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-04 13:11:53','2023-11-02 20:12:37',1949,'2023-04-03 14:01:43',false,29,38,36);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-16 00:02:52','2024-04-26 18:58:20',3551,'2023-04-06 10:45:57',true,30,49,4);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-24 20:34:45','2024-02-17 06:23:00',3669,'2023-04-01 17:00:01',false,31,25,8);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-03 07:34:13','2023-09-01 01:16:11',739,'2023-04-09 01:59:28',false,32,27,19);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-04 10:35:01','2024-04-09 06:00:52',2158,'2023-04-13 17:46:32',false,33,8,8);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-16 08:29:57','2023-10-08 21:41:58',458,'2023-04-14 07:24:29',true,34,42,37);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-26 05:08:27','2023-09-19 17:44:30',1152,'2023-04-01 11:09:59',false,35,23,26);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-15 22:54:52','2023-10-10 15:28:16',1043,'2023-04-15 20:44:21',false,36,16,34);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-21 15:15:02','2023-12-12 15:29:55',2520,'2023-04-05 08:52:06',false,37,34,24);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-10 16:05:01','2024-01-09 17:43:48',2599,'2023-04-13 06:00:22',true,38,13,29);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-20 08:36:29','2023-12-30 12:49:41',2313,'2023-04-09 09:20:19',false,39,8,42);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-07-07 05:35:01','2024-01-27 19:41:06',719,'2023-04-01 16:29:31',true,40,27,16);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-29 19:02:51','2024-04-02 09:45:43',4177,'2023-04-11 02:19:14',false,41,25,50);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-01 05:37:10','2023-09-21 06:36:13',2148,'2023-04-07 15:24:39',false,42,37,12);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-24 20:44:11','2024-04-11 10:28:45',2653,'2023-04-13 11:02:39',true,43,37,26);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-14 05:31:50','2023-10-10 18:38:57',4080,'2023-04-12 06:00:13',false,44,9,1);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-07 14:10:16','2024-02-04 21:37:50',3297,'2023-04-02 05:03:33',true,45,41,36);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-06-15 04:35:20','2024-01-18 20:33:59',1116,'2023-04-11 18:41:00',false,46,34,4);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-05-06 15:01:14','2023-10-12 06:59:10',3301,'2023-04-07 00:21:48',true,47,40,37);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-08-11 11:57:32','2024-04-13 17:41:04',1813,'2023-04-03 12:14:58',false,48,50,28);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-10 09:01:59','2023-09-04 12:25:07',4314,'2023-04-07 09:10:09',true,49,11,29);
INSERT INTO Sublet_Offer(start_date,end_date,rent,time_sent,status,offer_id,offering_user,listing_id) VALUES ('2023-04-22 17:41:56','2023-11-12 05:21:45',4192,'2023-04-05 02:40:13',false,50,32,25);

-- Comment Samples
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-30 12:01:56','sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy',1,NULL,3,32);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-30 21:46:31','interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat',2,NULL,25,42);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-20 01:55:00','primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue',3,2,25,44);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-07 22:49:00','potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi',4,NULL,37,6);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-09 02:06:09','gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices',5,1,3,1);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-05 22:42:48','molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque',6,NULL,17,18);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-18 01:13:10','pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus',7,NULL,7,42);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-02 07:19:40','metus aenean',8,NULL,17,6);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-24 18:41:01','at velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus',9,NULL,35,22);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-07 07:11:11','consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit',10,5,3,46);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-12 09:24:05','tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit',11,NULL,46,38);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-28 14:58:54','est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in',12,NULL,36,33);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-25 00:24:30','diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam',13,10,3,36);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-25 20:40:52','ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus',14,NULL,49,27);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-29 10:48:08','eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec',15,4,37,10);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-05 02:22:12','tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis',16,6,17,33);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-16 12:21:38','hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas',17,12,36,41);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-22 11:51:38','eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis',18,NULL,40,45);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-12 19:22:43','dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris',19,NULL,16,15);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-13 03:38:15','maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris',20,17,36,26);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-18 23:58:34','praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus',21,17,36,4);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-30 14:32:29','dolor sit amet consectetuer adipiscing elit proin interdum mauris non',22,NULL,46,18);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-05 21:49:40','odio odio elementum eu interdum eu tincidunt',23,NULL,22,42);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-11 06:15:08','nam',24,5,3,15);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-12 21:44:43','ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices',25,20,36,44);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-11 08:55:05','rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis',26,NULL,19,35);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-10 05:31:44','mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel',27,9,35,47);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-25 02:23:30','lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo',28,NULL,12,41);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-30 17:13:22','pede posuere nonummy integer non velit donec diam neque vestibulum eget',29,NULL,17,23);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-29 13:52:50','nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam',30,18,40,21);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-24 12:35:20','viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus',31,NULL,18,13);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-27 08:18:19','curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in',32,NULL,27,28);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-05 21:30:43','mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus',33,NULL,46,26);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-20 09:06:02','eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum',34,1,3,2);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-27 08:23:46','blandit nam nulla integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi',35,NULL,19,5);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-30 18:04:37','natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean',36,NULL,44,17);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-26 07:22:31','sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo',37,NULL,23,48);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-12 13:00:04','sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna',38,NULL,49,29);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-14 18:48:35','ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in purus eu',39,NULL,14,18);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-08 14:26:43','volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus',40,NULL,20,17);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-22 00:32:21','nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis',41,24,3,9);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-26 09:48:13','non lectus aliquam sit amet diam in',42,NULL,8,7);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-19 19:38:31','dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a ipsum',43,NULL,26,34);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-27 18:28:39','elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean',44,NULL,39,25);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-15 12:28:00','ac nulla sed vel enim sit amet nunc viverra',45,43,26,18);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-06 12:57:08','luctus et ultrices posuere',46,NULL,9,2);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-13 23:50:50','ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae duis',47,NULL,13,41);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-01 15:15:51','convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique',48,NULL,17,17);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-05-30 23:41:57','nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien',49,NULL,14,34);
INSERT INTO Comment(timestamp,text,comment_id,reply_id,listing_id,housing_account_id) VALUES ('2023-04-07 01:30:31','elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus',50,NULL,10,25);

-- Moderator Review Samples
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('ipsum dolor',31,48);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('at velit eu est congue elementum in hac habitasse platea dictumst',19,26);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('donec semper sapien a libero nam dui proin leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio',4,9);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('lectus aliquam sit amet',31,4);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu',15,17);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus',33,14);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus',19,20);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu',22,28);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio',2,22);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis',1,6);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula',45,8);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae',22,44);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('blandit nam nulla integer pede',20,6);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy',42,32);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis',17,42);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('vel ipsum praesent blandit lacinia',1,43);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('lectus suspendisse potenti in eleifend quam',23,47);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('tempus vivamus in felis eu sapien cursus vestibulum proin eu mi',9,13);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula',17,23);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in',21,33);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus',3,26);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('in consequat ut nulla sed accumsan felis ut at dolor quis',22,35);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('orci',5,3);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor',32,1);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci',16,15);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('cubilia curae donec pharetra magna vestibulum aliquet',9,16);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('et ultrices posuere cubilia curae nulla dapibus',21,8);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis',10,25);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit',34,45);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('venenatis turpis enim blandit mi',46,20);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac',39,20);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim',37,19);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('tellus semper interdum mauris ullamcorper purus sit amet nulla',29,9);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis',28,12);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc',7,38);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('consequat ut nulla',15,21);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam',44,20);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras',4,2);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('vitae consectetuer eget rutrum at lorem integer',7,20);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('consequat nulla nisl nunc nisl duis bibendum felis sed interdum',31,6);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus',8,46);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at',41,34);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('venenatis tristique fusce congue diam id',31,49);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a',22,7);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('morbi vel lectus in quam fringilla rhoncus mauris enim',25,42);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet',30,21);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque',21,32);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum',19,23);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('laoreet ut rhoncus aliquet pulvinar sed nisl',9,23);
INSERT INTO Moderator_Review(action,moderator_id,report_id) VALUES ('pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum',49,33);

-- Moderator Edit Samples
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla','2023-04-25 16:05:34',45,8);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque','2023-04-30 17:14:41',31,36);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum','2023-04-11 07:23:44',36,35);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('convallis','2023-04-01 17:04:48',4,10);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus','2023-04-07 20:51:38',41,38);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('integer','2023-04-11 18:15:35',42,27);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas','2023-04-19 05:12:41',3,2);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus','2023-04-10 10:23:09',14,5);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ullamcorper augue','2023-04-01 22:41:25',15,8);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras','2023-04-16 02:17:46',45,6);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci','2023-04-27 18:13:17',22,26);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede','2023-04-02 08:24:41',27,35);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat','2023-04-04 18:44:43',42,34);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sapien a libero nam dui proin leo','2023-04-25 05:18:27',18,35);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a libero nam dui','2023-04-16 11:26:10',19,14);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper','2023-04-03 02:41:50',28,22);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('pede ac diam cras pellentesque volutpat dui maecenas tristique est','2023-04-26 15:42:44',1,18);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sit amet cursus id turpis integer aliquet massa','2023-04-23 21:01:40',25,19);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('amet cursus id turpis integer aliquet massa','2023-04-24 12:12:14',48,21);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('lorem quisque ut erat','2023-04-13 13:30:07',14,28);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus','2023-04-21 21:26:36',31,26);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sapien sapien non mi integer ac neque duis bibendum morbi non quam nec','2023-04-12 14:23:55',29,15);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('a','2023-04-13 19:30:39',27,3);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam','2023-04-26 21:51:23',20,5);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('tortor quis turpis sed','2023-04-18 17:27:48',32,6);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('primis in faucibus','2023-04-27 02:02:01',40,37);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus','2023-04-30 19:02:26',28,8);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ac est lacinia nisi venenatis tristique fusce','2023-04-22 15:36:55',8,29);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse','2023-04-17 20:10:04',37,21);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum','2023-04-17 03:05:17',45,18);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus','2023-04-08 07:23:52',47,48);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus aliquam','2023-04-20 02:09:18',18,33);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('id mauris vulputate elementum nullam','2023-04-07 06:10:17',13,21);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel','2023-04-19 17:40:32',10,1);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('nec condimentum','2023-04-30 15:52:20',47,20);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('felis sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in','2023-04-15 12:43:12',23,24);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('blandit ultrices enim lorem ipsum dolor sit','2023-04-24 07:10:27',26,23);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus','2023-04-16 21:10:03',47,28);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis','2023-04-07 08:11:32',20,16);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient','2023-04-15 01:54:47',3,9);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('sed lacus','2023-04-20 12:54:18',37,26);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros','2023-04-27 03:44:49',4,24);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('nec molestie sed justo pellentesque viverra pede ac diam cras','2023-04-09 23:59:13',14,27);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien','2023-04-03 18:28:49',46,23);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia eget','2023-04-24 13:55:29',36,9);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere','2023-04-07 07:49:00',2,27);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et','2023-04-21 16:28:03',1,30);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('donec','2023-04-26 19:22:21',18,36);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat','2023-04-09 00:00:24',33,21);
INSERT INTO Moderator_Edit(change_description,timestamp,moderator_id,listing_id) VALUES ('ipsum primis in faucibus orci luctus et ultrices posuere','2023-04-28 15:09:30',10,39);

-- Images Samples
INSERT INTO Images(image_file_name,listing_id) VALUES ('Hac.ppt',28);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Aenean.mp3',40);
INSERT INTO Images(image_file_name,listing_id) VALUES ('PhasellusSit.xls',4);
INSERT INTO Images(image_file_name,listing_id) VALUES ('FaucibusOrci.xls',7);
INSERT INTO Images(image_file_name,listing_id) VALUES ('ParturientMontesNascetur.png',31);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Posuere.ppt',23);
INSERT INTO Images(image_file_name,listing_id) VALUES ('EratQuisque.mpeg',37);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Nulla.doc',33);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Eu.mpeg',4);
INSERT INTO Images(image_file_name,listing_id) VALUES ('InConsequat.tiff',48);
INSERT INTO Images(image_file_name,listing_id) VALUES ('TristiqueEst.avi',29);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AccumsanOdioCurabitur.ppt',7);
INSERT INTO Images(image_file_name,listing_id) VALUES ('LaciniaSapien.png',45);
INSERT INTO Images(image_file_name,listing_id) VALUES ('MorbiAIpsum.tiff',6);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Maecenas.ppt',33);
INSERT INTO Images(image_file_name,listing_id) VALUES ('CurabiturInLibero.xls',14);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AtNuncCommodo.xls',27);
INSERT INTO Images(image_file_name,listing_id) VALUES ('LectusPellentesque.xls',32);
INSERT INTO Images(image_file_name,listing_id) VALUES ('NullaMollisMolestie.avi',14);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Venenatis.ppt',6);
INSERT INTO Images(image_file_name,listing_id) VALUES ('UltricesPosuereCubilia.ppt',47);
INSERT INTO Images(image_file_name,listing_id) VALUES ('DiamIn.ppt',47);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Mattis.doc',26);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Sem.avi',45);
INSERT INTO Images(image_file_name,listing_id) VALUES ('ConsequatNullaNisl.mp3',41);
INSERT INTO Images(image_file_name,listing_id) VALUES ('InQuam.xls',39);
INSERT INTO Images(image_file_name,listing_id) VALUES ('TortorRisus.xls',32);
INSERT INTO Images(image_file_name,listing_id) VALUES ('SodalesSedTincidunt.xls',22);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Vivamus.xls',20);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AliquamQuis.txt',4);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Turpis.ppt',31);
INSERT INTO Images(image_file_name,listing_id) VALUES ('PhasellusSit.mp3',14);
INSERT INTO Images(image_file_name,listing_id) VALUES ('VariusNulla.mov',47);
INSERT INTO Images(image_file_name,listing_id) VALUES ('LigulaVehicula.mov',6);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Nec.ppt',33);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AmetConsectetuer.avi',18);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Eget.gif',38);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AmetLobortis.mp3',47);
INSERT INTO Images(image_file_name,listing_id) VALUES ('TurpisElementum.avi',40);
INSERT INTO Images(image_file_name,listing_id) VALUES ('AmetDiamIn.mov',21);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Rutrum.xls',50);
INSERT INTO Images(image_file_name,listing_id) VALUES ('PharetraMagna.jpeg',47);
INSERT INTO Images(image_file_name,listing_id) VALUES ('SedAnteVivamus.avi',20);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Cum.mp3',40);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Sed.mp3',4);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Sagittis.tiff',50);
INSERT INTO Images(image_file_name,listing_id) VALUES ('NecMolestieSed.tiff',2);
INSERT INTO Images(image_file_name,listing_id) VALUES ('SapienVariusUt.mp3',2);
INSERT INTO Images(image_file_name,listing_id) VALUES ('Sollicitudin.avi',32);
INSERT INTO Images(image_file_name,listing_id) VALUES ('IaculisDiam.tiff',31);

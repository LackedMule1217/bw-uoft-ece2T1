/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   DBentry.cpp
 * Author: weishij2
 * 
 * Created on November 24, 2018, 12:23 PM
 */

#include "DBentry.h"



// A) Constructors
//    A.1) Default constructor
DBentry::DBentry() {
}
//    A.2) Second constructor
DBentry::DBentry(string _name, unsigned int _IPaddress, bool _active) {
    name = _name;
    IPaddress = _IPaddress;
    active = _active;
}

// B) Destructor
DBentry::~DBentry() {
}

// C) Mutators
//    C.1) Sets the domain name, which is used as a key
void DBentry::setName(string _name) {
    name = _name;
}
//    C.2) Sets the IPaddress data
void DBentry::setIPaddress(unsigned int _IPaddress) {
    IPaddress = _IPaddress;
}
//    C.3) Sets whether or not the entry is active
void DBentry::setActive(bool _active) {
    active = _active;
}

// D) Accessors
//    D.1) Returns the name
string DBentry::getName() const {
    return name;
}
//    D.2) Returns the IPaddress data
unsigned int DBentry::getIPaddress() const {
    return IPaddress;
}
//    D.3) Returns whether or not this entry is active
bool DBentry::getActive() const {
    return active;
}

// E) Non-member functions
//    E.1) Prints the entry in the format
//         name : IPaddress : active  followed by newline active is printed as a string (active or inactive)
ostream& operator<< (ostream& out, const DBentry& rhs) {
    out << rhs.name << " : " << rhs.IPaddress << " : " << (rhs.active ? "active" : "inactive") << endl;
    return out;
}

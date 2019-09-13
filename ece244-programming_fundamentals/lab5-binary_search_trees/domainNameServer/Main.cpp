/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.cpp
 * Author: weishij2
 *
 * Created on November 23, 2018, 9:47 PM
 */

#include <iostream>
#include <sstream>
#include <string>

using namespace std;

#include "DBentry.h"
#include "TreeDB.h"
#include "TreeNode.h"

// Function prototypes of helper functions
// A) ABSTRACTION LEVEL A: Commands
//    A.1) Command 1: insert
void insert(TreeDB & database, const string & name, const unsigned int & IPaddress, const bool & status);
//    A.2) Command 2: find
void find(TreeDB & database, const string & name);
//    A.3) Command 3: remove
void remove(TreeDB & database, const string & name);
//    A.4) Command 4: printall
void printAll(TreeDB & database);
//    A.5) Command 5: printprobes
void printProbes(TreeDB & database, const string & name);
//    A.6) Command 6: removeall
void removeAll(TreeDB & database);
//    A.7) Command 7: countactive
void countActive(TreeDB & database);
//    A.8) Command 8: updatestatus
void updateStatus(TreeDB & database, const string & name, const bool & status);
// B) ABSTRACTION LEVEL B: Print output
//    B.1) Error message: entry already exists
void printErrObjectExists();
//    B.2) Error message: entry does not exist
void printErrObjectDNE();
//    B.3) Error message: success
void printErrSuccess();

/*
 * A simple domain name server (DNS) to store and retrieve data
 */
int main() {
    // 0) Instantiate variables
    TreeDB database;
    string line;
    string command;
    string name;
    string statusStr;
    unsigned int IPaddress;
    bool status;
    
    // 1) Parse user input
    while (!cin.eof()) {
        // 1.1) Prompt for user input
        cout << "> ";
        getline(cin, line);
        // 1.2) Feed 'line' into 'lineStream' for parsing
        stringstream lineStream (line);
        // 1.3) Clear 'arguments' and 'command' from previous line of user-input
        command.clear();
        name.clear();
        statusStr.clear();
        // 1.4) Extracts command
            /* 
             * Possible Commands:
             * (1) insert 'name' 'IPaddress' 'status'
             * (2) find 'name'
             * (3) remove 'name'
             * (4) printall
             * (5) printprobes 'name'
             * (6) removeall
             * (7) countactive
             * (8) updatestatus 'name' 'status'
            */
        lineStream >> command;
        if (command.empty()) continue;
        // 1.5) Store arguments corresponding to 'command'
        if      (command == "insert")           lineStream >> name >> IPaddress >> statusStr;
        else if (command == "find" || command == "remove" || command == "printprobes")
                                                lineStream >> name;
        else if (command == "updatestatus")     lineStream >> name >> statusStr;
        if (command == "insert" || command == "updatestatus") {
            if (statusStr == "active")          status = true;
            else if (statusStr == "inactive")   status = false;
            else                                continue;
        }
        // 1.6) Call functions corresponding to each command
        if       (command == "insert")       insert(database, name, IPaddress, status);
        else if (command == "find")         find(database, name);
        else if (command == "remove")       remove(database, name);
        else if (command == "printall")     printAll(database);
        else if (command == "printprobes")  printProbes(database, name);
        else if (command == "removeall")    removeAll(database);
        else if (command == "countactive")  countActive(database);
        else if (command == "updatestatus") updateStatus(database, name, status);
        else if (command == "q" || command == "quit" || command == "exit") {
            removeAll(database);
            break;
        }
    }
    return 0;
}

// Helper function implementation
// A) ABSTRACTION LEVEL A: Commands
//    A.1) Command 1: insert
void insert(TreeDB & database, const string & name, const unsigned int & IPaddress, const bool & status) {
    DBentry* newEntry = new DBentry(name, IPaddress, status);
    if (database.insert(newEntry)) printErrSuccess();
    else {
        delete newEntry;
        printErrObjectExists();
    }
}
//    A.2) Command 2: find
void find(TreeDB & database, const string & name) {
    if (database.find(name) != nullptr) cout << *(database.find(name));
    else printErrObjectDNE();
}
//    A.3) Command 3: remove
void remove(TreeDB & database, const string & name) {
    if (database.remove(name)) printErrSuccess();
    else printErrObjectDNE();
}
//    A.4) Command 4: printall
void printAll(TreeDB & database) {
    cout << database.getRoot();
}
//    A.5) Command 5: printprobes
void printProbes(TreeDB & database, const string & name) {
    if (database.find(name) != nullptr) database.printProbes();
    else printErrObjectDNE();
}
//    A.6) Command 6: removeall
void removeAll(TreeDB & database) {
    database.clear();
    printErrSuccess();
}
//    A.7) Command 7: countactive
void countActive(TreeDB & database) {
    database.countActive();
}
//    A.8) Command 8: updatestatus
void updateStatus(TreeDB & database, const string & name, const bool & status) {
    if (database.find(name) != nullptr) {
        database.find(name)->setActive(status);
        printErrSuccess();
    }
    else printErrObjectDNE();
}

// B) ABSTRACTION LEVEL B: Print output
//    B.1) Error message: entry already exists
void printErrObjectExists() {
    cout << "Error: entry already exists" << endl;
}
//    B.2) Error message: entry does not exist
void printErrObjectDNE() {
    cout << "Error: entry does not exist" << endl;
}
//    B.3) Error message: success
void printErrSuccess() {
    cout << "Success" << endl;
}

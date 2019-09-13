//
//  main.cpp skeleton
//  lab3
//
//  Created by Tarek Abdelrahman on 2018-08-25.
//  Copyright © 2018 Tarek Abdelrahman. All rights reserved.
//

#include <iostream>
#include <sstream>
#include <string>

using namespace std;

#include "globals.h"
#include "shape.h"

// This is the shape array, to be dynamically allocated
shape** shapesArray;

// The number of shapes in the database, to be incremented 
// every time a shape is successfully created
int shapeCount = 0;

// The value of the argument to the max_shapes command
int max_shapes;

// Output syntax
const string COLON_SPACE = ": ";
const string SPACE = " ";

// ECE244 Student: you may want to add the prototype of
// helper functions you write here
// ABSTRACTION LEVEL A
void maxShapesCommand (const string & arguments);
void createCommand (const string & arguments);
void moveCommand (const string & arguments);
void rotateCommand (const string & arguments);
void drawCommand (const string & arguments);
void deleteCommand (const string & arguments);
// ABSTRACTION LEVEL B
bool assignValue (stringstream & argsStream, int & value);
bool assignName (stringstream & argsStream, string & name, bool & is_all, bool is_new_shape=false);
bool assignType (stringstream & argsStream, string & type);
bool assignPositiveInt (stringstream & argsStream, int & integer);
bool assignAngle (stringstream & argsStream, int & angle);
// ABSTRACTION LEVEL C
bool checkArgError (stringstream & argsStream);
bool checkTooManyArgsError (stringstream & argsStream);
bool checkTooFewArgsError (const stringstream & argsStream);
bool checkCommandError (const string & command);
bool checkNameError (const string & name);
bool checkNameExistsError (const string & name);
bool checkNameNotFoundError (const string & name);
bool checkTypeError (const string & type);
bool checkPositiveIntError (const int & integer);
bool checkAngleError (const int & angle);
bool checkShapeArrayFull ();
// ABSTRACTION LEVEL D
void printErrorMessage(const int & errCode, const string & name="");



int main() {

    string line;
    string command;
    string arguments;

    while (!cin.eof()) {

        cout << "> ";         // Prompt for input
        getline(cin, line);   // Get a line from standard input

        // Put the line in a linestream for parsing
        // Making a new sstream for each line so the flags are cleared
        stringstream lineStream (line);

        // Clear arguments, command extracted from previous line of user-input
        arguments.clear();
        command.clear();

        // Read from string stream into the command
        // The only way this can fail is if the eof is encountered

        // Check for the command and act accordingly
        // ECE244 Student: Insert your code here

        // 1) Extracts and error checks command
        lineStream >> command;
        if (command.empty()) continue;
        else if (checkCommandError(command)) continue;

        // 2) Stores words after the command to be passed to argument helper functions; error checks if empty
        while(!lineStream.eof()) {
            string arg;
            lineStream >> arg;
            // extra end space allows "checkTooFewArgsError" to be placed after argsStream assignment
            if (!arg.empty()) arguments += arg + " ";
        }
        if (arguments.empty()) {
            printErrorMessage(9);   // too few arguments
            continue;
        }

        // 3) Call corresponding command helper function passing in arguments by value
        if (command == keyWordsList[1]) maxShapesCommand(arguments);
        else if (command == keyWordsList[2]) createCommand(arguments);
        else if (command == keyWordsList[3]) moveCommand(arguments);
        else if (command == keyWordsList[4]) rotateCommand(arguments);
        else if (command == keyWordsList[5]) drawCommand(arguments);
        else if (command == keyWordsList[6]) deleteCommand(arguments);
        
    }  // End input loop until EOF.
    
    return 0;
}



// HELPER FUNCTIONS

// ABSTRACTION LEVEL A
// A.1 maxShapesCommand
void maxShapesCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    int value;
    stringstream argsStream (arguments);

    if (!(assignValue (argsStream, value))) return;

    if (checkTooManyArgsError(argsStream)) return;

    // delete shapesArray and its elements from previous instantiations; reset shapeCount
    for (int i=0; i<shapeCount; i++) {
        if (shapesArray[i] != nullptr) {
            delete shapesArray[i];
            shapesArray[i] = nullptr;
        }
    }
    delete shapesArray;
    shapesArray = nullptr;
    shapeCount = 0;

    // Instantiate shapesArray with size of max_shapes; output success
    max_shapes = value;
    shapesArray = new shape* [value];
    cout << "New database: max shapes is " << value << endl;
}

// A.2 createCommand
void createCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    string name, type;
    int loc_1, loc_2, size_1, size_2;
    bool is_all = false;
    bool is_new_shape = true;
    stringstream argsStream (arguments);

    if (!(assignName (argsStream, name, is_all, is_new_shape))) return;
    else if (!(assignType (argsStream, type))) return;
    else if (!(assignPositiveInt (argsStream, loc_1))) return;
    else if (!(assignPositiveInt (argsStream, loc_2))) return;
    else if (!(assignPositiveInt (argsStream, size_1))) return;
    else if (!(assignPositiveInt (argsStream, size_2))) return;

    if (checkTooManyArgsError(argsStream)) return;
    if (checkShapeArrayFull()) return;

    // Instantiate shapesArray with size of max_shapes; increment shapeCount; output success
    shapesArray[shapeCount] = new shape(name, type, loc_1, loc_2, size_1, size_2);
    shapeCount += 1;
    cout << "Created " << name << COLON_SPACE;
    cout << type << SPACE;
    cout << loc_1 << SPACE << loc_2 << SPACE;
    cout << size_1 << SPACE << size_2 << endl;
}

// A.3 moveCommand
void moveCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    string name;
    int loc_1, loc_2;
    bool is_all = false;
    stringstream argsStream (arguments);

    if (!(assignName (argsStream, name, is_all))) return;
    else if (!(assignPositiveInt (argsStream, loc_1))) return;
    else if (!(assignPositiveInt (argsStream, loc_2))) return;

    if (checkTooManyArgsError(argsStream)) return;

    // Move shape name to location defined by loc_1, loc_2; output success
    for (int i=0; i<shapeCount; i++) {
        if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) {
            shapesArray[i]->setXlocation(loc_1);
            shapesArray[i]->setYlocation(loc_2);
        }
    }
    cout << "Moved " << name << " to " << loc_1 << SPACE << loc_2 << endl;
}

// A.4 rotateCommand
void rotateCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    string name;
    int angle;
    bool is_all = false;
    stringstream argsStream (arguments);

    if (!(assignName (argsStream, name, is_all))) return;
    else if (!(assignAngle (argsStream, angle))) return;

    if (checkTooManyArgsError(argsStream)) return;

    // Move shape name to location defined by loc_1, loc_2; output success
    for (int i=0; i<shapeCount; i++) {
        if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) shapesArray[i]->setRotate(angle);
    }
    cout << "Rotated " << name << " by " << angle << " degrees" << endl;
}

// A.5 drawCommand
void drawCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    string name;
    bool is_all = true;
    stringstream argsStream (arguments);

    if (!(assignName (argsStream, name, is_all))) return; // "is_all" is passed by reference

    if (checkTooManyArgsError(argsStream)) return;

    // Draw all shapes if "is_all" while skipping nullptr, else draw shape defined by "name"
    if (is_all) {
        cout << "Drew all shapes" << endl;
        for (int i=0; i<shapeCount; i++) {
            if (shapesArray[i] != nullptr) shapesArray[i]->draw();
        }
    }
    else {
        cout << "Drew " << name << endl;
        for (int i=0; i<shapeCount; i++) {
            if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) shapesArray[i]->draw();
        }
    }
}

// A.6 deleteCommand
void deleteCommand (const string & arguments) {
    // Instantiate variables from arguments (pass by reference); error checks each assignment
    string name;
    bool is_all = true;
    stringstream argsStream (arguments);

    if (!(assignName (argsStream, name, is_all))) return; // "is_all" is passed by reference

    if (checkTooManyArgsError(argsStream)) return;

    // Delete all shapes if "is_all", else delete shape defined by "name"
    if (is_all) {
        cout << "Deleted: all shapes" << endl;
        for (int i=0; i<shapeCount; i++) {
            if (shapesArray[i] != nullptr) {
                delete shapesArray[i];
                shapesArray[i] = nullptr;
            }
        }
    }
    else {
        cout << "Deleted shape " << name << endl;
        for (int i=0; i<shapeCount; i++) {
            if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) {
                delete shapesArray[i];
                shapesArray[i] = nullptr;
            }
        }
    }
}

// ABSTRACTION LEVEL B
// B.1 Assign value
bool assignValue (stringstream & argsStream, int & value) {
    argsStream >> value;
    // Error check
    if (checkTooFewArgsError(argsStream)) return false;
    else if (checkArgError(argsStream)) return false;
    else if (checkPositiveIntError(value)) return false;
    else return true;
}

// B.2 Assign name (does not check if name already exists in shapeArray)
bool assignName (stringstream & argsStream, string & name, bool & is_all, bool is_new_shape) {
    argsStream >> name;
    // Error check
    if (checkTooFewArgsError(argsStream)) return false;
    else if (checkArgError(argsStream)) return false;

    // When drawing or deleting all, allow "name" to take on "all" element in keyWordsList
    if (is_all && (name == "all")) return true;
    else {
        is_all = false; // pass by reference; notifies caller that "name" != "all"
        if (checkNameError(name)) return false;
    }

    // When creating a new shape object, check if name already exists, or else check if name not found in shapesArray
    if (is_new_shape) {
        if (checkNameExistsError(name)) return false;
    }
    else {
        if (checkNameNotFoundError(name)) return false;
    }
    return true;
}

// B.3 Assign type
bool assignType (stringstream & argsStream, string & type) {
    argsStream >> type;
    // Error check
    if (checkTooFewArgsError(argsStream)) return false;
    else if (checkArgError(argsStream)) return false;
    else if (checkTypeError(type)) return false;
    else return true;
}

// B.4 Assign positive int
bool assignPositiveInt (stringstream & argsStream, int & integer) {
    argsStream >> integer;
    // Error check
    if (checkTooFewArgsError(argsStream)) return false;
    else if (checkArgError(argsStream)) return false;
    else if (checkPositiveIntError(integer)) return false;
    else return true;
}

// B.5 Assign angle
bool assignAngle (stringstream & argsStream, int & angle) {
    argsStream >> angle;
    // Error check
    if (checkTooFewArgsError(argsStream)) return false;
    else if (checkArgError(argsStream)) return false;
    else if (checkAngleError(angle)) return false;
    else return true;
}

// ABSTRACTION LEVEL C
// C.1 Error Check Function: checkArgError
bool checkArgError (stringstream & argsStream) {
    if (argsStream.fail() && !argsStream.eof()) {
        printErrorMessage(2);   // invalid argument
        return true;
    }
    else if (argsStream.peek() != ' ') {
        printErrorMessage(2);   // invalid argument since entire word is not read
        return true;
    }
    else return false;
}

// C.2 Error Check Function: checkTooManyArgsError
bool checkTooManyArgsError (stringstream & argsStream) {
    string extraArg;
    argsStream >> extraArg;
    if (!argsStream.eof()) {
        printErrorMessage(8);   // too many arguments
        return true;
    }
    else return false;
}

// C.3 Error Check Function: checkTooFewArgsError
bool checkTooFewArgsError (const stringstream & argsStream) {
    if (argsStream.eof()) {
        printErrorMessage(9);   // too few arguments
        return true;
    }
    else return false;
}

// C.4 Error Check Function: checkCommandError
bool checkCommandError (const string & command) {
    // "auto" auto-deduces variable type (in this case it replaces "string")
    // Compares "command" to each word in keyWordsList
    for (auto & keyWord : keyWordsList) {
        if (command == keyWord) return false;
    }
    printErrorMessage(1);   // invalid command
    return true;
}

// C.5.1 Error Check Function: checkNameError
bool checkNameError (const string & name) {
    // "auto" auto-deduces variable type (in this case it replaces "string")
    // Compares "name" to each word in keyWordsList
    for (auto & keyWord : keyWordsList) {
        if (name == keyWord) {
            printErrorMessage(3);   // invalid shape name
            return true;
        }
    }
    // Compares "name" to each word in shapeTypesList
    for (auto & shapeType : shapeTypesList) {
        if (name == shapeType) {
            printErrorMessage(3);   // invalid shape name
            return true;
        }
    }
    return false;
}
// C.5.2 Error Check Function: checkNameExistsError
bool checkNameExistsError (const string & name) {
    // Compares "name" to each word in shapesArray
    for (int i=0; i<shapeCount; i++) {
        if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) {
            printErrorMessage(4, name);   // shape name exists
            return true;
        }
    }
    return false;
}
// C.5.3 Error Check Function: checkNameNotFoundError
bool checkNameNotFoundError (const string & name) {
    // Compares "name" to each word in shapesArray
    for (int i=0; i<shapeCount; i++) {
        if ((shapesArray[i] != nullptr) && (name == shapesArray[i]->getName())) return false;
    }
    printErrorMessage(5, name);   // shape name not found
    return true;
}

// C.6 Error Check Function: checkTypeError
bool checkTypeError (const string & type) {
    // "auto" auto-deduces variable type (in this case it replaces "string")
    // Compares "type" to each word in shapeTypesList
    for (auto & shapeType : shapeTypesList) {
        if (type == shapeType) return false;
    }
    printErrorMessage(6);   // invalid shape type
    return true;
}

// C.7 Error Check Function: checkPositiveIntError
bool checkPositiveIntError (const int & integer) {
    if (integer < 0) {
        printErrorMessage(7);   // invalid value
        return true;
    }
    else return false;
}

// C.8 Error Check Function: checkAngleError
bool checkAngleError (const int & angle) {
    if (angle < 0 || angle > 360) {
        printErrorMessage(7);   // invalid value
        return true;
    }
    else return false;
}

// C.9 Error Check Function: checkShapeArrayFull
bool checkShapeArrayFull () {
    if (shapeCount >= max_shapes) {
        printErrorMessage(10);   // shape array is full
        return true;
    }
    else return false;
}


// ABSTRACTION LEVEL D
// D.1 Error function that prints error message corresponding to the error code (range: 1-10)
void printErrorMessage (const int & errCode, const string & name) {
    switch (errCode) {
        case 1 : cout << "Error: invalid command" << endl; break;
        case 2 : cout << "Error: invalid argument" << endl; break;
        case 3 : cout << "Error: invalid shape name" << endl; break;
        case 4 : cout << "Error: shape " << name << " exists" << endl; break;
        case 5 : cout << "Error: shape " << name << " not found" << endl; break;
        case 6 : cout << "Error: invalid shape type" << endl; break;
        case 7 : cout << "Error: invalid value" << endl; break;
        case 8 : cout << "Error: too many arguments" << endl; break;
        case 9 : cout << "Error: too few arguments" << endl; break;
        case 10 : cout << "Error: shape array is full" << endl; break;
        default: return;
    }
}
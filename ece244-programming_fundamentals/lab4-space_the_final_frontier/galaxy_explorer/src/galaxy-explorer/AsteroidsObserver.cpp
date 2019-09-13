/*
 * This file was developed for the Fall 2018 instance of ECE244 at the University of Toronto.
 * Creator: Matthew J. P. Walker
 */

#include <galaxy-explorer/AsteroidsObserver.hpp>

void AsteroidsObserver::onAsteroidInRange(Asteroid asteroid) {
    // Append asteroid to beginning of linked list
    asteroid_list.pushFront(asteroid);
}

void AsteroidsObserver::onAsteroidUpdate(Asteroid asteroid) {
    // 1) Checks if 'asteroid_list' is empty and if true, return
    if (asteroid_list.isEmpty()) return;

    // 2) Delete asteroid with 'asteroidId' from linked list
    // 2.1) Gets 'asteroid' ID
    int asteroidId = asteroid.getID();
    // 2.2) Instantiate two pointers to iterate through linked list
    AsteroidListItem* headPtr = asteroid_list.beforeBegin();
    AsteroidListItem* headPtrLead = asteroid_list.begin();
    // 2.3) Iterates through the linked list until finding the asteroid in the data field of the linked list node with 'asteroidId'
    while (headPtrLead != nullptr && headPtrLead->getData().getID() != asteroidId) {
        headPtr = headPtrLead;
        headPtrLead = headPtrLead->getNext();       // headPtrLead = ptr to 'asteroidId' node
    }
    // 2.4) Delete node with 'asteroidId' by calling 'eraseAfter(AsteroidListItem* prev)'
    asteroid_list.eraseAfter(headPtr);
    
    // 3) Insert 'asteroid' node into location by calling 'insertAfter(AsteroidListItem* prev, Asteroid e)'
    asteroid_list.insertAfter(headPtr, asteroid);
}

void AsteroidsObserver::onAsteroidOutOfRange(Asteroid asteroid) {
    // 1) Checks if 'asteroid_list' is empty and if true, return
    if (asteroid_list.isEmpty()) return;

    // 2) Delete asteroid with 'asteroidId' from linked list
    // 2.1) Gets 'asteroid' ID
    int asteroidId = asteroid.getID();
    // 2.2) Instantiate two pointers to iterate through linked list
    AsteroidListItem* headPtr = asteroid_list.beforeBegin();
    AsteroidListItem* headPtrLead = asteroid_list.begin();
    // 2.3) Iterates through the linked list until finding the asteroid in the data field of the linked list node with 'asteroidId'
    while (headPtrLead != nullptr && headPtrLead->getData().getID() != asteroidId) {
        headPtr = headPtrLead;
        headPtrLead = headPtrLead->getNext();       // headPtrLead = ptr to 'asteroidId' node
    }
    // 2.4) Delete node with 'asteroidId' by calling 'eraseAfter(AsteroidListItem* prev)'
    asteroid_list.eraseAfter(headPtr);
}

void AsteroidsObserver::onAsteroidDestroy(Asteroid asteroid) {
    // 1) Delete asteroid node by calling 'onAsteroidOutOfRange(Asteroid asteroid)'
    if (asteroid_list.isEmpty()) return;
    else onAsteroidOutOfRange(asteroid);
}

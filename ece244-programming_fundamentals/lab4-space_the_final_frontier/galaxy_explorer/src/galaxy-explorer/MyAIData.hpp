/*
 * This file was developed for the Fall 2018 instance of ECE244 at the University of Toronto.
 * Creator: Matthew J. P. Walker
 * Supervised by: Tarek Abdelrahman
 */

#ifndef ECE244_GALAXY_EXPLORER_STUDENT_AI_DATA_HPP
#define ECE244_GALAXY_EXPLORER_STUDENT_AI_DATA_HPP


/**
 * Student editable struct for storing their ai state
 * Yes, you may change this header.
 * Maybe you want to remember the last asteroid Id you shot at?
 */
struct MyAIData {
	bool debug_on = true;
        
        // A) Info of each asteroid in linked list
        int* asteroidIdArr;
        int* angleShipToAsteroidArr;
        float* distanceToShipArr;
        float* minDistanceToShipArr;
        float* distanceThresholdArr;
        bool* isCollideWithShipArr;
        
        // B) Target asteroid
        int targetId;
        int targetAngleShipToAsteroid;
        float targetDistanceToShip;
        float targetMinDistanceToShip;
        bool targetIsCollideWithShip;
        sf::Vector2f targetLocation;
        sf::Vector2i targetVelocity;
        sf::IntRect targetHitbox;
};

#endif /* ECE244_GALAXY_EXPLORER_STUDENT_AI_DATA_HPP */

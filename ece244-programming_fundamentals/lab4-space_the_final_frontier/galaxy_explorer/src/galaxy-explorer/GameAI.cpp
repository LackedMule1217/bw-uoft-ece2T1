#include <galaxy-explorer/GameAI.hpp>
#include <galaxy-explorer/MyAIData.hpp>

#include <SFML/Graphics.hpp>

#include <iostream>
#include <math.h>
using namespace std;

// HELPER FUNCTION PROTOTYPES
// A. ABSTRACTION LEVEL A
void updateMyAIData(AsteroidsObserver & asteroidsObserver, MyAIData* & myGameAi, const ShipState& ship_state);
void clearMyAIData(MyAIData* & myGameAi);
int getMovementAngle(MyAIData* & myGameAi);
// B. ABSTRACTION LEVEL B
float getMinDistance (const sf::IntRect shipHitbox, const sf::IntRect asteroidHitbox, const sf::Vector2f asteroidVelocityVec);
// C. ABSTRACTION LEVEL C
sf::Vector2f getVecProjection (const sf::Vector2f a, const sf::Vector2f b);
int getAngleShipToAsteroid (const sf::IntRect ship, const sf::IntRect asteroid);
// D. ABSTRACTION LEVEL D
int modulo (const int a, const int b);
sf::Vector2f getCentroid (const sf::IntRect a);
float getDistanceBetweenCentroids (const sf::IntRect a, const sf::IntRect b);
float getVecMagnitude (const sf::Vector2f a);
float getDistanceThreshold (const sf::IntRect ship, const sf::IntRect asteroid);
bool getIsCollideWithShip (const float minDistance, const float distanceThreshold);
float getDegFromRad(const float rad);
float getRadFromDeg(const float deg);

// Global variables
int wobbleDegreeCnt = 0;
int wobbleDegreeCntInc = true;
bool isCenterShip = false;

// HELPER FUNCTIONS
int counter = 0;
// A. ABSTRACTION LEVEL A
//    A.1 Update struct MyAIData
void updateMyAIData(AsteroidsObserver & asteroidsObserver,
        MyAIData* & myGameAi,
        const ShipState& ship_state) {
    //    1) Obtain size of asteroids list and instantiate struct MyAIData variables
    int listSize = asteroidsObserver.asteroids().size();
    myGameAi->asteroidIdArr = new int[listSize];
    myGameAi->angleShipToAsteroidArr = new int[listSize];
    myGameAi->distanceToShipArr = new float[listSize];
    myGameAi->minDistanceToShipArr = new float[listSize];
    myGameAi->distanceThresholdArr = new float[listSize];
    myGameAi->isCollideWithShipArr = new bool[listSize];
    //    2) Iterate through asteroids list and import info to struct MyAIData
    //       2.1) Instantiate variables
    int index = 0;
    int tempTargetId;
    int tempAngleShipToAsteroid;
    float tempDistanceToShip = -1;
    float tempMinDistanceToShip = -1;
    bool tempIsCollideWithShip;
    bool isPrevTargetExists = false;
    sf::Vector2f tempTargetLocation;
    sf::Vector2i tempTargetVelocity;
    sf::IntRect tempTargetHitbox;
    AsteroidListItem* headPtr = asteroidsObserver.asteroids().begin();
    //       2.2) Iterate through asteroid linked list to update 'struct MyAIData'
    while (headPtr != nullptr) {
        //        2.2.1) Update 'A) Info of each asteroid in linked list'
        myGameAi->asteroidIdArr[index] = headPtr->getData().getID();
        myGameAi->angleShipToAsteroidArr[index] = getAngleShipToAsteroid(ship_state.hitbox,
                headPtr->getData().getCurrentHitbox());
        myGameAi->distanceToShipArr[index] = getDistanceBetweenCentroids(ship_state.hitbox,
                headPtr->getData().getCurrentHitbox());
        myGameAi->minDistanceToShipArr[index] = getMinDistance(ship_state.hitbox,
                headPtr->getData().getCurrentHitbox(),
                (sf::Vector2f)headPtr->getData().getVelocity());
        myGameAi->distanceThresholdArr[index] = getDistanceThreshold(ship_state.hitbox,
                headPtr->getData().getCurrentHitbox());
        myGameAi->isCollideWithShipArr[index] = getIsCollideWithShip(myGameAi->minDistanceToShipArr[index],
                myGameAi->distanceThresholdArr[index]);
        //        2.2.2) Update temp for 'B) Target asteroid' by targeting an asteroid that will be the closest to the ship will collide
        if (myGameAi->isCollideWithShipArr[index] == true &&
                (myGameAi->distanceToShipArr[index] < tempDistanceToShip || tempDistanceToShip == -1)) {
            tempTargetId = myGameAi->asteroidIdArr[index];
            tempAngleShipToAsteroid = myGameAi->angleShipToAsteroidArr[index];
            tempDistanceToShip = myGameAi->distanceToShipArr[index];
            tempMinDistanceToShip = myGameAi->minDistanceToShipArr[index];
            tempIsCollideWithShip = myGameAi->isCollideWithShipArr[index];
            tempTargetLocation = getCentroid(headPtr->getData().getCurrentHitbox());
            tempTargetVelocity = headPtr->getData().getVelocity();
            tempTargetHitbox = headPtr->getData().getCurrentHitbox();
        }
        //        2.2.3) If asteroidId in list == targetId, set 'isPrevTargetExists' to true only if asteroid collides with ship
        /*if (myGameAi->targetId == headPtr->getData().getID() && myGameAi->targetIsCollideWithShip) {
            isPrevTargetExists = true;
            myGameAi->targetDistanceToShip = myGameAi->distanceToShipArr[index];
            myGameAi->targetLocation = getCentroid(headPtr->getData().getCurrentHitbox());
            myGameAi->targetHitbox = headPtr->getData().getCurrentHitbox();
        }*/
        //        2.2.4) Increment for next while loop iteration
        headPtr = headPtr->getNext();
        index++;
    }
    //    3) Target asteroid
    //       3.1) If 'isPrevTargetExists', then return since we want to destroy the target before moving on to another one
    if (isPrevTargetExists) return;
    //       3.2) If no asteroids are to collide with ship, target asteroid closest to ship in terms of angle
    if (tempDistanceToShip == -1) {
        //   3.3) Iterate through 'angleShipToAsteroid' to find angle closest with ship's angle
        //        3.3.1) Find index in 'asteroidIdArr' that corresponds to closest angle with ship
        int tempIndex, tempAngleDiff = -1;
        for (index = 0; index < listSize; index++) {
            if (tempAngleDiff == -1) {
                tempIndex = index;
                tempAngleDiff = abs(ship_state.millidegree_rotation - myGameAi->angleShipToAsteroidArr[index]);
            }
            else if (tempAngleDiff > abs(ship_state.millidegree_rotation - myGameAi->angleShipToAsteroidArr[index])) {
                tempIndex = index;
                tempAngleDiff = abs(ship_state.millidegree_rotation - myGameAi->angleShipToAsteroidArr[index]);
            }
        }
        //        3.3.2) If asteroid angle is <= 290 or >= 70 degree, then center the ship instead to 0 degree
        if (myGameAi->angleShipToAsteroidArr[tempIndex] <= 290000 || myGameAi->angleShipToAsteroidArr[tempIndex] >= 70000){
            isCenterShip = true;
            tempAngleShipToAsteroid = 0;
        } else if (isCenterShip) {
            tempAngleShipToAsteroid = 0;
            if (myGameAi->angleShipToAsteroidArr[tempIndex] >= 350000 || myGameAi->angleShipToAsteroidArr[tempIndex] <= 10000)
                isCenterShip = false;
        }
        //        3.3.3) Assign target asteroid info to temp variables
        else tempAngleShipToAsteroid = myGameAi->angleShipToAsteroidArr[tempIndex];
        headPtr = asteroidsObserver.asteroids().begin();
        tempTargetId = myGameAi->asteroidIdArr[tempIndex];
        tempDistanceToShip = myGameAi->distanceToShipArr[tempIndex];
        tempMinDistanceToShip = myGameAi->minDistanceToShipArr[tempIndex];
        tempIsCollideWithShip = myGameAi->isCollideWithShipArr[tempIndex];
        while (headPtr != nullptr) {
            if (headPtr->getData().getID() == tempTargetId) {
                tempTargetLocation = getCentroid(headPtr->getData().getCurrentHitbox());
                tempTargetVelocity = headPtr->getData().getVelocity();
                tempTargetHitbox = headPtr->getData().getCurrentHitbox();
            }
            headPtr = headPtr->getNext();
        }
    }
    else isCenterShip = false;
    //       3.3) Update 'B) Target asteroid'
    myGameAi->targetId = tempTargetId;
    myGameAi->targetAngleShipToAsteroid = tempAngleShipToAsteroid;
    myGameAi->targetDistanceToShip = tempDistanceToShip;
    myGameAi->targetMinDistanceToShip = tempMinDistanceToShip;
    myGameAi->targetIsCollideWithShip = tempIsCollideWithShip;
    myGameAi->targetLocation = tempTargetLocation;
    myGameAi->targetVelocity = tempTargetVelocity;
    myGameAi->targetHitbox = tempTargetHitbox;
}
//    A.2 Clear and delete struct MyAIData except 'A) Target asteroid' section
void clearMyAIData(MyAIData* & myGameAi) {
    //    1) Delete dynamically-allocated contents
    delete myGameAi->asteroidIdArr;
    delete myGameAi->angleShipToAsteroidArr;
    delete myGameAi->distanceToShipArr;
    delete myGameAi->minDistanceToShipArr;
    delete myGameAi->distanceThresholdArr;
    delete myGameAi->isCollideWithShipArr;
    //    2) Set to nullptr
    myGameAi->asteroidIdArr = nullptr;
    myGameAi->angleShipToAsteroidArr = nullptr;
    myGameAi->distanceToShipArr = nullptr;
    myGameAi->minDistanceToShipArr = nullptr;
    myGameAi->distanceThresholdArr = nullptr;
    myGameAi->isCollideWithShipArr = nullptr;
}
//    A.3 Calculates the what angle the ship required to destroy an asteroid
int getMovementAngle(MyAIData* & myGameAi) {
    // 1) Obtain angle from asteroid to ship
    //int asteroidShipAngle = getAngleShipToAsteroid (ship_state.hitbox, myGameAi->targetHitbox);
    int asteroidShipAngle = myGameAi->targetAngleShipToAsteroid;
    // 2) Check if asteroid will collide with ship
    int wobbleDegree;
    if (myGameAi->targetIsCollideWithShip) wobbleDegree = 13;
    else wobbleDegree = 35; // Previous value: 33
    // 3) Apply wobble to angle
    cout << "wobbleDegreeCnt: " << wobbleDegreeCnt << endl;
    cout << "wobbleDegreeCntInc: " << wobbleDegreeCntInc << endl;
    if (wobbleDegreeCntInc && wobbleDegreeCnt <= wobbleDegree)
        return modulo(asteroidShipAngle + 1000 * wobbleDegreeCnt++, 360000);
    else if (!wobbleDegreeCntInc && wobbleDegreeCnt >= -wobbleDegree)
        return modulo(asteroidShipAngle + 1000 * wobbleDegreeCnt--, 360000);
    else {
        wobbleDegreeCntInc = !wobbleDegreeCntInc;
        return modulo(asteroidShipAngle + 1000 * wobbleDegreeCnt, 360000);
    }
}
// B. ABSTRACTION LEVEL B
//    B.1 Minimum distance between the ship and an asteroid
float getMinDistance (const sf::IntRect shipHitbox,
        const sf::IntRect asteroidHitbox,
        const sf::Vector2f asteroidVelocityVec) {
    // 1) Instantiate variables
    sf::Vector2f shipCentroid = getCentroid(shipHitbox);
    sf::Vector2f asteroidCentroid = getCentroid(asteroidHitbox);
    sf::Vector2f asteroidShipVec = shipCentroid - asteroidCentroid;
    // 2) Project asteroidShipVec onto asteroidVelocityVec
    sf::Vector2f projectShipVecToVelocityVec = getVecProjection(asteroidShipVec, asteroidVelocityVec);
    // 3) Find minimum distance through the magnitude of the orthogonal projection
    return getVecMagnitude(asteroidShipVec - projectShipVecToVelocityVec);
}
// C. ABSTRACTION LEVEL C
//    C.1 Projection of 2D vector 'a' onto 2D vector 'b'
sf::Vector2f getVecProjection (const sf::Vector2f a, const sf::Vector2f b) {
    float dotProduct = (a.x * b.x) + (a.y * b.y);
    float projectionScalar = dotProduct / pow(getVecMagnitude(b), 2);
    sf::Vector2f projectionResult;
    projectionResult.x = projectionScalar * b.x;
    projectionResult.y = projectionScalar * b.y;
    return projectionResult;
}
//    C.2 Angle between centroids of ship and asteroid
int getAngleShipToAsteroid (const sf::IntRect ship, const sf::IntRect asteroid) {
    // 1) Instantiate variables
    float xDistance = (ship.left + ship.width/2) - (asteroid.left + asteroid.width/2);
    float yDistance = (ship.top + ship.height/2) - (asteroid.top + asteroid.height/2);
    float xDistanceAbs = abs(xDistance);
    float yDistanceAbs = abs(yDistance);
    // 2) Calculate acute angle angle
    float angleRad = atan(yDistanceAbs / xDistanceAbs) * 1000;
    int angleDeg = (int)(getDegFromRad(angleRad));
    // 3) Transform angle to range from 0 to 359999 degrees
    //    3.1) Quadrant I
    if (xDistance <= 0 && yDistance >= 0) angleDeg = modulo(-angleDeg, 90000);
    //    3.2) Quadrant II
    else if (xDistance >= 0 && yDistance >= 0) angleDeg = angleDeg + 270000;
    //    3.3) Quadrant III
    else if (xDistance >= 0 && yDistance <= 0) angleDeg = modulo(-angleDeg, 270000);
    //    3.4) Quadrant IV (xDistance <= 0 && yDistance <= 0)
    else angleDeg = angleDeg + 90000;
    return angleDeg;
}
// D. ABSTRACTION LEVEL D
//    D.1 Modulo
int modulo (const int a, const int b) {
    return (b + (a % b)) % b;
}
//    D.2 Centroid of an IntRect Object
sf::Vector2f getCentroid (const sf::IntRect a) {
    return sf::Vector2f (a.left + a.width/2, a.top + a.height/2);
}
//    D.3 Distance between the centroid of two IntRect objects
float getDistanceBetweenCentroids (const sf::IntRect a, const sf::IntRect b) {
    float xDistance = abs((a.left + a.width/2) - (b.left + b.width/2));
    float yDistance = abs((a.top + a.height/2) - (b.top + b.height/2));
    return sqrt(pow(xDistance, 2) + pow(yDistance, 2));
}
//    D.4 Magnitude of a 2D vector
float getVecMagnitude (const sf::Vector2f a) {
    return sqrt(pow(a.x, 2) + pow(a.y, 2));
}
//    D.5 Max distance from ship to asteroid for collision
float getDistanceThreshold (const sf::IntRect ship, const sf::IntRect asteroid) {
    float shipHitboxDiagonal = sqrt(pow(ship.width, 2) + pow(ship.height, 2));
    float asteroidHitboxDiagonal = sqrt(pow(asteroid.width, 2) + pow(asteroid.height, 2));
    return (shipHitboxDiagonal + asteroidHitboxDiagonal) / 2;
}
//    D.6 Will the asteroid collide with the ship
bool getIsCollideWithShip (const float minDistance, const float distanceThreshold) {
    return minDistance <= distanceThreshold;
}
//    D.7.1 Convert from degree to radian
float getDegFromRad(const float rad) {
    return rad * (180 / M_PI);
}
//    D.7.1 Convert from radian to degree
float getRadFromDeg(const float deg) {
    return deg * (M_PI / 180);
}


GameAI::GameAI(const GameInfo& game_info, sf::RenderTarget* debug_rt) {
    this->debug_rt = debug_rt;
    this->game_info = game_info;
    this->asteroid_observer = AsteroidsObserver(this);
    this->my_game_ai = new MyAIData();

    // customState().debug_on = false;

    // TODO: GameInfo Data (cout)
    cout << "screen bound (height): " << game_info.field_shape.height << endl;
    cout << "screen bound (left): " << game_info.field_shape.left << endl;
    cout << "screen bound (top): " << game_info.field_shape.top << endl;
    cout << "screen bound (width): " << game_info.field_shape.width << endl;
    cout << "phase hitbox size (x): " << game_info.phaser_pulse_hitbox_size.x << endl;
    cout << "phase hitbox size (): " << game_info.phaser_pulse_hitbox_size.x << endl;
    cout << "phase pulse speed: " << game_info.phaser_pulse_speed << endl;
    cout << "ship rotation speed: " << game_info.ship_rotation_speed_millidegrees_per_frame << endl;
}

GameAI::~GameAI() {
    delete my_game_ai;
}

SuggestedAction GameAI::suggestAction(const ShipState& ship_state) {
    debug_rt->clear(sf::Color::Transparent);
    if (customState().debug_on) {
        if (not asteroidsObserver().asteroids().isEmpty()) {
            const sf::IntRect first_ast_hb = my_game_ai->targetHitbox;
            sf::RectangleShape ast_rect(sf::Vector2f(first_ast_hb.width, first_ast_hb.height));
            ast_rect.setPosition(first_ast_hb.left, first_ast_hb.top);
            ast_rect.setOutlineThickness(33.0f); // if lines are too thin, they won't show up sometimes
            ast_rect.setOutlineColor(sf::Color::Yellow);
            ast_rect.setFillColor(sf::Color::Transparent);
            debug_rt->draw(ast_rect);
        }
    }
    
    // 0) PRINTING INFO
    counter++;
    // 0.1) Print info of the front asteroid in linked list
    cout << counter << "----------------------ASTEROID----------------------" << counter << endl;
    if (not asteroidsObserver().asteroids().isEmpty()) {
        //cout << "id: " << asteroidsObserver().asteroids().front().getID() << endl;
        //cout << "hitbox (height): " << asteroidsObserver().asteroids().front().getCurrentHitbox().height << endl;
        //cout << "hitbox (left): " << asteroidsObserver().asteroids().front().getCurrentHitbox().left << endl;
        //cout << "hitbox (top): " << asteroidsObserver().asteroids().front().getCurrentHitbox().top << endl;
        //cout << "hitbox (width): " << asteroidsObserver().asteroids().front().getCurrentHitbox().width << endl;
        //cout << "hitbox centroid (x): " << getCentroid(asteroidsObserver().asteroids().front().getCurrentHitbox()).x << endl;
        //cout << "hitbox centroid (y): " << getCentroid(asteroidsObserver().asteroids().front().getCurrentHitbox()).y << endl;
        //cout << "health: " << asteroidsObserver().asteroids().front().getHealth() << endl;
        //cout << "mass: " << asteroidsObserver().asteroids().front().getMass() << endl;
        cout << "velocity <x, y>: <" << asteroidsObserver().asteroids().front().getVelocity().x << " ," 
                << asteroidsObserver().asteroids().front().getVelocity().y << ">" << endl;
    }
    cout << "size of asteroid list: " << asteroidsObserver().asteroids().size() << endl;
    // 0.2) Print info of ship status
    //cout << counter << "----------------------SHIP----------------------" << counter << endl;
    //cout << "fire request: " << ship_state.fire_phaser_requested << endl;
    //cout << "frames until phaser ready: " << ship_state.frames_until_phaser_is_ready << endl;
    //cout << "score: " << ship_state.score << endl;;
    //cout << "millidegree rotation: " << ship_state.millidegree_rotation << endl;
    //cout << "ship hitbox (height): " << ship_state.hitbox.height << endl;
    //cout << "ship hitbox (left): " << ship_state.hitbox.left << endl;
    //cout << "ship hitbox (top): " << ship_state.hitbox.top << endl;
    //cout << "ship hitbox (width): " << ship_state.hitbox.width << endl;
    //cout << "ship centroid (x): " << getCentroid(ship_state.hitbox).x << endl;
    //cout << "ship centroid (y): " << getCentroid(ship_state.hitbox).y << endl;
    // 0.3) Print other info
    //cout << counter << "----------------------OTHER----------------------" << counter << endl;
    if (not asteroidsObserver().asteroids().isEmpty()) {
        /*cout << "distance of ship to front asteroid: "
                << getDistanceBetweenCentroids(ship_state.hitbox, asteroidsObserver().asteroids().front().getCurrentHitbox())
                << endl;*/
    }
    
    
    // Declare variables to store useful info
    int shipRotation = modulo(ship_state.millidegree_rotation, 360000);
    int fireAngle;
    bool rotateCW;
    // A) TARGETING SYSTEM
    cout << counter << "----------------------TARGETING SYSTEM----------------------" << counter << endl;
    if (not asteroidsObserver().asteroids().isEmpty()) {
        updateMyAIData(asteroid_observer, my_game_ai, ship_state);
        for (int i = 0; i < asteroid_observer.asteroids().size(); i++) {
            //cout << "struct MyAIData (asteroidIdArr[" << i << "]): " << my_game_ai->asteroidIdArr[i] << endl;
            //cout << "struct MyAIData (angleShipToAsteroid[" << i << "]): " << my_game_ai->angleShipToAsteroid[i] << endl;
            //cout << "struct MyAIData (distanceToShipArr[" << i << "]): " << my_game_ai->distanceToShipArr[i] << endl;
            //cout << "struct MyAIData (minDistanceToShipArr[" << i << "]): " << my_game_ai->minDistanceToShipArr[i] << endl;
            //cout << "struct MyAIData (distanceThreshold[" << i << "]): " << my_game_ai->distanceThresholdArr[i] << endl;
            //cout << "struct MyAIData (isCollideWithShip[" << i << "]): " << my_game_ai->isCollideWithShipArr[i] << endl;
        }
        //cout << "struct MyAIData (targetId): " << my_game_ai->targetId << endl;
        /*cout << "struct MyAIData (targetDistanceToShip): " << my_game_ai->targetDistanceToShip << endl;
        cout << "struct MyAIData (targetMinDistanceToShip): " << my_game_ai->targetMinDistanceToShip << endl;
        cout << "struct MyAIData (targetLocation <x, y>): <" << my_game_ai->targetLocation.x << ", " 
               << my_game_ai->targetLocation.y << ">" << endl;
        cout << "struct MyAIData (targetVelocity <x, y>): <" << my_game_ai->targetVelocity.x << ", " 
               << my_game_ai->targetVelocity.y << ">" << endl;*/
    }
    // B) TRACKING SYSTEM
    cout << counter << "----------------------TRACKING SYSTEM----------------------" << counter << endl;
    if (not asteroidsObserver().asteroids().isEmpty()) {
        fireAngle = getMovementAngle(my_game_ai);
        //cout << "Fire Angle: " << fireAngle << endl;
        //cout << "shipRotation: " << shipRotation << endl;
    }
    // C) Free memory from dynamically allocated variables within 'struct MyAIData'
    clearMyAIData(my_game_ai);
    // D) Instruct ship to rotate and fire
    //    1) Determine rotation direction
    if (abs(shipRotation - fireAngle) < ((shipRotation > fireAngle) ? (360000 - shipRotation + fireAngle) : (360000 - fireAngle + shipRotation))) {
        if (shipRotation > fireAngle) rotateCW = false;
        else rotateCW = true;
    }
    else {
        if (shipRotation > fireAngle) rotateCW = true;
        else rotateCW = false;
    }
    //cout << "rotateCW: " << rotateCW << endl;
    //    2) Instruct ship to rotate / fire
    if (rotateCW) {
        return SuggestedAction{SuggestedAction::YawingClockwise, SuggestedAction::FiringTry};
    }
    else {
        return SuggestedAction{SuggestedAction::YawingAntiClockwise, SuggestedAction::FiringTry};
    }
}

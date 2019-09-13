#include <galaxy-explorer/AsteroidList.hpp>


AsteroidListItem::AsteroidListItem() {
	this->next = nullptr;
	this->data = nullptr;
}

AsteroidListItem::AsteroidListItem(Asteroid a) {
	this->next = nullptr;
	this->data = new Asteroid(a.getID(), a.getMass(), a.getHealth(), a.getCurrentHitbox(), a.getVelocity());
}

AsteroidListItem::~AsteroidListItem() {
}

AsteroidList::AsteroidList()
{
}

AsteroidList::AsteroidList(const AsteroidList& src)
{
    // The functions in this class are listed in a suggested order of implementation,
    // except for this one and the destructor (because you should put all your constructors together).
    // 1) Checks if 'src' is empty
    if (src.isEmpty()) return;

    // 2) Copy 'src' contents to new object using 3 pointers
    const AsteroidListItem* srcPtr = src.head.getNext();
    AsteroidListItem* headPtr = this->beforeBegin();
    AsteroidListItem* tempPtr;
    // Iterates through the linked list until reaches NULL
    while (srcPtr != nullptr) {
        tempPtr = new AsteroidListItem(srcPtr->getData());
        headPtr->setNext(tempPtr);
        headPtr = headPtr->getNext();
        srcPtr = srcPtr->getNext();
    }
}

AsteroidList::~AsteroidList() {
    // The functions in this class are listed in a suggested order of implementation,
    // except for this one and the copy constructor (because you should put all your constructors together).
}

void AsteroidList::pushFront(Asteroid e) {
    // Create a new node with Asteroid e as its data
    AsteroidListItem* tempNode = new AsteroidListItem(e);

    tempNode->setNext(head.getNext());
    head.setNext(tempNode);
}

Asteroid& AsteroidList::front() {
    // Check if list is empty
    if (!this->isEmpty()) return head.getNext()->getData();
    else return *(Asteroid*)nullptr;
}

const Asteroid& AsteroidList::front() const {
    // Check if list is empty
    if (!this->isEmpty()) return head.getNext()->getData();
    else return *(const Asteroid*)nullptr;
}

bool AsteroidList::isEmpty() const {
    if (head.getNext() == nullptr) return true;
    else return false;
}

int AsteroidList::size() const {
    const AsteroidListItem* tempAsteroidListItem = head.getNext();
    int counter = 0;
    // Iterates through the linked list until reaches NULL
    while (tempAsteroidListItem != nullptr) {
        tempAsteroidListItem = tempAsteroidListItem->getNext();
        counter++;
    }
    return counter;
}

AsteroidListItem* AsteroidList::beforeBegin() {
    return &head;
}

const AsteroidListItem* AsteroidList::beforeBegin() const {
    return &head;
}

AsteroidListItem* AsteroidList::begin() {
    // Check if list is empty
    if (!this->isEmpty()) return head.getNext();
    else return &head;
}

const AsteroidListItem* AsteroidList::begin() const {
    // Check if list is empty
    if (!this->isEmpty()) return head.getNext();
    else return &head;
}

AsteroidListItem* AsteroidList::beforeEnd() {
    // Check if list is empty
    if (!this->isEmpty()) {
        AsteroidListItem* tempPtr = head.getNext();
        // Iterates through the linked list until reaches the node before NULL
        while (tempPtr->hasNext()) tempPtr = tempPtr->getNext();
        return tempPtr;
    }
    else return this->beforeBegin();
}

const AsteroidListItem* AsteroidList::beforeEnd() const {
    // Check if list is empty
    if (!this->isEmpty()) {
        const AsteroidListItem* tempPtr = head.getNext();
        // Iterates through the linked list until reaches the node before NULL
        while (tempPtr->hasNext()) tempPtr = tempPtr->getNext();
        return tempPtr;
    }
    else return this->beforeBegin();
}

AsteroidListItem* AsteroidList::end() {
    if (!this->isEmpty()) return nullptr;
    else return this->begin();
}

const AsteroidListItem* AsteroidList::end() const {
    if (!this->isEmpty()) return nullptr;
    else return this->begin();
}

AsteroidListItem* AsteroidList::insertAfter(AsteroidListItem* prev, Asteroid e) {
    AsteroidListItem* headPtr = this->beforeBegin();

    // 1) Iterates through the linked list until reaching 'prev'
    while (headPtr != prev && headPtr != nullptr) {
        headPtr = headPtr->getNext();
    }

    // 2) Check if 'prev' is not found in list
    if (headPtr == nullptr) return nullptr;

    // 3) Insert node after prev and stitch up the new linked list
    AsteroidListItem* tempNode = new AsteroidListItem(e);       // creates a new node with Asteroid e as its data
    tempNode->setNext(headPtr->getNext());
    headPtr->setNext(tempNode);

    return tempNode;
}

AsteroidListItem* AsteroidList::insertAfter(AsteroidListItem* prev, const AsteroidList& others) {
    AsteroidListItem* headPtr = this->beforeBegin();

    // 1) Iterates through the linked list until reaching 'prev'
    while (headPtr != prev && headPtr != nullptr) {
        headPtr = headPtr->getNext();
    }

    // 2) Check if 'prev' is not found in list
    if (headPtr == nullptr) return nullptr;

    // 3) Check if 'others' is empty and if true, return <insertion_point>
    if (others.isEmpty()) return headPtr;

    // 4) Insert node after prev and stitch up the new linked list
    // 4.1 Create new linked list as a copy of 'others'
    AsteroidList* othersCpy = new AsteroidList(others);
    // 4.2 Insert 'othersCpy' into linked list
    AsteroidListItem* othersCpyPtr = othersCpy->head.getNext();
    while (othersCpyPtr->hasNext()) othersCpyPtr = othersCpyPtr->getNext();
    othersCpyPtr->setNext(headPtr->getNext());
    headPtr->setNext(othersCpy->head.getNext());
    // 4.3 Delete head of 'othersCpy'
    delete &(othersCpy->head);

    return othersCpyPtr;
}

AsteroidListItem* AsteroidList::eraseAfter(AsteroidListItem* prev) {
    AsteroidListItem* headPtr = this->beforeBegin();
    AsteroidListItem* headPtrLead = head.getNext();

    // 1) Check if list is empty
    if (this->isEmpty()) return this->end();

    // 2) Iterates through the linked list until reaching 'prev'
    while (headPtr != prev && headPtrLead != nullptr) {
        headPtr = headPtrLead;
        headPtrLead = headPtrLead->getNext();
    }

    // 3) Check if 'prev' is not found in list
    if (headPtrLead == nullptr) return this->end();

    // 4) Delete the node after 'prev' using 2 pointers (headPtrLead = ptr to prev node)
    // 4.1) Stitch node after 'prev' with the linked list, excluding the 'prev' node
    headPtr->setNext(headPtrLead->getNext());
    // 4.2) Delete 'prev' node
    delete headPtrLead;

    return headPtr->getNext();
}

void AsteroidList::clear() {
    AsteroidListItem* headPtr = head.getNext();
    AsteroidListItem* headPtrLead = head.getNext();

    // 1) Check if list is empty
    if (this->isEmpty()) return;

    // 2) Delete nodes after prev using 2 pointers
    while (headPtrLead != nullptr) {
        headPtrLead = headPtr->getNext();
        delete headPtr;
        headPtr = headPtrLead;
    }
    
    // 3) Set head.getNext() to nullptr
    head.setNext(nullptr);
}

AsteroidList& AsteroidList::operator=(const AsteroidList& src) {
    // 1) Check if the two linked lists are actually the same list
    if (this == &src) return (*this);

    // 2) Clear current linked list by calling 'clear()'
    this->clear();

    // 3) Iterate through 'src' while appending a copy of a 'src' node to the current linked list
    // 3) Append a copy of 'src' to the current linked list by calling 'insertAfter(AsteroidListItem* insertion_point,
    // const AsteroidList& others)'
    this->insertAfter(&(this->head), src);

    return (*this);
}

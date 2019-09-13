#include <galaxy-explorer/AsteroidList.hpp>


AsteroidListItem::AsteroidListItem() {
	this->next = nullptr;
	this->data = nullptr;
}

AsteroidListItem::AsteroidListItem(Asteroid a) {
	this->next = nullptr;
	this->data = nullptr;
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
}

AsteroidList::~AsteroidList() {
	// The functions in this class are listed in a suggested order of implementation,
	// except for this one and the copy constructor (because you should put all your constructors together).
}

void AsteroidList::pushFront(Asteroid e) {
}

Asteroid& AsteroidList::front() {
	return *(Asteroid*)nullptr;
}

const Asteroid& AsteroidList::front() const {
	return *(const Asteroid*)nullptr;
}

bool AsteroidList::isEmpty() const {
	return true;
}

int AsteroidList::size() const {
	return 0;
}

AsteroidListItem* AsteroidList::beforeBegin() {
	return nullptr;
}

const AsteroidListItem* AsteroidList::beforeBegin() const {
	return nullptr;
}

AsteroidListItem* AsteroidList::begin() {
	return nullptr;
}

const AsteroidListItem* AsteroidList::begin() const {
	return nullptr;
}

AsteroidListItem* AsteroidList::beforeEnd() {
	return nullptr;
}

const AsteroidListItem* AsteroidList::beforeEnd() const {
	return nullptr;
}

AsteroidListItem* AsteroidList::end() {
	return nullptr;
}

const AsteroidListItem* AsteroidList::end() const {
	return nullptr;
}

AsteroidListItem* AsteroidList::insertAfter(AsteroidListItem* prev, Asteroid e) {
	return nullptr;
}

AsteroidListItem* AsteroidList::insertAfter(AsteroidListItem* prev, const AsteroidList& others) {
	return nullptr;
}

AsteroidListItem* AsteroidList::eraseAfter(AsteroidListItem* prev) {
	return nullptr;
}

void AsteroidList::clear() {
}

AsteroidList& AsteroidList::operator=(const AsteroidList& src) {
	return *(AsteroidList*)nullptr;
}

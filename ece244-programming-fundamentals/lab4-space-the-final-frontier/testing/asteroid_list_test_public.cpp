#include <galaxy-explorer/AsteroidList.hpp>

#include <common/catch.hpp> // should be last

namespace {
	const Asteroid asteroid1 = Asteroid({1111}, 100, 1, {1,1,1,1}, {1,1});
	const Asteroid asteroid2 = Asteroid({2222}, 200, 2, {2,2,1,1}, {2,2});
	const Asteroid asteroid3 = Asteroid({3333}, 300, 3, {3,3,1,1}, {3,3});
	const Asteroid asteroid4 = Asteroid({4444}, 400, 4, {4,4,1,1}, {4,4});
	const Asteroid asteroid5 = Asteroid({5555}, 500, 5, {5,5,1,1}, {5,5});
}

SCENARIO ("Basic Invariants", "[public][functionality][asteroid-list]") {
	GIVEN ("a empty list") {
		AsteroidList alist;

		THEN ("the list should be empty") {
			REQUIRE(alist.begin() == alist.end());
			REQUIRE(alist.size() == 0);
		}
	}
}

SCENARIO ("Basic Insertion", "[public][functionality][asteroid-list]") {
	GIVEN ("an empty list") {
		AsteroidList alist;

		WHEN ("pushFront()ing an element") {
			alist.pushFront(asteroid3);

			THEN ("the front element should match the pushed-in value") {
				REQUIRE(alist.isEmpty() == false);
				REQUIRE(alist.front().getID() == asteroid3.getID());
			}

			AND_WHEN("pushFront()ing another element") {
				alist.pushFront(asteroid2);

				THEN ("the front element should match the newly pushed-in value") {
					REQUIRE(alist.size() == 2);
					REQUIRE(alist.begin()->getData().getID() == asteroid2.getID());
				}

				AND_WHEN("inserting after the first element") {
					alist.insertAfter(alist.begin(), asteroid1);

					THEN ("the front element should still be the old value") {
						REQUIRE(alist.size() == 3);
						REQUIRE(alist.begin()->getData().getID() == asteroid2.getID());
					}
				}
			}
		}
	}
}

SCENARIO ("Basic Removal", "[public][functionality][asteroid-list]") {
	GIVEN ("a list with two elements") {
		AsteroidList alist;
		alist.pushFront(asteroid2);
		alist.pushFront(asteroid1);

		WHEN("removing the second element") {
			alist.eraseAfter(alist.begin());

			THEN ("the front element should still match the newly pushed-in value") {
				REQUIRE(alist.size() == 1);
				REQUIRE(alist.begin()->getData().getID() == asteroid1.getID());
			}
		}
	}

	GIVEN ("a list with two elements") {
		AsteroidList alist;
		alist.pushFront(asteroid2);
		alist.pushFront(asteroid1);

		WHEN("clearing the list") {
			alist.clear();

			THEN ("the list should be empty") {
				REQUIRE(alist.isEmpty() == true);
			}
		}
	}
}

SCENARIO ("Basic Iteration", "[public][functionality][asteroid-list]") {
	GIVEN ("a list with three elements") {
		AsteroidList alist;
		alist.pushFront(asteroid3);
		alist.pushFront(asteroid2);
		alist.pushFront(asteroid1);

		THEN ("the list should have the three elements") {
			REQUIRE(alist.size() == 3);
			REQUIRE(asteroid1.getID() == alist.begin()->getData().getID());
			REQUIRE(asteroid2.getID() == alist.begin()->getNext()->getData().getID());
			REQUIRE(asteroid3.getID() == alist.begin()->getNext()->getNext()->getData().getID());
			REQUIRE(alist.end() == alist.begin()->getNext()->getNext()->getNext());

			int item_count = 0;
			for (AsteroidListItem* it = alist.beforeBegin(); it != alist.beforeEnd(); it = it->getNext()) { item_count += 1; }
			REQUIRE(item_count == 3);

			AND_WHEN ("inserting while iterating") {
				AsteroidListItem* insertion_point = nullptr;
				for (AsteroidListItem* it = alist.begin(); it != alist.end(); it = it->getNext()) {
					if (it->getData().getID() == asteroid2.getID()) {
						REQUIRE(insertion_point == nullptr);
						insertion_point = alist.insertAfter(it, asteroid4);
					}
				}

				THEN ("the new item should be present in the right place") {
					REQUIRE(alist.size() == 4);
					REQUIRE(asteroid1.getID() == alist.begin()->getData().getID());
					REQUIRE(asteroid2.getID() == alist.begin()->getNext()->getData().getID());
					REQUIRE(asteroid4.getID() == alist.begin()->getNext()->getNext()->getData().getID());
					REQUIRE(asteroid3.getID() == alist.begin()->getNext()->getNext()->getNext()->getData().getID());
					REQUIRE(alist.end() == alist.begin()->getNext()->getNext()->getNext()->getNext());

					REQUIRE(insertion_point == alist.begin()->getNext()->getNext());
				}
			}
		}
	}
}

SCENARIO ("Basic Copying", "[public][functionality][asteroid-list]") {
	GIVEN ("a list with three elements") {
		AsteroidList alist1;
		alist1.pushFront(asteroid3);
		alist1.pushFront(asteroid2);
		alist1.pushFront(asteroid1);

		REQUIRE(alist1.size() == 3); // quick check to make sure the implementation is sane

		WHEN ("making a copy") {
			AsteroidList alist2 = alist1;

			REQUIRE(alist1.size() == alist2.size());

			THEN ("the copy should have the same elements") {
				const AsteroidListItem* it1 = alist1.begin();
				const AsteroidListItem* it2 = alist2.begin();
				for (; it1 != alist1.end() && it2 != alist2.end(); it1 = it1->getNext(), it2 = it2->getNext()) {
					REQUIRE(it1->getData().getID() == it2->getData().getID());
				}
			}
		}
	}

	GIVEN ("a list with three elements") {
		AsteroidList alist1;
		alist1.pushFront(asteroid3);
		alist1.pushFront(asteroid2);
		alist1.pushFront(asteroid1);
		
		REQUIRE(alist1.size() == 3); // quick check to make sure the implementation is sane

		GIVEN ("another list with two elements") {
			AsteroidList alist2;
			alist2.pushFront(asteroid5);
			alist2.pushFront(asteroid4);


			WHEN ("inserting the two element list into the three element one") {
				alist1.insertAfter(alist1.begin()->getNext(), alist2);

				THEN ("the elements should be present in the formerly three element list") {
					REQUIRE(alist1.size() == 5);
					REQUIRE(asteroid1.getID() == alist1.begin()->getData().getID());
					REQUIRE(asteroid2.getID() == alist1.begin()->getNext()->getData().getID());
					REQUIRE(asteroid4.getID() == alist1.begin()->getNext()->getNext()->getData().getID());
					REQUIRE(asteroid5.getID() == alist1.begin()->getNext()->getNext()->getNext()->getData().getID());
					REQUIRE(asteroid3.getID() == alist1.begin()->getNext()->getNext()->getNext()->getNext()->getData().getID());
					REQUIRE(alist1.end() == alist1.begin()->getNext()->getNext()->getNext()->getNext()->getNext());
				}
			}
		}
	}

	GIVEN ("a list with three elements") {
		AsteroidList alist1;
		alist1.pushFront(asteroid3);
		alist1.pushFront(asteroid2);
		alist1.pushFront(asteroid1);

		REQUIRE(alist1.size() == 3); // quick check to make sure the implementation is sane

		GIVEN ("another list with two elements") {
			AsteroidList alist2;
			alist2.pushFront(asteroid5);
			alist2.pushFront(asteroid4);

			WHEN ("assigning the list2 to list1") {
				alist1 = alist2;

				THEN ("the lists should be the same") {
					REQUIRE(alist1.size() == alist2.size());
					REQUIRE(alist1.begin()->getData().getID() == alist2.begin()->getData().getID());
					REQUIRE(alist1.begin()->getNext()->getData().getID() == alist2.begin()->getNext()->getData().getID());
				}
			}
		}
	}
}

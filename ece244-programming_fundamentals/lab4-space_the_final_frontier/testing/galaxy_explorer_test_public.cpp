#include <galaxy-explorer/galaxy_explorer_master.hpp>

#include <common/general_utils.hpp>

#include <vector>

#include <common/catch.hpp> // should be last

SCENARIO ("Public Deterministic Games", "[public][simulation][galaxy-explorer]") {
	auto seeds = {
		// "random" seeds
		123456, 111111, 222222, 333333, 535353, 555444, 444666, 123321, 456654,
		// easy seeds
		100021,
	};

	std::vector<int> scores;

	for (int seed : seeds) {
		GameplayController game(seed, true, true);

		while (game.update() == GameEndCheck::Continue) {
			// spin
		}

		scores.push_back(game.getState().playerState().score);
		print_seed_score(std::cout, seed, scores.back());
	}

	print_score_stats(std::cout, scores);
}

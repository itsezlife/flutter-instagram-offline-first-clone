import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test sponsored posts algorithm', () {
    final posts = <int>[1, 3, 4, 3, 2, 3, 4, 5, 6, 1]; // Your fetched posts
    const numSponsoredPosts = 3; // Number of sponsored posts to insert

    test('sequentially with greedy algorithm', () {
      final effectiveIndexes = calculateEffectiveIndexesSequentially(
        posts.length,
        numSponsoredPosts,
      );

      // Insert sponsored posts at the calculated effective indexes
      for (final index in effectiveIndexes) {
        posts.insert(
          index + 1,
          50,
        ); // Adjust the index as needed based on your list structure
      }
    });

    group('randomly', () {
      test('10 posts', () {
        final posts = [4, 2, 3, 4, 1, 2, 3, 4, 2, 5];
        final effectiveIndexes = calculateEffectiveIndexesRandomly(
          posts.length,
          numSponsoredPosts,
        );

        // Insert sponsored posts at the calculated effective indexes
        for (final index in effectiveIndexes) {
          posts.insert(
            index + 1,
            50,
          ); // Adjust the index as needed based on your list structure
        }
      });
    });
  });
}

List<int> calculateEffectiveIndexesSequentially(
  int postsLength,
  int numSponsoredPosts,
) {
  final effectiveIndexes = <int>[];

  // Calculate the maximum effective index based on posts length
  var maxEffectiveIndex = postsLength - 1;

  // Ensure numSponsoredPosts doesn't exceed maxEffectiveIndex
  final sponsoredPostsNum = min(numSponsoredPosts, maxEffectiveIndex);

  // Generate effective indexes using a greedy algorithm
  for (var i = 0; i < sponsoredPostsNum; i++) {
    // Find the first valid effective index
    var effectiveIndex = 0;
    while (effectiveIndexes.contains(effectiveIndex) ||
        effectiveIndex > maxEffectiveIndex) {
      effectiveIndex++;
    }

    // Add the effective index to the list
    effectiveIndexes.add(effectiveIndex);

    // Update the maximum effective index based on the current effective index
    maxEffectiveIndex = min(maxEffectiveIndex, effectiveIndex + 1);
  }

  return effectiveIndexes;
}

List<int> calculateEffectiveIndexesRandomly(
  int postsLength,
  int numSponsoredPosts,
) {
  final effectiveIndexes = <int>[];
  final possibleIndexes = List<int>.generate(postsLength, (i) => i)..shuffle();

  // Randomize the possible indexes to ensure randomness

  // Iterate over the desired number of sponsored posts
  for (var i = 0; i < numSponsoredPosts; i++) {
    // Find the first valid effective index from the randomized possible indexes
    final effectiveIndex = possibleIndexes.firstWhere(
      (index) => !effectiveIndexes.contains(index),
    );

    // Add the effective index to the list
    effectiveIndexes.add(effectiveIndex);

    // Remove the effective index from the possible indexes to prevent
    // duplicates
    possibleIndexes.remove(effectiveIndex);
  }

  return effectiveIndexes;
}

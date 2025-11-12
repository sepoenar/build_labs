#!/bin/python3

#suits = ['Club', 'Spade', 'Heart', 'Diamond']
#values = ['J', 'Q', 'K', 'A'] + list(range(2, 11))
#deck = []

#for suit in suits:
#    for value in values:
#        deck.append(tuple([suit, value]))

#print(deck)



##############################

import random

colors = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

# Create deck
deck = [(color, card) for color in colors for card in cards]

print(deck)

# Shuffle deck
random.shuffle(deck)

# Print the top 5 cards
for hand in deck[:5]:
    print(f"{hand[0]} of {hand[1]}")
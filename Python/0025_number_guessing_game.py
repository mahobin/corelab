# 0025_number_guessing_game

import random

random.seed(1)
secret = random.randint(1, 100)
lo, hi = 1, 100
while True:
    guess = (lo + hi) // 2
    print("guess", guess)
    if guess == secret:
        print("found it")
        break
    lo, hi = (guess + 1, hi) if guess < secret else (lo, guess - 1)

import guessit
import json, sys

path = sys.argv[1];
guess = guessit.guess_video_info(path, info = ['filename'])

print json.dumps(guess)
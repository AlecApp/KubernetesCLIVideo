#A fun little Python script that spits out compliments.
#usage script.py -g <gender> -n <name

import sys, getopt, random

def main(argv):
  gender = 'UNKNOWN'
  name = 'UNKNOWN'
  try:
    opts, args = getopt.getopt(argv, "g:n:", ["gender=", "name="])
  except getopt.GetoptError:
    print("usage: scriptName.py -g <gender> -n <name>")
    sys.exit(2)
  for opt, arg in opts:
    if opt in ("-g", "--gender"):
      gender = arg
    elif opt in ("-n", "--name"):
      name = arg
  try:
    compliment_me(gender, name)
  except (UnboundLocalError, IndexError) as error:
    print(error)
    print("usage: scriptName.py -g <gender> -n <name>")
    
#End function - main

def compliment_me(gender, name):
  if gender.lower() == "male":
  #Generate Male Compliments
    compliments = [
      "Looking buff, John!",
      "You seem taller than when I last saw you",
      "You're really smart.",
      "You've got the Touch! You've got the Powaaahhhh!",
      "You've got the Eye of the Tiger!",
      "Today's your day, John! Make it happen!",
      "Those aren't shoulders. They're boulders!",
      "You're a charming guy, you know that?"
	  ]
    r = random.randint(0, len(compliments)-1)
  elif gender.lower() == "female":
  #Generate Female Compliments
    compliments = [
	  "This girl is on fiiiire!",
	  "You are Beyonce, always.",
	  "Your momma would be proud of you, John.",
	  "You're stronger than you think.",
	  "You've got the glam and the guts.",
	  "John, you've never been more beautiful!",
	  "Be your best, John! You always are!",
	  "You've got sass, class, and ass.",
	  "You're 10/10 - Worth your weight in gold."
	  ]
    r = random.randint(0, len(compliments)-1)
  final_string = compliments[r]
  final_string = final_string.replace("John", name)
  print("\n*****************************************************************\n\n*** \\0/  " + final_string + "  \\0/ ***\n\n*****************************************************************\n")
#End function - compliment_me 

main(sys.argv[1:])

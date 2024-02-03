# from helper import *
from helper import validate_and_execute, user_input_message

user_input = ""
while user_input != "quit":
    user_input = input(user_input_message)
    list_of_days = user_input.split(":")
    print(list_of_days)
    list_of_days_dictionary = {"days": list_of_days[0], "unit": list_of_days[1]}
    print(list_of_days_dictionary)
    validate_and_execute(list_of_days_dictionary)
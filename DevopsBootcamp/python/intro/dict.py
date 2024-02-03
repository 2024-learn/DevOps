def days_to_units(num_days, conversion_unit):
    if conversion_unit == "hours":
        return f"{num_days} days have {num_days * 24} hours"
    elif conversion_unit == "minutes":
       return f"{num_days} days have {num_days * 24 * 60} minutes"
    elif conversion_unit == "seconds":
       return f"{num_days} days have {num_days * 24 * 60 * 60} seconds"
    else:
        return "unsupported conversion unit"

def validate_and_execute():
    try:
        user_input_int = int(list_of_days_dictionary["days"])
        if user_input_int > 0:
            num_mins = days_to_units(user_input_int, list_of_days_dictionary["unit"])
            print(num_mins)
        elif user_input_int == 0:
            print("please enter any number larger than zero")
        elif user_input_int < 0:
            print("Please enter a whole number, larger than zero")
    except ValueError:
        print("your input is not a positive integer")

user_input = ""
while user_input != "quit":
    user_input = input("Please enter a whole positive number and a conversion unit: \n")
    list_of_days = user_input.split(":")
    print(list_of_days)
    list_of_days_dictionary = {"days": list_of_days[0], "unit": list_of_days[1]}
    print(list_of_days_dictionary)
    validate_and_execute()
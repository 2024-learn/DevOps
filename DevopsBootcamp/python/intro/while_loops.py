conversion_to_mins = 24 * 60
def days_to_units(num_days):
    return f"{num_days} days are {num_days * conversion_to_mins} minutes"
def validate_and_execute():
    try:
        user_input_int = int(user_input)
        if user_input_int > 0:
            num_mins = days_to_units(user_input_int)
            print(num_mins)
        elif user_input_int == 0:
            print("please enter any number larger than zero")
        elif user_input_int < 0:
            print("Please enter a whole number, larger than zero")
    except ValueError:
        print("your input is not a positive integer")
        
user_input = ""
while user_input != "quit":
    user_input = input("Please enter a number: \n")
    validate_and_execute()
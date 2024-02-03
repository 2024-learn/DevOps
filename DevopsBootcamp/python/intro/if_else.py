conversion_to_mins = 24 * 60
def days_to_units(num_days):
    if num_days > 0:
        return f"{num_days} days are {num_days * conversion_to_mins} minutes"
    elif num_days == 0:
        print("please enter any number larger than zero.")
    # else:
    #     print("you entered a number less than zero")

def validate_and_execute():
    if user_input.isdigit():
        num_mins = days_to_units(int(user_input))
        print(num_mins)
    else:
        print("your input is not a positive integer")

user_input = input("Please enter a number: \n")
validate_and_execute()

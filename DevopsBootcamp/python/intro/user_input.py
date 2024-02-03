conversion_to_mins = 24 * 60
def days_to_units(num_days):
    return f"{num_days} days are {num_days * conversion_to_mins} minutes"

user_input = input("Please enter a number: \n")
user_input_int = int(user_input)
num_mins = days_to_units(user_input_int)
print(num_mins)
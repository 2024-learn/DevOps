# functions
conversion_to_mins = 24 * 60
def days_to_units(num_days):
    print(f"{num_days} days are {num_days * conversion_to_mins} minutes")

days_to_units(35)

def days_to_units(num_days, custom_message):
    print(f"{num_days} days are {num_days * conversion_to_mins} minutes")
    print(custom_message)

days_to_units(100, "wow!")
days_to_units(10, "sounds about right!")
days_to_units(46, "getting up there!")
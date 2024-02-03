# import datetime
from datetime import datetime
user_input = input("Enter your goal with a dealine, separated by a colon. Please enter date as date.month.year\n")
input_list = user_input.split(":")

goal = input_list[0]
deadline = input_list[1]

# module.definition in the module
# strptime will take a string representation of a date and will convert it into a data format

# deadline_date = datetime.datetime.strptime(deadline, "%d.%m.%Y")
# today_date = datetime.datetime.today()

deadline_date = datetime.strptime(deadline, "%d.%m.%Y")
today_date = datetime.today()

# calculate how many days from now till deadline
remaining_time = deadline_date - today_date
print(f"you have {remaining_time.days} days to accomplish your {goal} goal.")

remaining_hours = int(remaining_time.total_seconds() / 60 / 60)
print(f"you have {remaining_hours} hours to accomplish your {goal} goal.")

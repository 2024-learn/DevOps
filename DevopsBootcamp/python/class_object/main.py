from user import User
from post import Post

# create object:
app_user_one = User("phyllis@example.com", "Phyllis L.", "pwd", "SRE")
app_user_one.get_user_info()

app_user_one.change_job_title("Independently Wealthy")
app_user_one.get_user_info()

app_user_two = User("aa@aa.com", "Mr. Alvin Chipmunk", "nuts", "gatherer")
app_user_two.get_user_info()

new_post = Post("On a winter field mission today", app_user_two.name)
new_post.get_post_info()
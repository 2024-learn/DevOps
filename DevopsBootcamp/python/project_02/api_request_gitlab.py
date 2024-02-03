import requests

response = requests.get("https://gitlab.com/api/v4/users/likiphyllis/projects")
# print(response.text)
# print(response.json())

my_projects = response.json()
for project in my_projects:
    print(f"Project Name: {project['name']}\nProject Url: {project['web_url']}\n")

import requests
import smtplib
import os

nginx_server = 'http://3.99.147.146:8080/'

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')


def send_notification(email_msg):
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:  # configure email provider
        smtp.starttls()
        smtp.ehlo()  # identifies our python app with the mail server on this encrypted communication
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        message = f"Subject: SITE DOWN\nPlease fix the issue.{email_msg}"
        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

try:
    response = requests.get(nginx_server)
    # print(response)
    # print(response.text)
    # print(response.status_code)
    status = response.status_code
    if response.status_code == 200:
    # if False:
        print(f"Application is running successfully. Status {status} ")
    else:
        print(f"app is down; status: {status}")
        msg = f"restart application{status}"  # send email notification when server is down.
        send_notification(msg)
# handle connection errors:
except Exception as ex:
    print(f"connection error: {ex}")
    msg = "Nginx server is down: Connection error"
    send_notification(msg)

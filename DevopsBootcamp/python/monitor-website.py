import requests
import smtplib
import os
import paramiko
import boto3
import time

nginx_server = 'http://99.79.66.106:8080/'

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')

def restart_container():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=nginx_server, port=22, username='ec2-user', key_filename='/Users/naisenya/.ssh/id_rsa')
    # stdin, stdout, stderr = ssh.exec_command('docker ps')
    stdin, stdout, stderr = ssh.exec_command('docker start 463a528e0a15')
    print(stdout.readlines())
    ssh.close()


def send_notification(email_msg):
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.starttls()
        smtp.ehlo()
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        message = f"Subject: SITE DOWN\nPlease fix the issue.{email_msg}"
        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

try:
    response = requests.get(nginx_server)
    status = response.status_code
    if response.status_code == 200:
    # if False:  # to test application failure
        print(f"Application is running successfully. Status {status} ")
    else:
        print(f"app is down; status: {status}")
        msg = f"restart application{status}"
        send_notification(msg)
        # restart the application:
        restart_container()

# handle connection errors:
except Exception as ex:
    print(f"connection error: {ex}")
    msg = "Nginx server is down: Connection error"
    send_notification(msg)

    # restart server:

    # restart the application:
    # time.sleep(30)
    # restart_container()





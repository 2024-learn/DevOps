# health check: ec2 status checks
import boto3
import schedule

ec2_client = boto3.client('ec2')
ec2_resource = boto3.resource('ec2')

# check instance status
def check_instance_status():
    statuses = ec2_client.describe_instance_status(
        IncludeAllInstances=True
    )
    for status in statuses['InstanceStatuses']:
        instance_status = status['InstanceStatus']['Status']
        system_status = status['SystemStatus']['Status']
        state = status['InstanceState']['Name']  # get everything in one call
        print(
            f"Instance {status['InstanceId']} is {state};\ninstance status is {instance_status} and system status is {system_status}\n"
        )
        # print(state)


schedule.every(5).minutes.do(check_instance_status)
# schedule.every().day.at("01:00")
while True:
    schedule.run_pending()
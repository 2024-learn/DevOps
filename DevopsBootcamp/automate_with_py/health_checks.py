# check instance: run/stop/terminated status
import boto3

ec2_client = boto3.client('ec2')
ec2_resource = boto3.resource('ec2')

def check_running_state():
  reservations = ec2_client.describe_instances()
  for reservation in reservations["Reservations"]:
      instances = reservation["Instances"]
      for instance in instances:
          # print(instance['State']['Name'])
          print(f" instance state: {instance['InstanceId']} is {instance['State']['Name']}\n")


# check instance status
def check_instance_status():
  statuses = ec2_client.describe_instance_status()
  for status in statuses['InstanceStatuses']:
      instance_status = status['InstanceStatus']['Status']
      system_status = status['SystemStatus']['Status']
      state = status['InstanceState']['Name']  # get everything in one call
      print(
         f"Instance {status['InstanceId']} is {state};\ninstance status is {instance_status} and system status is {system_status}\n"
         )
      # print(state)


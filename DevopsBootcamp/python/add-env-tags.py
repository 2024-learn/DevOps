import boto3

ec2_client_canada = boto3.client('ec2', region_name='ca-central-1')
ec2_resource_canada = boto3.resource('ec2', region_name='ca-central-1')

instance_ids = []

reservations_canada = ec2_client_canada.describe_instances()['Reservations']
for reservation in reservations_canada:
    instances = reservation['Instances']
    for instance in instances:
        instance_ids.append(instance['InstanceId'])

response = ec2_resource_canada.create_tags(
    Resources=instance_ids,
    Tags=[
        {
            'Key': 'env',
            'Value': 'prod'
        },
    ]
)

ec2_client_ohio = boto3.client('ec2', region_name='us-east-2')
ec2_resource_ohio = boto3.resource('ec2', region_name='us-east-2')

instance_ids_ohio = []

reservations_ohio = ec2_client_ohio.describe_instances()['Reservations']
for reservation in reservations_ohio:
    instances_ohio = reservation['Instances']
    for instance in instances_ohio:
        instance_ids_ohio.append(instance['InstanceId'])

response = ec2_resource_ohio.create_tags(
    Resources=instance_ids_ohio,
    Tags=[
        {
            'Key': 'env',
            'Value': 'dev'
        },
    ]
)

import boto3

ec2_client = boto3.client('ec2')

all_vpcs = ec2_client.describe_vpcs()
vpcs = (all_vpcs["Vpcs"])

# get CidrBlockState:
for vpc in vpcs:
    print(vpc["VpcId"])
    cidr_block_assoc_set = vpc["CidrBlockAssociationSet"]
    for set in cidr_block_assoc_set:
        print(set["CidrBlockState"])


# connect to a non-default region without changing the default state in the aws credentials
import boto3

ec2_client = boto3.client('ec2', region_name="eu-central-1")

all_vpcs = ec2_client.describe_vpcs()
vpcs = (all_vpcs["Vpcs"])

# get CidrBlockState:
for vpc in vpcs:
    print(vpc["VpcId"])
    cidr_block_assoc_set = vpc["CidrBlockAssociationSet"]
    for set in cidr_block_assoc_set:
        print(set["CidrBlockState"])    

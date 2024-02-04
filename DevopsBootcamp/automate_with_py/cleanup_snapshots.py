#  clean up for one type of volume
import boto3
from operator import itemgetter

ec2_client = boto3.client('ec2', region_name='ca-central-1')
snapshots = ec2_client.describe_snapshots(
        OwnerIds=['self']
    )

sort_by_creation_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse=True)

for snap in sort_by_creation_date[:]:  # will delete all volumes
    response = ec2_client.delete_snapshot(
        SnapshotId=snap['SnapshotId']
    )
    print(response)

# cleanup for multiple volumes:
import boto3
from operator import itemgetter

ec2_client = boto3.client('ec2', region_name='ca-central-1')

volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': ['prod']
        }
    ]
)
for volume in volumes['Volumes']:
    snapshots = ec2_client.describe_snapshots(
        OwnerIds=['self'],
        Filters=[
            {
                'Name': 'volume-id',
                'Values': [volume['VolumeId']]
            }
        ]
    )

sort_by_creation_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse=True)

for snap in sort_by_creation_date[:]:  # will delete all volumes
    response = ec2_client.delete_snapshot(
        SnapshotId=snap['SnapshotId']
    )
    print(response)

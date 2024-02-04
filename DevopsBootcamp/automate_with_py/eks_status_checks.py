import boto3

client = boto3.client('eks', region_name='us-east-2')
clusters = client.list_clusters()['clusters']
# print(clusters['clusters'])

for cluster in clusters:
    response = client.describe_cluster(
        name=cluster
    )
    # cluster_status = response['cluster']['status']
    # cluster_endpoint = response['cluster']['endpoint']
    
    # print(cluster_status)
    # print(f"Cluster: {cluster}. Status: {cluster_status}")
    # print(f"Cluster: {cluster}. Endpoint: {cluster_endpoint}")

    cluster_info = response['cluster']
    cluster_status = cluster_info['status']
    cluster_endpoint = cluster_info['endpoint']
    cluster_version = cluster_info['version']

    # print(f"Cluster: {cluster}. Status: {cluster_status}")
    # print(f"Cluster: {cluster}. Endpoint: {cluster_endpoint}")
    # print(f"Cluster: {cluster}. Version: {cluster_version}")

    # more presentable response:
    print(f"Cluster: {cluster}")
    print(f"\tStatus: {cluster_status}")
    print(f"\tEndpoint: {cluster_endpoint}")
    print(f"\tVersion: {cluster_version}")
    print(" ")
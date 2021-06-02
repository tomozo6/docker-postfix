#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Import Module
# ------------------------------------------------------------------------------
import subprocess
from subprocess import PIPE

import boto3
cloudwatch = boto3.client('cloudwatch')


# ------------------------------------------------------------------------------
# Class & Function
# ------------------------------------------------------------------------------
def get_queuecount():
    cmd = "/bin/find /var/spool/postfix/deferred/ -type f | /bin/wc -l"
    proc = subprocess.run(cmd, shell=True, stdout=PIPE, stderr=PIPE, text=True)
    return int(proc.stdout)


def main():
    try:
        queue_count = get_queuecount()

        cloudwatch.put_metric_data(
            MetricData=[
                {
                    'Dimensions': [
                        {
                            'Name': 'Middleware',
                            'Value': 'postfix'
                        },
                    ],
                    'MetricName': 'QueueCount',
                    'Unit': 'Count',
                    'Value': queue_count
                },
            ],
            Namespace='Middleware'
        )
        print("INFO: put_metric.py Succeed")
    except Exception as e:
        print("ERROR: put_metric.py Faild")
        print(f"ERROR: {e}")
        raise e


if __name__ == '__main__':
    main()

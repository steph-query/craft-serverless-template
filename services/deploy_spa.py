import mimetypes
import os
import StringIO
import zipfile

import boto3
from botocore.client import Config

def lambda_handler(event, context):
# Args: s3_bucket, s3_path, sns_topic
    S3_BUCKET = os.environ.get('S3_BUCKET')
    S3_KEY = os.environ.get('S3_KEY')

    sns = boto3.resource("sns")
    topic = sns.Topic(os.environ.get('SNS_TOPIC')

    location = {
        "bucketName": S3_BUCKET,
        "objectKey": S3_KEY
    }

    try:
        job = event.get("CodePipeline.job")
        if job:
            for artifact in job["data"]["inputArtifacts"]:
                if artifact["name"] == "MyAppBuild": # MyAppBuild is the default name for this step in CodePipeline
                    location = artifact["location"]["s3Location"]

        s3 = boto3.resource("s3", config=Config(signature_version="s3v4"))
        index_bucket = s3.Bucket(S3_BUCKET)
        build_bucket = s3.Bucket(location["bucketName"])

        index_zip = StringIO.StringIO()
        build_bucket.download_fileobj(location["objectKey"], index_zip)

        with zipfile.ZipFile(index_zip) as myzip:
            for nm in myzip.namelist():
                obj = myzip.open(nm)
                index_bucket.upload_fileobj(obj, nm,
                    ExtraArgs={"ContentType": mimetypes.guess_type(nm)[0]})
                index_bucket.Object(nm).Acl().put(ACL="public-read")

        print "Job done!"
        topic.publish(Subject="I am a god", Message="Hurry up with my damn massage.")

        if job:
            codepipeline = boto3.client("codepipeline")
            codepipeline.put_job_success_result(jobId=job["id"])
    except:
        topic.publish(Subject="DOH!", Message="Suckka got played!")

    return "That's all folks!"


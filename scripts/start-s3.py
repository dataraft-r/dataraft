"""Wait for the disposable CI MinIO and create the isolated test bucket."""

import os
import time
import sys

from minio import Minio

client = Minio(
    "127.0.0.1:9000",
    access_key=os.environ["AWS_ACCESS_KEY_ID"],
    secret_key=os.environ["AWS_SECRET_ACCESS_KEY"],
    secure=False,
)
if len(sys.argv) > 1 and sys.argv[1] == "verify":
    keys = [obj.object_name for obj in client.list_objects(
        os.environ["DATARAFT_TEST_S3_BUCKET"], recursive=True
    )]
    assert any(key.startswith("integration/tables/") for key in keys), keys
    assert any(key.startswith("integration/landing/") for key in keys), keys
    print("Verified remote DuckLake tables and landed source objects")
    sys.exit(0)

for attempt in range(60):
    try:
        if not client.bucket_exists(os.environ["DATARAFT_TEST_S3_BUCKET"]):
            client.make_bucket(os.environ["DATARAFT_TEST_S3_BUCKET"])
        break
    except Exception:
        if attempt == 59:
            raise
        time.sleep(1)

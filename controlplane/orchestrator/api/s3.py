from fastapi import APIRouter
from services.aws_s3 import list_buckets

router = APIRouter()

@router.get("/api/s3/list")
def api_list_buckets():
    return list_buckets()


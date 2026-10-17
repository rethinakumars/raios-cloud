from dispatcher import dispatch
from orchestrator.models.region import get_region_state

def list_buckets():
    region = get_region_state()
    return dispatch("s3", "list", region)


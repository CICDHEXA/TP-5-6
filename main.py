import requests
import json

ACCESS_TOKEN = {REPLACEACCESSTOKEN}
PROJECT_ID = {REPLACEPROJECTID}
GITLAB_URL = "http://gitlab"

headers = {
    "PRIVATE-TOKEN": ACCESS_TOKEN
}

def get_commits():
    r = requests.get(f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/repository/commits", headers=headers)
    return r.json() if r.status_code == 200 else []

def get_merge_requests():
    r = requests.get(f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/merge_requests", headers=headers)
    return r.json() if r.status_code == 200 else []

def get_pipelines():
    r = requests.get(f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/pipelines", headers=headers)
    return r.json() if r.status_code == 200 else []

def generate_report():
    report = {
        "commit_count": len(get_commits()),
        "merge_request_count": len(get_merge_requests()),
        "pipeline_count": len(get_pipelines())
    }
    with open("report.json", "w") as f:
        json.dump(report, f, indent=2)
    print("Report generated:", report)

if __name__ == "__main__":
    generate_report()

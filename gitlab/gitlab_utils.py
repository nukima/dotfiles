import gitlab
import git
import os
import json
import time
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
GITLAB_URL = os.getenv("GITLAB_URL")
ACCESS_TOKEN = os.getenv("ACCESS_TOKEN")
ROOT_FOLDER = os.getenv("ROOT_FOLDER", "gitlab_projects")  # Default to "gitlab_projects"
JSON_FILE = os.getenv("JSON_FILE", "projects.json")  # Default to "projects.json"

def explore_projects():
    """Fetches all accessible GitLab projects and saves them to a JSON file."""
    gl = gitlab.Gitlab(GITLAB_URL, private_token=ACCESS_TOKEN)
    gl.auth()
    
    # Fetch all accessible projects
    projects = gl.projects.list(all=True, iterator=True)
    project_data = {}
    
    # Load existing projects
    if os.path.exists(JSON_FILE):
        with open(JSON_FILE, "r") as f:
            project_data = json.load(f)
    
    # Update or add new projects
    for project in projects:
        project_data[project.id] = {
            "id": project.id,
            "name": project.name,
            "path_with_namespace": project.path_with_namespace,
            "ssh_url_to_repo": project.ssh_url_to_repo,
        }

    # Save to JSON file
    with open(JSON_FILE, "w") as f:
        json.dump(project_data, f, indent=4)
    print(f"Saved {len(project_data)} projects to {JSON_FILE}")

def sync_projects():
    """Syncs projects listed in the JSON file to the local filesystem."""
    # Ensure root folder exists
    Path(ROOT_FOLDER).mkdir(parents=True, exist_ok=True)
    
    # Load project data
    if not os.path.exists(JSON_FILE):
        print(f"{JSON_FILE} does not exist. Run `explore_projects` first.")
        return
    
    with open(JSON_FILE, "r") as f:
        project_data = json.load(f)
    
    for project_id, project in project_data.items():
        repo_path = os.path.join(ROOT_FOLDER, project["path_with_namespace"])
        try:
            if not os.path.exists(repo_path):
                print(f"Cloning project {project['name']} to {repo_path}...")
                os.makedirs(repo_path, exist_ok=True)
                git.Repo.clone_from(project["ssh_url_to_repo"], repo_path)
            else:
                print(f"Pulling updates for project {project['name']}...")
                repo = git.Repo(repo_path)
                repo.git.pull()

            # Delay to avoid excessive requests
            time.sleep(10)  # Adjust this delay as needed
        except Exception as e:
            print(f"Error syncing project {project['name']}: {e}")

    print("All projects synced successfully.")


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="GitLab Utilities")
    parser.add_argument(
        "action", choices=["explore", "sync"], help="Action to perform: explore or sync"
    )
    args = parser.parse_args()

    if args.action == "explore":
        explore_projects()
    elif args.action == "sync":
        sync_projects()

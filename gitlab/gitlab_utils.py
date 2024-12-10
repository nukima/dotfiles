import tqdm
import os
import json
import time
import logging
from typing import Dict, Any
from pathlib import Path

import gitlab
import git
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class GitLabSynchronizer:
    def __init__(self, env_file: str = '.env'):
        """
        Initialize GitLab synchronizer with configuration from environment variables.
        
        :param env_file: Path to the .env file (default: '.env')
        """
        # Load environment variables
        load_dotenv(env_file)

        # Configuration parameters
        self.gitlab_url = self._get_env_var('GITLAB_URL')
        self.access_token = self._get_env_var('ACCESS_TOKEN')
        self.root_folder = os.getenv('ROOT_FOLDER', 'gitlab_projects')
        self.json_file = os.getenv('JSON_FILE', 'projects.json')

        # Create root folder if it doesn't exist
        Path(self.root_folder).mkdir(parents=True, exist_ok=True)

    def _get_env_var(self, var_name: str) -> str:
        """
        Retrieve an environment variable with error handling.
        
        :param var_name: Name of the environment variable
        :return: Value of the environment variable
        :raises ValueError: If the environment variable is not set
        """
        value = os.getenv(var_name)
        if not value:
            raise ValueError(f"Environment variable {var_name} is not set")
        return value

    def explore_projects(self) -> Dict[str, Any]:
        """
        Fetch all accessible GitLab projects and save them to a JSON file.
        
        :return: Dictionary of project data
        """
        try:
            # Authenticate with GitLab
            gl = gitlab.Gitlab(self.gitlab_url, private_token=self.access_token)
            gl.auth()

            # Fetch all accessible projects
            projects = list(gl.projects.list(all=True, iterator=True))
            
            # Load existing projects if JSON file exists
            project_data = self._load_existing_projects()

            # Update project data
            for project in projects:
                project_data[str(project.id)] = {
                    "id": project.id,
                    "name": project.name,
                    "path_with_namespace": project.path_with_namespace,
                    "ssh_url_to_repo": project.ssh_url_to_repo,
                }

            # Save updated project data
            self._save_projects(project_data)
            
            logger.info(f"Saved {len(project_data)} projects to {self.json_file}")
            return project_data

        except Exception as e:
            logger.error(f"Error exploring projects: {e}")
            raise

    def _load_existing_projects(self) -> Dict[str, Any]:
        """
        Load existing projects from JSON file.
        
        :return: Dictionary of existing projects
        """
        try:
            if os.path.exists(self.json_file):
                with open(self.json_file, "r") as f:
                    return json.load(f)
            return {}
        except json.JSONDecodeError:
            logger.warning(f"Invalid JSON in {self.json_file}. Starting with empty project list.")
            return {}

    def _save_projects(self, project_data: Dict[str, Any]):
        """
        Save project data to JSON file.
        
        :param project_data: Dictionary of project data to save
        """
        with open(self.json_file, "w") as f:
            json.dump(project_data, f, indent=4)

    def sync_projects(self):
        """
        Synchronize projects with progress bar and detailed logging.
        """
        # Validate JSON file exists
        if not os.path.exists(self.json_file):
            logger.error(f"{self.json_file} does not exist. Run `explore_projects` first.")
            return

        # Load project data
        with open(self.json_file, "r") as f:
            project_data = json.load(f)

        # Create a progress bar
        progress_bar = tqdm.tqdm(
            list(project_data.items()), 
            desc="Syncing Projects", 
            total=len(project_data),
            unit="project"
        )

        for project_id, project in progress_bar:
            try:
                # Update progress bar description with current project name
                progress_bar.set_description(f"Syncing {project['name']}")
                
                # Sync the project
                self._sync_single_project(project)
                
                time.sleep(1)  # Delay between project syncs
            except Exception as e:
                logger.error(f"Error syncing project {project['name']}: {e}")
                # Optionally, you can update the progress bar to show error
                progress_bar.set_description(f"Failed: {project['name']}")
                progress_bar.update(1)

        logger.info("Project synchronization completed.")

    def _sync_single_project(self, project: Dict[str, Any]):
        """
        Synchronize a single project with enhanced logging.
        """
        logger.info(f"Processing project: {project['name']}")
        
        repo_path = os.path.join(self.root_folder, project["path_with_namespace"])
        
        try:
            # Clone or update repository
            if not os.path.exists(repo_path):
                logger.info(f"Cloning project {project['name']}...")
                os.makedirs(repo_path, exist_ok=True)
                git.Repo.clone_from(project["ssh_url_to_repo"], repo_path)
                return

            # Open existing repository
            repo = git.Repo(repo_path)

            # Fetch remote updates with logging
            logger.info(f"Fetching updates for {project['name']}...")
            origin = repo.remote(name="origin")
            fetch_info = origin.fetch()

            # Handle empty remote repository
            if not fetch_info:
                logger.warning(f"Remote repository for {project['name']} is empty. Skipping...")
                return

            # Determine current branch
            try:
                current_branch = repo.active_branch
                logger.info(f"Current branch: {current_branch.name}")
            except TypeError:
                # Handle detached HEAD
                self._handle_detached_head(repo, origin)
                return

            # Synchronize current branch with its remote tracking branch
            tracking_branch = current_branch.tracking_branch()
            if tracking_branch:
                logger.info(f"Pulling updates for current branch {current_branch.name}...")
                repo.git.pull()
            else:
                logger.warning(f"No upstream branch set for {current_branch.name}. Skipping pull.")

        except Exception as e:
            logger.error(f"Detailed sync error for {project['name']}: {e}")
            raise

    def _handle_detached_head(self, repo: git.Repo, origin):
        """
        Handle repository in detached HEAD state.
        
        :param repo: Git repository
        :param origin: Repository's origin remote
        """
        logger.warning("Repository is in a detached HEAD state.")
        
        # Try to find a suitable branch to checkout
        if "master" in origin.refs:
            logger.info("Checking out 'master' branch...")
            repo.git.checkout("-b", "master", "origin/master")
        else:
            # Find the first available remote branch
            available_branches = [ref.remote_name for ref in origin.refs if ref.remote_name != "HEAD"]
            if available_branches:
                first_branch = available_branches[0]
                logger.info(f"Checking out branch {first_branch}...")
                repo.git.checkout("-b", first_branch, f"origin/{first_branch}")
            else:
                logger.error("No branches available to check out.")


def main():
    """Main entry point for the script."""
    import argparse

    parser = argparse.ArgumentParser(description="GitLab Project Synchronization Utility")
    parser.add_argument(
        "action", 
        choices=["explore", "sync"], 
        help="Action to perform: explore or sync projects"
    )
    args = parser.parse_args()

    synchronizer = GitLabSynchronizer()

    try:
        if args.action == "explore":
            synchronizer.explore_projects()
        elif args.action == "sync":
            synchronizer.sync_projects()
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
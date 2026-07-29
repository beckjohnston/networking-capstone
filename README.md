# networking-capstone

# To Do

 - Terraform project
 - Ansible files
 - GitHub Actions/CI CD
 - Presentation work

## Terraform Project
Create a terraform project

## Ansible Project
 - Create and connect various nodes.
   - Detail where the inventory file can be changed incase the node's ip changes
 - Create scripts for verifying and connecting to the created instances
    - Try to make example scripts for httpd, differnt software downloads, etc.
 - Try to make the project as easy to modify as possible. Variable files, etc.
    - Host names for nodes should be easily marked and detailed instructions for modification should be available in the README.md
 - Attach monitoring software such as Grafana or Prometheus.
    - Find a way to install the sofware using Docker onto the nodes.
    - Note the exact url necessary for accessing the sofware in the README.md file

## GitHub Action - CI/CD
 - Configure the workflow to be triggered by a pull request
 - Perform a dry run in terraform and ansible before applying changes

## Presentation Work
 - Finalize the README.md file with detailed descriptions for the use of all features.
   - Highlight how to modify the Terraform and Ansible files based on varying needs or changes
 - Create a slide deck for the in-person presentation.
 - Either get the project working on a laptop for use in the presentation or create a video of how the project functions.
   - A video might need to be editted as Terraform can be very slow when being run

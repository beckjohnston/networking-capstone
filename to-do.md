# To Do
[] Terraform project
[] Ansible files
[] GitHub Actions/CI CD
[] Presentation work
[] Create a diagram for the README/presentation

## Terraform Project
Create a terraform project

## Ansible Project
- Create and connect various nodes.
- Detail where the inventory file can be changed in case the node's IP changes
- Make it possible to create the inventory file using the Terraform output via GitHub Actions
- Create scripts for verifying and connecting to the created instances
- Try to make example scripts for httpd, different software downloads, etc.
- Make the program OS agnostic. Start with compatibility with Amazon Linux.
- Try to make the project as easy to modify as possible. Variable files, etc.
- Host names for nodes should be easily marked and detailed instructions for modification should be available in the README.md.
- Attach monitoring software such as Grafana or Prometheus.
- Find a way to install the software onto the nodes using Docker.
- Note the exact URL necessary for accessing the software in the README.md file.

## GitHub Action - CI/CD
- Configure the workflow to be triggered by a pull request.
- Perform a dry run in Terraform and Ansible prior to applying changes.
- Create a rollback workflow

## Presentation Work
- Finalize the README.md file with detailed descriptions for the use of all features.
- Highlight how to modify the Terraform and Ansible files based on varying needs or changes
- Create a slide deck for the in-person presentation.
- Either get the project working on a laptop for use in the presentation or create a video of how the project functions.
- A video might need to be edited as Terraform can be very slow when being run

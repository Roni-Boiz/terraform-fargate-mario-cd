# Terraform-Fargate-GitHub-Actions

This project demonstrates the deployment of a containerized application on AWS Fargate using Amazon ECS and Terraform. AWS Fargate, a serverless compute engine for containers, eliminates the need to manage EC2 instances, allowing developers to focus on building applications. Amazon ECS (Elastic Container Service) orchestrates Docker container deployments on AWS, providing scalability and flexibility. The project utilizes an image hosted on Docker Hub and deploys it via Terraform, automating the creation and management of infrastructure as code. Application Load Balancers (ALBs) are used to distribute incoming traffic to running tasks, enabling high availability and reliability. ALBs also provide features like SSL termination, path-based routing, and enhanced security, making them ideal for managing web-based applications.

![intro]()


## Prerequisites

1. **AWS Account:** Sign up at [aws.amazon.com](https://aws.amazon.com/).
2. **DockerHub Account:** For deploying a containerized application, register for [DockerHub](https://hub.docker.com/).
3. **Slack Account:** To get pipeline feedback in Slack channel. Sign up at [slack.com](https://slack.com/).


## Steps to deploy Application in EKS

### Step 1: Steup EC2 Instance

1. #### Create EC2 Instance

    To launch an AWS EC2 instance with Ubuntu latest (24.04) using the AWS Management Console, sign in to your AWS account, access the EC2 dashboard, and click “Launch Instances.” In “Step 1,” select “Ubuntu 24.04” as the AMI, and in “Step 2,” choose “t3.small” as the instance type ("t2.nano" is way too small). Configure the instance details, storage (12 GB), tags , and security group ( make sure to create inbound rules to allow tcp traffic on port 22, 80, 443, 9000, 3000 [optional] ) settings according to your requirements. Review the settings, create or select a key pair for secure access, and launch the instance. Once launched, you can connect to it via SSH using the associated key pair or through management console as well.

   ![ec2-instance]()


3. #### Create IAM Role

    To create a new role for manage AWS resource through EC2 Instance in AWS, start by navigating to the AWS Console and typing “IAM” to access the Identity and Access Management service. Click on “Roles,” then select “Create role.” Choose “AWS service” as the trusted entity and select “EC2” from the available services. Proceed to the next step and use the “Search” field to add the necessary permissions policies, such as "AdministratorAccess" or "AmazonEC2FullAccess", "AmazonS3FullAccess" and "AmazonECS_FullAccess", etc. After adding these permissions, click "Next." In the “Role name” field, enter “EC2 Instance Role” and complete the process by clicking “Create role”.

   ![ec2-role-1]()
   
   ![ec2-role-2]()
   
   ![ec2-role-3]()


2. #### Attach IAM Role

    To assign the newly created IAM role to an EC2 instance, start by navigating to the EC2 dashboard in the AWS Console. Locate the specific instance where you want to add the role, then select the instance and choose "Actions." From the dropdown menu, go to "Security" and click on "Modify IAM role." In the next window, select the newly created role from the list and click on "Update IAM role" to apply the changes.

   ![attach-role-1]()

   ![attach-role-2]()


### Step 2: Setup Self-Hosted Runner on EC2

1. #### In GitHub

    To set up a self-hosted GitHub Actions runner, start by navigating to your GitHub repository and clicking on Settings. Go to the Actions tab and select Runners. Click on New self-hosted runner and choose Linux as the operating system with X64 as the architecture. Follow the provided instructions to copy the commands required for installing the runner (Settings --> Actions --> Runners --> New self-hosted runner).

    **Download Code**
    ```bash
    # Create a folder
    $ mkdir actions-runner && cd actions-runner
    # Download the latest runner package
    $ curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
    # Optional: Validate the hash
    $ echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-2.319.1.tar.gz" | shasum -a 256 -c
    # Extract the installer
    $ tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz
    ```

    **Configure Code**
    ```bash
    # Create the runner and start the configuration experience
    $ ./config.sh --url https://github.com/Roni-Boiz/terraform-fargate-mario-cd --token <your-token>
    # Last step, run it!
    $ ./run.sh
    ```
    
    ![runner-1]()


3. #### In EC2 Instance

    Next, connect to your EC2 instance via SSH or management console, and paste the commands in the terminal to complete the setup and register the runner. When you enter `./config.sh` enter follwoing details:

    - runner group --> keep as default
    - name of runner --> git-workflow
    - runner labels --> git-workflow
    - work folder --> keep default

    ![runner-2]()


> [!TIP]
> At the end you should see **Connected to GitHub** message upon successful connection


### Step 3: Setup Slack

1. #### Create Channel

    To set up Slack notifications for your GitHub Actions workflow, start by creating a Slack channel `github-actions` if you don't have one. Go to your Slack workspace, create a channel specifically for notifications, and then click on Home.

    ![slack-1]()


2. #### Create App

    From the Home click on Add apps than click App Directory. This opens a new tab; click on Manage then click on Build and then Create New App.

    ![slack-2]()
   
    ![slack-3]()
   
    ![slack-4]()
   
    ![slack-5]()

    Choose From scratch, provide a name for your app, select your workspace, and click Create. Next, enable Incoming Webhooks by setting it to "on," and click Add New Webhook to Workspace. Select the newly created channel for notifications and grant the necessary permissions.

    ![slack-6]()
   
    ![slack-7]()
   
    ![slack-8]()
   
    ![slack-9]()


3. #### Create Repository Secret

    This generates a webhook URL—copy it and go to your GitHub repository settings. Navigate to Secrets > Actions > New repository secret and add the webhook URL as a `SLACK_WEBHOOK_URL` secret.

    ![slack-10]()
   
    ![slack-11]()

This setup ensures that Slack notifications are sent using the act10ns/slack action, configured to run "always"—regardless of job status—sending messages to the specified Slack channel via the webhook URL stored in the secrets.

> [!NOTE]
> Don't forget to update the **channel name** (not the app name) you have created in all the places `.github/workflows/terrafrom.yml`, `.github/workflows/cicd.yml`, `.github/workflows/destroy.yml`.


### Step 6: Pipeline

Following workflows will execute in background `Script --> Terraform --> CI/CD Pipeline`. Wait till the pipeline finishes to build and deploy the application to kubernetes cluster.

**Script Pipeline**

![script-pipeline]()

**Terraform Pipeline**

![terraform-pipeline]()

**CICD Pipeline**

![cicd-pipeline]()

After ppipeline finished you can access the application. Following images showcase the output results.


**Slack Channel Output**

![slack-channel-1]()

> [!NOTE]
> Copy the application url of application service (`http://app-load-balancer-1551555331.ap-south-1.elb.amazonaws.com/`) and paste on browser to access the application


**Application**

![app]()

### Step 7: Destroy Resources

Finally if you need to destroy all the resources. For that run the `destroy pipeline` manually in github actions.

**Destroy Pipeline**

![destroy-pipeline]()

**Slack Channel Output**

![slack-channel-2]()


### Step 8: Remove Self-Hosted Runner

Finally, you need remove the self-hosted runner and terminate the instance.

1. #### Open your repository 

    Go to Settings --> Actions --> Runners --> Select your runner (git-workflow) --> Remove Runner. Then you will see steps safely remove runner from EC2 instance.

2. #### Remove runner 
    
    Go to your EC2 instance and execute the command

    ```bash
    # Remove the runner
    $ ./config.sh remove --token <your-token>
    ```
    
    ![runner-remove]()

> [!WARNING]
> Make sure you are in the right folder `~/actions-runner`

3. **Terminate Instance**

    Go to your AWS Management console --> EC2 terminate the created instance (git-workflow) and then remove any additional resources (vpc, security groups, s3 buckets, dynamodb tables, load balancers, volumes, auto scaling groups, etc)

    **Verify that every resource is removed or terminated**
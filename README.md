# Terraform-Fargate-GitHub-Actions

This project demonstrates the deployment of a containerized application on AWS Fargate using Amazon ECS and Terraform. AWS Fargate, a serverless compute engine for containers, eliminates the need to manage EC2 instances, allowing developers to focus on building applications. Amazon ECS (Elastic Container Service) orchestrates Docker container deployments on AWS, providing scalability and flexibility. The project utilizes an image hosted on Docker Hub and deploys it via Terraform, automating the creation and management of infrastructure as code. Application Load Balancers (ALBs) are used to distribute incoming traffic to running tasks, enabling high availability and reliability. ALBs also provide features like SSL termination, path-based routing, and enhanced security, making them ideal for managing web-based applications.

![intro](https://github.com/user-attachments/assets/32cb180c-a227-477d-b023-80e2eb5de2ba)

## Prerequisites

1. **AWS Account:** Sign up at [aws.amazon.com](https://aws.amazon.com/).
2. **DockerHub Account:** For deploying a containerized application, register for [DockerHub](https://hub.docker.com/).
3. **Slack Account:** To get pipeline feedback in Slack channel. Sign up at [slack.com](https://slack.com/).


## Steps to deploy Application in ECS FARGATE

### Step 1: Steup EC2 Instance

1. #### Create EC2 Instance

    To launch an AWS EC2 instance with Ubuntu latest (24.04) using the AWS Management Console, sign in to your AWS account, access the EC2 dashboard, and click “Launch Instances.” In “Step 1,” select “Ubuntu 24.04” as the AMI, and in “Step 2,” choose “t3.small” as the instance type ("t2.nano" is way too small). Configure the instance details, storage (12 GB), tags , and security group ( make sure to create inbound rules to allow tcp traffic on port 22, 80, 443, 9000, 3000 [optional] ) settings according to your requirements. Review the settings, create or select a key pair for secure access, and launch the instance. Once launched, you can connect to it via SSH using the associated key pair or through management console as well.

   ![ec2-instance](https://github.com/user-attachments/assets/96b0f67e-2ff5-42ec-96ef-43e05eb306ad)


3. #### Create IAM Role

    To create a new role for manage AWS resource through EC2 Instance in AWS, start by navigating to the AWS Console and typing “IAM” to access the Identity and Access Management service. Click on “Roles,” then select “Create role.” Choose “AWS service” as the trusted entity and select “EC2” from the available services. Proceed to the next step and use the “Search” field to add the necessary permissions policies, such as "AdministratorAccess" or "AmazonEC2FullAccess", "AmazonS3FullAccess" and "AmazonECS_FullAccess", etc. After adding these permissions, click "Next." In the “Role name” field, enter “EC2 Instance Role” and complete the process by clicking “Create role”.

   ![ec2-role-1](https://github.com/user-attachments/assets/6be1730a-f496-494b-8cda-4cc6d1b7e4c1)
   
   ![ec2-role-2](https://github.com/user-attachments/assets/e2ec28f8-3efe-4090-b1ec-89c2a6ffdc1b)
   
   ![ec2-role-3](https://github.com/user-attachments/assets/557a0254-bd2c-4d33-9d47-fb43d29cae93)


2. #### Attach IAM Role

    To assign the newly created IAM role to an EC2 instance, start by navigating to the EC2 dashboard in the AWS Console. Locate the specific instance where you want to add the role, then select the instance and choose "Actions." From the dropdown menu, go to "Security" and click on "Modify IAM role." In the next window, select the newly created role from the list and click on "Update IAM role" to apply the changes.

   ![attach-role-1](https://github.com/user-attachments/assets/381c3889-7999-40c2-9689-c96ae7aec1bf)

   ![attach-role-2](https://github.com/user-attachments/assets/f458a3ab-3c2a-47d6-a699-3a3bc9ce3cc8)


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
    
    ![runner-1](https://github.com/user-attachments/assets/58f6c9bd-ef47-4f70-b798-f390ef1e6997)


3. #### In EC2 Instance

    Next, connect to your EC2 instance via SSH or management console, and paste the commands in the terminal to complete the setup and register the runner. When you enter `./config.sh` enter following details:

    - runner group --> keep as default
    - name of runner --> git-workflow
    - runner labels --> git-workflow
    - work folder --> keep default

    ![runner-2](https://github.com/user-attachments/assets/72c6e90c-0f91-44a1-b81d-71486ee7dda3)


> [!TIP]
> At the end you should see **Connected to GitHub** message upon successful connection


### Step 3: Setup Slack

1. #### Create Channel

    To set up Slack notifications for your GitHub Actions workflow, start by creating a Slack channel `github-actions` if you don't have one. Go to your Slack workspace, create a channel specifically for notifications, and then click on Home.

    ![slack-1](https://github.com/user-attachments/assets/25f7a1b9-68c6-4e2c-bddc-078dc534914e)

2. #### Create App

    From the Home click on Add apps than click App Directory. This opens a new tab; click on Manage then click on Build and then Create New App.

    ![slack-2](https://github.com/user-attachments/assets/c18d4d5b-aa93-4f8b-bcdd-de2f83406ddd)
   
    ![slack-3](https://github.com/user-attachments/assets/c986f000-707b-4bb9-97dd-1d7f9f024cd6)
   
    ![slack-4](https://github.com/user-attachments/assets/2df6dd43-1eb2-402f-b2db-894d1435dacc)
   
    ![slack-5](https://github.com/user-attachments/assets/5513a5f1-c72c-4ded-9a20-7a58bb6ed451)

    Choose From scratch, provide a name for your app, select your workspace, and click Create. Next, enable Incoming Webhooks by setting it to "on," and click Add New Webhook to Workspace. Select the newly created channel for notifications and grant the necessary permissions.

    ![slack-6](https://github.com/user-attachments/assets/ad41fc15-e661-4193-85e5-cfbe33d63d5f)
   
    ![slack-7](https://github.com/user-attachments/assets/a6218908-2029-46c5-af84-31e307324276)
   
    ![slack-8](https://github.com/user-attachments/assets/b5e9caed-954b-44fd-b335-581c1cf0c38c)
   
    ![slack-9](https://github.com/user-attachments/assets/6cbb5a36-0606-4eab-8090-d58b420c0986)

3. #### Create Repository Secret

    This generates a webhook URL—copy it and go to your GitHub repository settings. Navigate to Secrets > Actions > New repository secret and add the webhook URL as a `SLACK_WEBHOOK_URL` secret.

    ![slack-10](https://github.com/user-attachments/assets/3269adc2-59eb-4c4b-ad08-96922e5ab433)
   
    ![slack-11](https://github.com/user-attachments/assets/89032c10-4787-418a-ae4a-468a2c2696bb)

This setup ensures that Slack notifications are sent using the act10ns/slack action, configured to run "always"—regardless of job status—sending messages to the specified Slack channel via the webhook URL stored in the secrets.

> [!NOTE]
> Don't forget to update the **channel name** (not the app name) you have created in all the places `.github/workflows/terrafrom.yml`, `.github/workflows/cicd.yml`, `.github/workflows/destroy.yml`.


### Step 4: Setup Docker Image

Push image to DokcerHub or use existing DokcerHub public repository image to deploy in ECS Fargate.

```bash
$ docker login -u <username> -p <password/token>
$ docker build -t mario .
$ docker tag mario <username>/super-mario-web:latest
$ docker push <username>/super-mario-web:latest
```

> [!NOTE]
> Don't forget to update the image tag/name in all the places `.github/workflows/cicd.yml` `modules/fargate/fargate.tf`

### Step 5: Pipeline

Following workflows will execute in background `Script --> Terraform --> CI/CD Pipeline`. Wait till the pipeline finishes to build and deploy the application to elstic container service.

**Script Pipeline**

![script-pipeline](https://github.com/user-attachments/assets/dec398a4-9742-447c-92fb-57cc421cfc72)

**Terraform Pipeline**

![terraform-pipeline](https://github.com/user-attachments/assets/7397cb95-920b-4a9e-8115-329d04bdf08f)

**CICD Pipeline**

![cicd-pipeline](https://github.com/user-attachments/assets/c5817e68-a8e7-4d65-8ccb-834c39785653)

After ppipeline finished you can access the application. Following images showcase the output results.

**Slack Channel Output**

![slack-channel-1](https://github.com/user-attachments/assets/6cf4baa6-6dfe-4b01-a239-dfe1a193af6e)

> [!NOTE]
> Copy the application url of application service (`http://app-load-balancer-1551555331.ap-south-1.elb.amazonaws.com/`) and paste on browser to access the application

**Application**

![app](https://github.com/user-attachments/assets/47275555-1980-4b41-a4c3-d10a6f5e949f)


### Step 6: Destroy Resources

Finally if you need to destroy all the resources. For that run the `destroy pipeline` manually in github actions.

**Destroy Pipeline**

![destroy-pipeline](https://github.com/user-attachments/assets/859b6b73-4137-42ce-b452-fca06cf36000)

**Slack Channel Output**

![slack-channel-2](https://github.com/user-attachments/assets/09831049-7589-43a0-924c-50c28e406eb6)


### Step 7: Remove Self-Hosted Runner

Finally, you need remove the self-hosted runner and terminate the instance.

1. #### Open your repository 

    Go to Settings --> Actions --> Runners --> Select your runner (git-workflow) --> Remove Runner. Then you will see steps safely remove runner from EC2 instance.

    ![runner-remove-1](https://github.com/user-attachments/assets/dc1b6d74-d1e5-44ef-a64e-eb13763a7688)

2. #### Remove runner 
    
    Go to your EC2 instance and execute the command

    ```bash
    # Remove the runner
    $ ./config.sh remove --token <your-token>
    ```
    
    ![runner-remove-2](https://github.com/user-attachments/assets/bddf9c84-74b7-46e0-8215-ce10d0c84b3c)

> [!WARNING]
> Make sure you are in the right folder `~/actions-runner`

3. #### Terminate Instance

    Go to your AWS Management console --> EC2 terminate the created instance (git-workflow) and then remove any additional resources (vpc, security groups, s3 buckets, dynamodb tables, load balancers, volumes, auto scaling groups, etc)

    **Verify that every resource is removed or terminated**

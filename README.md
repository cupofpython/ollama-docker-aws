# Running an LLM using Docker and AWS

In this project, I provision a `c4.8xlarge` EC2 instance that installs Docker Desktop and allows me to run Ollama and interact with the `llama3.2` LLM. There are many options for your EC2 instance type, including GPU options, however I selected this one due to its low cost and that it had double the memory of my local machine (M4 Mac with 36 GiB memory).

## Local implementation
First, make sure you have Docker Desktop open and running on your local machine. Then, open your terminal and run an Ollama container. This command will pull the Ollama image if it is not already installed. 

`docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama`

You can navigate to the Docker Desktop UI and select the container and the "exec" tab to run llama3.2. Copy in this command and click enter:

`ollama run llama3.2`

Now you can interact with the model!

## AWS Implementation

### Pre-requisites: 
Make sure you install the following:
- AWS CLI, i.e. `brew install aws-cli`
- Terraform i.e. `brew install terraform`

Generate an SSH key if you do not have one already and update `main.tf` with your ssh key information.

Finally, make sure that you set up your AWS CLI by running `aws configure` and specify your AWS_ACCESS_KEY_ID and the key itself. You can generate an IAM user in the AWS console with the permission "AmazonEC2FullAccess." 

### Getting started

You are now ready to provision your infrastructure and run your LLM on an EC2 instance!

Navigate to your folder with main.tf and run `terraform init`. This will create a working directory with the Terraform config files. Then type in `terraform apply -auto-approve`. The auto-approve flag ignores the interactive approval of the plan before applying the changes.

Now you should be able to see the `Docker-EC2` instance in your AWS Console. Since we specified we wanted to allow SSH, we can SSH into the instance from our local machine. 

The command to SSH can be found in the EC2 instance's console under "SSH client". You can copy and paste the ssh command generated in that section into your Terminal to connect. The command should look similar to this:

`ssh -i "{your_public_key_name}" ec2-user@{ec2-user}.{AWS_region}.compute.amazonaws.com`

Once you have successfully ssh'd in, type `docker --version` to verify Docker is successfully installed. This should return some message such as:

`Docker version 25.0.8, build 0bab007`

### Running Ollama Container and the LLM

Now, simply re-run the command to run the Ollama container:

`docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama`

This should pull the image and run the container on port 11434. Verify that it is running by running the following command:

`docker ps`

This should show the running container. Since it was started in a detached state as indicated by the `-d` flag, the container is running in the background and we can exec in to start the LLM. Note down the container ID and put it in the following command to start the shell:

`docker exec -it {CONTAINER_ID} sh`

Now that you are in the shell, let's run llama3.2:

`ollama run llama3.2`

### Interact with the LLM!

At this point you can interact with the LLM via your Terminal just as you would in Docker Desktop or on your local machine's terminal. 

When you are done playing with the LLM, exit the llm and the shell and simply stop and remove the container.

- `/bye` # Exit the LLM
- `exit` # Exit the Shell
- `docker stop {CONTAINER_ID} && docker rm {CONTAINER_ID}` # Stop and remove the container
- `docker ps -a` # Verify container no longer exists, this should have no containers listed

### Cleanup Resources

Now we can exit our EC2 instance by typing `exit` and if we are done using the EC2 instance, we can terminate it in the AWS console or by using the command `terraform destroy` in our local terminal. Coonfirm destroying the resources by typing `yes` when prompted.

Verify your cleanup by accessing the AWS Console, where you should see your EC2 instance shutting down.# ollama-docker-aws

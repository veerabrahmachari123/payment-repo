# DevOps Labs - starter files

lab1-git/setup-lab1.sh        Builds the Git scenario (secret in history, stuck rebase)
lab2-docker/payment-api/      Flask app + STARTING Dockerfile (contains the fault)
lab3-jenkins/Jenkinsfile      STARTING Jenkinsfile (contains the fault)

## Lab 1
    pip install git-filter-repo
    bash lab1-git/setup-lab1.sh ~/lab1
    cd ~/lab1/payment-service

## Lab 2
    cd lab2-docker/payment-api
    docker build -t payment-api .
    docker run -d --name payment-api -p 8080:8080 payment-api
    curl localhost:8080/health      # fails - your job is to find out why
Do not open app.py until you have finished Task 3 (it contains the fault).

## Lab 3
Do Lab 2 first. Then:
1. Copy lab2-docker/payment-api to a new folder and keep YOUR fixed Dockerfile.
2. Put lab3-jenkins/Jenkinsfile in the root of that folder, run `git init`, commit.
3. Start a registry:  docker run -d --name registry -p 5000:5000 registry:2
4. Create the Jenkins job (Pipeline script from SCM) and follow Part B of the Word document.

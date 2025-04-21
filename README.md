### Prerequisites
#### AWS CLI is configured
#### Docker repository named `lambda-docker-image` created in ECR

## Lambda using zip
### Create Lambda function
```
cd <repo-root>/lambda/terraform/lambda-zip
terraform init
terraform plan
terraform apply -auto-approve
# terraform destroy -auto-approve
```

## Lambda using zip with Lambda layer
### Install Lambda layer packages
```
cd <repo-root>/lambda/terraform/layer-lambda-zip
python -m venv layer
source layer/Scripts/activate
pip install -r requirements.txt
```

### Create Lambda layer and Lambda function that uses the layer
```
cd <repo-root>/lambda/terraform/layer-lambda-zip
terraform init
terraform plan
terraform apply -auto-approve
# terraform destroy -auto-approve
```

## Lambda using Docker
### Create Docker image and push to ECR
```
cd <repo-root>/lambda
docker build --platform linux/amd64 -t lambda-docker-image:1.0 .
docker tag lambda-docker-image:1.0 291912718832.dkr.ecr.us-east-1.amazonaws.com/lambda-docker-image:1.0
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 291912718832.dkr.ecr.us-east-1.amazonaws.com
docker push 291912718832.dkr.ecr.us-east-1.amazonaws.com/lambda-docker-image:1.0
```

### Create Lambda function that uses the Dockr image
```
cd <repo-root>/lambda/terraform/lambda-docker
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```
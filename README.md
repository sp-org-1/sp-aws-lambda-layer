### Install Lambda layer packages
```
cd lambda
python -m venv layer
source layer/Scripts/activate
pip install -r requirements.txt
```

### Create Lambda layer and lambda function that uses the layer
```
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```
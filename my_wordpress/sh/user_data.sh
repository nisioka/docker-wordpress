#!/bin/bash

#
# Install required modules.
#
yum update
yum install -y git docker jq
curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#
# Initialize environment variables
#
INITENV_SHELL="/etc/rc.d/initenv.sh"
SETENV_SHELL="/etc/profile.d/setenv.sh"

# Create initenv.sh
# initialize environment variable script -START-----------------------
cat > "$INITENV_SHELL" <<"__EOS__"
#!/bin/bash

# Environment variables file name
SETENV_SHELL="/etc/profile.d/setenv.sh"

# Load environmental variables
INSTANCE_ID=$(curl 169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl 169.254.169.254/latest/meta-data/placement/region)
ZONE=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone)

VPC_ID=$(aws ec2 describe-instances --region ${REGION} --instance-ids ${INSTANCE_ID} --query "Reservations[0].Instances[0].NetworkInterfaces[0].VpcId" --output text)
VPC_PROJECT=$(aws ec2 describe-vpcs --region ${REGION} --vpc-ids ${VPC_ID} --query "Vpcs[0].Tags[?Key=='Project'].Value" --output text)
VPC_ENV=$(aws ec2 describe-vpcs --region ${REGION} --vpc-ids ${VPC_ID} --query "Vpcs[0].Tags[?Key=='Env'].Value" --output text)

SSM_PARAMETER_STORE=$(aws ssm get-parameters-by-path --region ${REGION} --path "/${VPC_PROJECT}/${VPC_ENV}" --with-decryption)

# Output environment initialize scripts.
cat > "${SETENV_SHELL}" <<EOF
#
# [$(date '+%Y-%m-%dT%H:%M:%S+09:00' -d '9 hour')] Initialized scripts.
#
export INSTANCE_ID="${INSTANCE_ID}"
export REGION="${REGION}"
export ZONE="${ZONE}"
export VPC_ID="${VPC_ID}"
export VPC_PROJECT="${VPC_PROJECT}"
export VPC_ENV="${VPC_ENV}"
EOF

for PARAMS in $(echo ${SSM_PARAMETER_STORE} | jq -r '.Parameters[] | .Name + "=" + .Value'); do
echo 'export "${PARAMS##*/}"'
done >> "${SETENV_SHELL}"

chmod +x "$SETENV_SHELL"
source "$SETENV_SHELL"
__EOS__
# initialize environment variable script -END-------------------------

# Modify initenv.sh access control.
chmod +x "$INITENV_SHELL"

# Add startup service
cat > "/etc/systemd/system/initenv.service" <<EOF
[Unit]
Description=Initialize environment variables.
After=network.target

[Service]
Type=oneshot
User=root
Group=root
ExecStart="$INITENV_SHELL"

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable initenv

# Load environment variables.
bash "$INITENV_SHELL"
source "$SETENV_SHELL"
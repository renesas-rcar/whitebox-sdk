#!/bin/bash

REGION=${REGION:-ap-southeast-1}
DEVICE_NAME=${DEVICE_NAME:-R-CarS4-Device}
GROUP_NAME=${GROUP_NAME:-R-CarS4-DeviceGroup}

java -Droot="/greengrass/v2" -Dlog.store=FILE -jar /greengrass/v2/alts/init/distro/lib/Greengrass.jar \
    --aws-region ${REGION} --thing-name ${DEVICE_NAME} --thing-group-name ${GROUP_NAME} \
    --tes-role-name GreengrassV2TokenExchangeRole --tes-role-alias-name GreengrassCoreTokenExchangeRoleAlias \
    --component-default-user ggc_user:ggc_group --provision true --setup-system-service true \
    --deploy-dev-tools true



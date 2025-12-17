#!/bin/bash -eu

git clone https://github.com/aws/aws-iot-fleetwise-edge.git -b v1.0.6 \
    ${AWS_WORK}/aws-iot-fleetwise-edge \
    && mkdir -p ${AWS_WORK}/aws-iot-fleetwise-deploy && cd ${AWS_WORK}/aws-iot-fleetwise-deploy \
    && cp -r ${AWS_WORK}/aws-iot-fleetwise-edge/tools . \
    && mkdir -p config && cd config \
    && ${AWS_WORK}/aws-iot-fleetwise-edge/tools/provision.sh \
    --vehicle-name ${VEHICLE_NAME} \
    --certificate-pem-outfile certificate.pem \
    --private-key-outfile private-key.key \
    --endpoint-url-outfile endpoint.txt \
    --vehicle-name-outfile vehicle-name.txt \
    && ${AWS_WORK}/aws-iot-fleetwise-edge/tools/configure-fwe.sh \
    --input-config-file ${AWS_WORK}/aws-iot-fleetwise-edge/configuration/static-config.json \
    --output-config-file config-0.json \
    --log-color Yes \
    --vehicle-name `cat vehicle-name.txt` \
    --endpoint-url `cat endpoint.txt` \
    --can-bus0 vcan0 \
    && cd .. \
    && cp ./tools/install-socketcan.sh ./tools/setup-vcan.sh \
    && sed -i '9,70d' ./tools/setup-vcan.sh \
    && sed -i '/^# Install setup-socketcan$/a mkdir -p /usr/local/bin' ./tools/setup-vcan.sh \
    && sed -i 's/python3.7/python3/g' ./tools/cansim/run-cansim.sh \
    && sed -i 's/python3.7/python3/g' ./tools/install-cansim.sh \
    && sed -i 's/^apt update/# apt update/g' ./tools/install-cansim.sh \
    && sed -i -e 's/^After/# After/' -e 's/^Wants/# Wants/' ./tools/cansim/cansim@.service \
    && zip -r aws-iot-fleetwise-deploy.zip .


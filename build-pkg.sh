#!/usr/bin/env bash

# Check if the environment variables are set
if [[ -z "$TIZEN_SIGNING_PROFILE" || -z "$TIZEN_SIGNING_PASSWORD" ]]; then
  echo "Error: TIZEN_SIGNING_PROFILE and TIZEN_SIGNING_PASSWORD must be set."
  exit 1
fi
if [[ -z "$TIZEN" || -z "$TIZEN_DATA" ]]; then
  echo "Error: TIZEN and TIZEN_DATA must be set."
  exit 1
fi

TIZEN=$(realpath "${TIZEN}")
TIZEN_DATA=$(realpath "${TIZEN_DATA}")

# create a temporary directory
tpk_root=$(mktemp -d)

# copy pkg stuff
cp -r ./pkg/* $tpk_root

# copy binary
mkdir -p $tpk_root/bin
cp ./zig-out/app $tpk_root/bin

# sign the package
${TIZEN}/tools/ide/bin/native-signing $tpk_root \
  ${TIZEN}/tools/certificate-generator/certificates/developer/tizen-developer-ca.cer \
  ${TIZEN_DATA}/keystore/${TIZEN_SIGNING_PROFILE}/author.p12 ${TIZEN_SIGNING_PASSWORD} \
  ${TIZEN}/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12 \
  tizenpkcs12passfordsigner \
  ${TIZEN}/tools/certificate-generator/certificates/distributor/tizen-distributor-ca.cer \
  ${TIZEN_DATA}/keystore/${TIZEN_SIGNING_PROFILE}/distributor.p12 ${TIZEN_SIGNING_PASSWORD} "" ""

rm -f $tpk_root/.manifest.tmp

# create a zip file
tpk_out=$(realpath ./zig-out/app.tpk)
rm -f $tpk_out
pushd $tpk_root
zip -0r $tpk_out .
popd

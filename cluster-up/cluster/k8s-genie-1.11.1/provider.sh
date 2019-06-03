#!/usr/bin/env bash

set -e

image="k8s-genie-1.11.1@sha256:bd3c56acfd0bdad24e204a49e41d2192eab4cad282a1bb9bed01790874ba8b58"

source ${KUBEVIRTCI_PATH}/cluster/ephemeral-provider-common.sh

function up() {
    ${_cli} run $(_add_common_params)

    # Copy k8s config and kubectl
    ${_cli} scp --prefix $provider_prefix /usr/bin/kubectl - >${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubectl
    chmod u+x ${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubectl
    ${_cli} scp --prefix $provider_prefix /etc/kubernetes/admin.conf - >${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubeconfig

    # Set server and disable tls check
    export KUBECONFIG=${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubeconfig
    ${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubectl config set-cluster kubernetes --server=https://$(_main_ip):$(_port k8s)
    ${KUBEVIRTCI_PATH}cluster/$KUBEVIRT_PROVIDER/.kubectl config set-cluster kubernetes --insecure-skip-tls-verify=true

    # Make sure that local config is correct
    prepare_config
}

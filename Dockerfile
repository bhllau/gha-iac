FROM hashicorp/terraform:1.6.2

# * https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# * https://v3-1-0.helm.sh/docs/intro/install/
ARG BUILD_ARCH=amd64
ARG KUBECTL_VERSION_URL=https://dl.k8s.io/release/stable.txt
ARG HELM_VERSION=v3.13.2

RUN \
	apk update \
	&& apk add curl jq aws-cli \
	&& curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s ${KUBECTL_VERSION_URL})/bin/linux/${BUILD_ARCH}/kubectl" \
	&& chmod +x /usr/local/bin/kubectl \
	&& curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-${BUILD_ARCH}.tar.gz | tar -xvzf - linux-${BUILD_ARCH}/helm -C /tmp && mv /tmp/linux-${BUILD_ARCH}/helm /usr/local/bin/ \
	&& chmod +x /usr/local/bin/helm

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


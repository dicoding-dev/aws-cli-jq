# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023 as installer

# Use ARG for platform-specific AWS CLI installer
ARG TARGETARCH

# Set download URL based on architecture
RUN yum update -y --allowerasing \
  && yum install -y curl unzip --allowerasing \
  && if [ "$TARGETARCH" = "amd64" ]; then \
      ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      ARCH="aarch64"; \
    else \
      echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi \
  && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install --bin-dir /aws-cli-bin/

FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN yum update -y \
  && yum install -y less groff jq \
  && yum clean all

COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/

WORKDIR /aws
ENTRYPOINT ["/usr/local/bin/aws"]

FROM public.ecr.aws/amazonlinux/amazonlinux:2 as installer
ARG VERSION="2.22.5"
RUN yum update -y \
  && yum install -y curl unzip \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${VERSION}.zip" -o awscliv2.zip \
  && unzip awscliv2.zip \
  # The --bin-dir is specified so that we can copy the
  # entire bin directory from the installer stage into
  # into /usr/local/bin of the final stage without
  # accidentally copying over any other executables that
  # may be present in /usr/local/bin of the installer stage.
  && ./aws/install --bin-dir /aws-cli-bin/

FROM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum update -y \
  && yum install -y less groff jq \
  && yum clean all
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/
WORKDIR /aws
ENTRYPOINT ["/usr/local/bin/aws"]
